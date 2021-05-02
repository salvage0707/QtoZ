require 'httpclient'

class ArticlesController < ApplicationController
  before_action :authenticate_user!

  def new
    @job = ImportJob.latest(current_user.id)
  end

  def create
    # 絵文字チェック
    article = Article.new(emoji: params[:emoji])
    article.invalid?
    if article.errors[:emoji].length > 0
      flash.now[:alert] = article.errors[:emoji][0]
      render 'new'
      return 
    end

    # 記事を全削除
    ActiveRecord::Base.transaction do
      current_user.articles.destroy_all
    end

    # レスポンスを早くするため非同期でインポート処理
    async_import_qiita_articles(current_user, params[:emoji])

    redirect_to action: :new
  end

  def index
    job = ImportJob.latest(current_user.id)
    unless job.isSuccess?
      flash[:notice] = "インポート中です。再度記事設定ページにアクセスしてください。"
      redirect_to action: :new 
    end

    @articles = current_user.articles
  end

  def destroy
    article = Article.find(params[:id])
    article.destroy
    redirect_to articles_path
  end

  private 
    
    def async_import_qiita_articles(user, default_emoji)
      job = ImportJob.new(user: user)
      job.running
      job.save!

      Thread.new(user, default_emoji, job) do |user, default_emoji, job|
        begin
          ActiveRecord::Base.transaction do
            articles = []
            client = Qiita::Client.new(access_token: user.access_token)

            # ユーザーデータから投稿数を取得
            user_data_response = client.get_authenticated_user()
            items_count = user_data_response.body["items_count"]
            # 投稿数が本サービスの上限を超えているか判定
            import_item_count = (items_count > Article::MAX_IMPORT) ? Article::MAX_IMPORT : items_count
            # インポート数からページ数を取得
            max_page = (import_item_count.to_f / 20).ceil

            # 1ページ目から取得
            (1..max_page).each do |page|
              params = {page: page}
              response = client.list_authenticated_user_items(params)
              Article.import_from_qiita_response(user, default_emoji, response)
            end
          end

          job.success
          job.save!

        rescue => e
          job.faild
          job.save!
          raise e
        end
      end
    end
end
