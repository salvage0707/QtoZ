# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  queue_as :default

  MAX_IMPORT = Settings.qiita_api.import_job.max

  around_perform do |job_info, block|
    job = job_record(job_info)

    job.running!

    begin
      block.call
    rescue => exception
      job.faild!
      raise exception
    end

    job.success!
  end

  def perform(user_id, job_id, emoji)
    user = User.find(user_id)
    client = Qiita::Client.new(access_token: user.access_token)

    # ユーザーデータから投稿数を取得
    user_data_response = client.get_authenticated_user()
    items_count = user_data_response.body["items_count"]
    # 投稿数が本サービスの上限を超えているか判定
    import_item_count = (items_count > MAX_IMPORT) ? MAX_IMPORT : items_count
    # インポート数からページ数を取得
    max_page = (import_item_count.to_f / 20).ceil

    ActiveRecord::Base.transaction do
      # 1ページ目から取得
      (1..max_page).each do |page|
        params = { page: page }
        response = client.list_authenticated_user_items(params)
        response.body.each do |data|
          Article.import_from_qiita_response(user, emoji, data)
        end
      end
    end
  end

  private
    def job_record(job_info)
      job_id = job_info.arguments.second
      ImportJob.find(job_id)
    end
end
