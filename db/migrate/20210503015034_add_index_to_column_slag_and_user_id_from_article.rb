class AddIndexToColumnSlagAndUserIdFromArticle < ActiveRecord::Migration[6.1]
  def change
    add_index :articles,[:slag, :user_id], unique: true
  end
end
