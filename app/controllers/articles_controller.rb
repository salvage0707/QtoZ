# frozen_string_literal: true

require "httpclient"

class ArticlesController < ApplicationController
  before_action :authenticate_user!

  def new
    @job = ImportJob.latest(current_user.id)
  end

  def create
    # 記事を全削除
    ActiveRecord::Base.transaction do
      current_user.articles.destroy_all
    end

    # レスポンスを早くするため非同期でインポート処理
    # async_import_qiita_articles(current_user, params[:emoji])
    job = ImportJob.create(
      user: current_user,
      status: :wait
    )
    ApplicationJob.perform_later(current_user.id, job.id, params[:emoji])

    redirect_to action: :new
  end

  def index
    job = ImportJob.latest(current_user.id)
    unless job.success?
      flash[:notice] = "インポート中です。再度記事設定ページにアクセスしてください。"
      redirect_to action: :new
    end

    @articles = current_user.articles.order(qiita_created_at: :desc)
  end

  def update
    article = current_user.articles.find(params[:id])
    article.slag  = params[:slag]
    article.title = params[:title]
    article.emoji = params[:emoji]
    article.category  = params[:type]
    article.topics    = params[:topics]
    article.published = params[:published]

    if article.save
      render json: article, status: :ok
    else
      render json: article.errors, status: :bad_request
    end
  end

  def destroy
    article = current_user.articles.find(params[:id])
    article.destroy
    redirect_to articles_path
  end
end
