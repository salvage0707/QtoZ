require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'Validation チェック' do
    before do
      @user = create(:user)
    end

    context 'ユーザー名(username)' do
      it '空の値が無効であること' do
        @user.username = nil
        expect(@user).to_not be_valid
      end

      it '重複が無効であること' do
        other_user = build(:user, username: @user.username)
        expect(other_user).to_not be_valid
      end
    end

    context 'アイコン(image)' do
      it '空の値が有効であること' do
        @user.image = nil
        expect(@user).to be_valid
      end
    end

    context 'プロバイダー(provider)' do
      it '空の値が無効であること' do
        @user.provider = nil
        expect(@user).to_not be_valid
      end
    end

    context 'アクセストークン(access_token)' do
      it '空の値が無効であること' do
        @user.access_token = nil
        expect(@user).to_not be_valid
      end
    end

    context 'Qiita uid(uid)' do
      it '空の値が無効であること' do
        @user.uid = nil
        expect(@user).to_not be_valid
      end
    end

    context 'パスワード(password)' do
      it '空の値が無効であること' do
        @user.password = nil
        expect(@user).to_not be_valid
      end
    end

  end
end
