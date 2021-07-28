# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "Validation チェック" do
    let(:target) { build(:user) }

    context "ユーザー名(username)" do
      it "空の値が無効であること" do
        target.username = nil
        expect(target).to_not be_valid
      end

      it "重複が無効であること" do
        other_user = create(:user, username: target.username)
        expect(target).to_not be_valid
      end
    end

    context "アイコン(image)" do
      it "空の値が有効であること" do
        target.image = nil
        expect(target).to be_valid
      end
    end

    context "プロバイダー(provider)" do
      it "空の値が無効であること" do
        target.provider = nil
        expect(target).to_not be_valid
      end
    end

    context "アクセストークン(access_token)" do
      it "空の値が無効であること" do
        target.access_token = nil
        expect(target).to_not be_valid
      end
    end

    context "Qiita uid(uid)" do
      it "空の値が無効であること" do
        target.uid = nil
        expect(target).to_not be_valid
      end
    end

    context "パスワード(password)" do
      it "空の値が無効であること" do
        target.password = nil
        expect(target).to_not be_valid
      end
    end
  end
end
