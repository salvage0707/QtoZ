class ZipController < ApplicationController
  before_action :authenticate_user!

  def index
    @jobs = current_user.zip_jobs.order(created_at: :desc).limit(5)
  end

  def create
    job = ZipJob.new(user_id: current_user.id)
    job.running
    job.save

    Thread.new(current_user, job) do |user, job|
      # ユーザーのバケットオブジェクト削除
      Article.delete_storage(user)

      # バケットにzenn形式記事をアップロード
      Article.export_storage(user)

      # URLを設定
      url = ENV['GCF_ZIP_URL']
      data = { 
        input_path: Article.bucket_path(user), 
        filename: user.username 
      }
      response = Faraday.post(url, data.to_json(), "Content-Type" => "application/json")

      if response.status == 200
        body = JSON.parse(response.body)
        job.url = body["public_url"]
        job.success
      else
        job.faild
      end

      job.save
    end

    redirect_to action: :index
  end
end
