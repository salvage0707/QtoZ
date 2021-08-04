# frozen_string_literal: true

class ZipJob < ApplicationRecord
  belongs_to :user

  validates :status, presence: true

  enum status: {
    wait: "待機",
    running: "実行中",
    success: "完了",
    faild: "失敗"
  }
end
