class Article < ApplicationRecord
  belongs_to :user

  MAX_IMPORT = 100

  def self.import_from_qiita_response(user_id, emoji, response)
    # インサート処理
    articles = []
    response.body.each do |response_data|
      article = {}
      article[:title]     = response_data["title"]
      article[:slag]      = response_data["id"]
      article[:emoji]     = emoji
      article[:category]  = "tech"
      topics = response_data["tags"].map { |tag| tag["name"] }
      article[:topics]           = topics.join(",")
      article[:published]        = true
      article[:qiita_uid]        = response_data["id"]
      article[:qiita_url]        = response_data["url"]
      article[:qiita_created_at] = response_data["created_at"]
      article[:user_id]          = user_id

      articles << article
    end

    import!(articles)
  end
end
