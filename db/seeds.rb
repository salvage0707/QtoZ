# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require "json"

file = File.read(Rails.root.join("tmp", "data", "articles.json"))
data_hash = JSON.parse(file)
data_hash.each do |data|
  title = data["title"]
  qiita_uid = data["id"]
  url = data["url"]
  tag_names = data["tags"].map { |item| item["name"] }
  tags = tag_names.join(",")
  isPrivate = data["private"]
  created_at = data["created_at"]
  Article.create!(title: title, slag: qiita_uid, emoji: "✊", category: "tech", topics: tags, qiita_uid: qiita_uid, qiita_url: url, qiita_created_at: created_at, user_id: 1)
end
