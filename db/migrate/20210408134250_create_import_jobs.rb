# frozen_string_literal: true

class CreateImportJobs < ActiveRecord::Migration[6.1]
  def change
    create_table :import_jobs do |t|
      t.string :status
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
