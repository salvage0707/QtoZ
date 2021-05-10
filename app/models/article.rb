class Article < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :emoji, presence: true
  validates :slag,  presence: true, 
                    format: { with: /\A[a-z0-9¥-]+\z/, message: 'は"a-z0-9"と"-"の組み合わせで入力してください' },
                    length: { in: 12..50 },
                    uniqueness: { scope: :user_id  }
  validates :category,  presence: true,
                        inclusion: { in: %w(tech idea)}
  validates :topics,    presence: true
  validates :published, inclusion: { in: [true, false] }
  validates :qiita_uid, presence: true
  validates :qiita_url, presence: true
  validates :qiita_created_at, presence: true
  validates :user_id,          presence: true

  MAX_IMPORT = 100

  before_save do
    # topicsの不要な空白を削除する
    striped_topics = self.topics.split(",").map { |v| v.strip}
    self.topics = striped_topics.join(",")
  end

  def self.import_from_qiita_response(user, emoji, response)
    if emoji.blank?
      emoji = Emoji.random_emoji_unicode()
    end

    article = Article.new
    article.title    = response["title"]
    article.slag     = response["id"]
    article.emoji    = emoji
    article.category = "tech"
    topics = response["tags"].map { |v| v["name"] }
    article.topics    = topics.join(",")
    article.published = (response["private"] == "true") ? false : true; # 限定公開の物は公開しない設定でimport
    article.qiita_uid = response["id"]
    article.qiita_url = response["url"]
    article.qiita_created_at = response["created_at"]
    article.user_id = user.id
    article.body    = response["body"]

    article.save!
  end

  def self.export_storage(user)
    client = Storage::Client.create
    
    ids = Article.where(user_id: user.id).pluck(:id)
    
    ids.each do |id|
      article = Article.find(id)
      prefix = bucket_path(user)
      bucket_path = "#{prefix}/#{article.slag}.md"
      client.create_file StringIO.new(zenn_article_format(article)), bucket_path
    end
  end

  def self.delete_storage(user)
    client = Storage::Client.create
    file_name = bucket_path(user)
    files = client.files(prefix: file_name)
    files.each do |f| 
      f.delete
    end
  end

  def self.bucket_path(user)
    return "#{user.username}/article"
  end

  private

    def self.zenn_article_format(article)
      # hoge -> "hoge"にする
      topics = article.topics.map { |v| '"'+v+'"' }
      template = <<~"EOS"
          ---
          title: "#{article.title}" 
          emoji: "#{article.emoji}"
          type: "#{article.category}" 
          topics: [#{topics}]
          published: #{article.published}
          ---
          #{article.body}
        EOS
      return template
    end

end
