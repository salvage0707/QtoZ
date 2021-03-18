class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable,
         :omniauthable, omniauth_providers: %i[qiita]

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.username = auth.info.nickname
      user.password = Devise.friendly_token[0, 20]
      user.image = auth.info.image 
      user.access_token = auth.credentials.token
    end
  end
end
