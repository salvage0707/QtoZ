# frozen_string_literal: true

class CreateArticles < ActiveRecord::Migration[6.1]
  def change
    create_table :articles do |t|
      t.string :title,              null: false
      t.string :slag,               null: false
      t.string :emoji,              null: false
      t.string :category,           null: false
      t.string :topics,             null: false
      t.boolean :published,         null: false, default: true
      t.string :qiita_uid,          null: false
      t.string :qiita_url,          null: false
      t.datetime :qiita_created_at, null: false
      t.text :body,                 null: false

      t.references :user, null: false

      t.timestamps
    end
  end
end
