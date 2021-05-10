FactoryBot.define do
  factory :article do
    title                { "titleですよ！" }
    sequence(:slag)      { |n| "2e79a1abe7cd8214ceb#{n}" }
    emoji                { "✊" }
    category             { "tech" }
    topics               { 'hoge, foo, bar' }
    published            { true }
    sequence(:qiita_uid) { |n| "8ded79359c450dd30r0#{n}" }
    qiita_url            { "https://qiita.com/manbolila/items/8ded79359c450dd30e06" }
    qiita_created_at     { DateTime.new(2021, 4, 21, 12, 46, 37) }
    body                 { "# hoge body title ¥n ## body" }
    association :user
  end
end
