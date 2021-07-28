# frozen_string_literal: true

require "rails_helper"

RSpec.describe ZipJob, type: :model do
  describe "Validation チェック" do
    let(:target) { build(:zip_job, user: create(:user)) }

    describe "ステータス(status)" do
      it "空の値が無効であること" do
        target.status = nil
        expect(target).to_not be_valid
      end

      context "パターンチェック(実行中 or 完了 or 失敗)" do
        it '"実行中"が有効であること' do
          target.status = "実行中"
          expect(target).to be_valid
        end

        it '"完了"が有効であること' do
          target.status = "完了"
          expect(target).to be_valid
        end

        it '"失敗"が有効であること' do
          target.status = "失敗"
          expect(target).to be_valid
        end

        it "許容されない値が無効であること" do
          target.status = "hoge status"
          expect(target).to_not be_valid
        end
      end
    end

    describe "ユーザー(user_id)" do
      it "空の値が無効であること" do
        target.user = nil
        expect(target).to_not be_valid
      end
    end

    describe "ダウンロードurl(url)" do
      it "空の値が有効であること" do
        target.url = nil
        expect(target).to be_valid
      end
    end
  end
end
