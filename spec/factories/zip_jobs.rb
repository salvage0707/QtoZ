FactoryBot.define do
  factory :zip_job do
    status { "実行中" }
    url    { "http://example.com/hoge/foo" }
    association :user
  end
end
