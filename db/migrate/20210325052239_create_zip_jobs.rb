class CreateZipJobs < ActiveRecord::Migration[6.1]
  def change
    create_table :zip_jobs do |t|
      t.references :user, null:false
      t.string :status, null:false
      t.string :url

      t.timestamps
    end
  end
end
