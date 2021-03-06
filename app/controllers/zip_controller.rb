# frozen_string_literal: true

class ZipController < ApplicationController
  before_action :authenticate_user!

  def index
    @jobs = current_user.zip_jobs.order(created_at: :desc).limit(5)
  end

  def create
    job = ZipJob.new(user_id: current_user.id)
    job.status = :wait
    job.save

    Thread.new(current_user, job) do |user, job|
      job.status = :running
      job.save!

      # ユーザーのバケットオブジェクト削除
      Article.delete_storage(user)

      # バケットにzenn形式記事をアップロード
      Article.export_storage(user)

      # URLを設定
      url = Settings.gcp.cloud_functions.zenn_zip.url
      data = {
        input_path: Article.bucket_path(user),
        filename: user.username
      }
      response = Faraday.post(url, data.to_json(), "Content-Type" => "application/json")

      if response.status == 200
        body = JSON.parse(response.body)
        job.url = body["public_url"]
        job.status = :success
      else
        job.status = :faild
      end

      job.save
    rescue => exception
      job.status = :faild
      job.save
      raise exception
    end

    redirect_to action: :index
  end
end
