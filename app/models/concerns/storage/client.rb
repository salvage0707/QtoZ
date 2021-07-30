# frozen_string_literal: true

require "google/cloud/storage"

module Storage
  class Client
    def self.create
      if Rails.env.development?
        keyfile = "#{Rails.root}/#{Settings.gcp.cloud_storage.article_files.keyfile}"
        storage = Google::Cloud::Storage.new(credentials: keyfile)
      else
        storage = Google::Cloud::Storage.new()
      end

      bucket_name = Settings.gcp.cloud_storage.article_files.bucket_name
      storage.bucket bucket_name
    end
  end
end
