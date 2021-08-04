# frozen_string_literal: true

class ImportJob < ApplicationRecord
  belongs_to :user

  validates :status, presence: true

  scope :latest, -> (user_id) { where(user_id: user_id).last }

  enum status: {
    wait: "待機",
    running: "実行中",
    success: "完了",
    faild: "失敗"
  }
end
