class Article < ApplicationRecord
  belongs_to :user

  attr_writer :body

  before_save :save_body_to_storage
  after_destroy :destroy_body_from_storage

  MAX_IMPORT = 100

  def save_body_to_storage
    path = use_bucket_path()
    self.filepath = "#{path}/#{self.slag}.md"
    
    client = Storage::Client.create
    client.create_file StringIO.new(zenn_article_format()), self.filepath

    self.bucket_name = client.name
  end

  def update_body_from_storage
    # 空文字("") and nill の場合にファイルオブジェクトが生成されるため、チェックする
    return nil if self.filepath.blank?

    client = Storage::Client.create
    file = client.file self.filepath 

    return nil if file.nil?

    @body = get_body file

    client.create_file StringIO.new(zenn_article_format()), self.filepath
  end

  def destroy_body_from_storage
    # 空文字("") and nill の場合にファイルオブジェクトが生成されるため、チェックする
    return nil if self.filepath.blank?

    client = Storage::Client.create
    file = client.file self.filepath
    # バケットに存在する場合
    file.delete if !file.nil?
  end

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
      topics = response_data["tags"].map { |tag| '"'+tag["name"]+'"' }
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

  private

    def use_bucket_path
      user = User.find_by(id: self.user_id)
      return "zenn/#{user.username}"
    end

    def zenn_article_format
      template = <<~"EOS"
          --
          title: "#{self.title}" 
          emoji: "#{self.emoji}"
          type: "#{self.category}" 
          topics: [#{self.topics}]
          published: #{self.published}
          ---
          #{@body}
        EOS
      return template
    end

    def get_body (file)
      body = ""
      isRead = true

      # zenn形式のyaml行をのぞいてリード
      downloaded = file.download
      downloaded.each_line do |line|
        if /^---$/.match(line)
          isRead = !isRead
        end

        body << line if isRead
      end

      return body
    end
end
