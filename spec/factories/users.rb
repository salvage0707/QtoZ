# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "example_user00#{n}" }
    password            { "password" }
    provider            { "Qiita" }
    sequence(:uid)      { |n| "example_user00#{n}" }
    access_token        { "fajkhsdfljalkjfdiej290u4" }
    image               { "https://s3-ap-northeast-1.amazonaws.com/qiita-image-store/0/88/ccf90b557a406157dbb9d2d7e543dae384dbb561/large.png?1575443439" }
  end
end
