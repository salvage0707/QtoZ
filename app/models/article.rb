class Article < ApplicationRecord
  validates :emoji, format: { with: /\A\p{Emoji}{1}\z/, message: "絵文字を1文字入力してください" }

  belongs_to :user

  MAX_IMPORT = 100

  def self.import_from_qiita_response(user, emoji, response)
    # インサート処理
    response.body.each do |response_data|
      # 限定公開の記事は対象外
      next if response_data["private"] == "true"

      article = Article.new
      article.title     = response_data["title"]
      article.slag      = response_data["id"]
      article.emoji     = emoji
      article.category  = "tech"
      topics  = response_data["tags"].map { |tag| '"'+tag["name"]+'"' }
      article.topics           = topics.join(",")
      article.published        = true
      article.qiita_uid        = response_data["id"]
      article.qiita_url        = response_data["url"]
      article.qiita_created_at = response_data["created_at"]
      article.user_id          = user.id
      article.body = response_data["body"]

      article.save!
    end
  end

  def self.export_storage(user)
    client = Storage::Client.create
    
    ids = Article.where(user_id: user.id).pluck(:id)
    p ids
    
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
      template = <<~"EOS"
          ---
          title: "#{article.title}" 
          emoji: "#{article.emoji}"
          type: "#{article.category}" 
          topics: [#{article.topics}]
          published: #{article.published}
          ---
          #{article.body}
        EOS
      return template
    end

end
