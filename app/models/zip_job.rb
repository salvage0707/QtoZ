class ZipJob < ApplicationRecord
  belongs_to :user

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
    return self.status == RUNNITG
  end

  def isSuccess?
    return self.status == SUCCESS
  end

  def isFaild?
    sreturn elf.status == FAILD
  end
end
