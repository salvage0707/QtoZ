class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable,
         :omniauthable, omniauth_providers: %i[qiita]
  
  has_many :articles
  has_many :zip_jobs

  validates :username,     presence: true, uniqueness: true
  validates :provider,     presence: true
  validates :access_token, presence: true
  validates :uid,          presence: true
  validates :password,     presence: true

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.username = auth.info.nickname
      user.password = Devise.friendly_token[0, 20]
      user.image = auth.info.image 
      user.access_token = auth.credentials.token
    end
  end

end
