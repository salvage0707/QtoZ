class ArticlesController < ApplicationController
  before_action :authenticate_user!

  def new
  end

  def create
    Thread.new do
      sleep(3)
      p Time.now
    end
    redirect_to articles_path
  end

  def index
    @articles = current_user.articles
  end

  def destroy
    article = Article.find(params[:id])
    article.destroy
    redirect_to articles_path
  end
end
