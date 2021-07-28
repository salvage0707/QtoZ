# frozen_string_literal: true

class ZipJob < ApplicationRecord
  belongs_to :user

  validates :status, presence: true,
                     inclusion: { in: %w(実行中 完了 失敗) }

  RUNNITG = "実行中"
  SUCCESS = "完了"
  FAILD   = "失敗"

  def running
    self.status = RUNNITG
  end

  def success
    self.status = SUCCESS
  end

  def faild
    self.status = FAILD
  end

  def isRunning?
    self.status == RUNNITG
  end

  def isSuccess?
    self.status == SUCCESS
  end

  def isFaild?
    sreturn elf.status == FAILD
  end
end
