require 'httpclient'

class ArticlesController < ApplicationController
  before_action :authenticate_user!

  def new
  end

  def create
    # 記事を全削除
    ActiveRecord::Base.transaction do
      current_user.articles.map(&:destroy!)
    end

    # レスポンスを早くするため非同期でインポート処理
    async_import_qiita_articles(current_user, current_user.access_token, params[:emoji])

    redirect_to articles_path
  end

  def zip
    url = ENV['GCF_ZIP_URL']  # URLを設定
    data = {
      username: current_user.username
    }
    response = Faraday.post(url, data.to_json(), Content-Type: "application/json")
    render json: response.body
  end

  def index
    @articles = current_user.articles
  end

  def destroy
    article = Article.find(params[:id])
    article.destroy
    redirect_to articles_path
  end

  private 
    
    def async_import_qiita_articles(user, access_token, default_emoji)
      Thread.new(user, access_token, default_emoji) do |user, access_token, default_emoji|
        articles = []
        client = Qiita::Client.new(access_token: current_user.access_token)

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
    end
end
