FactoryBot.define do
  factory :import_job do
    status { "実行中" }
    association :user
  end
end
