require "google/cloud/storage"
 
module Storage
  class Client
    def self.create
      if Rails.env.development?
        keyfile = "#{Rails.root}/#{ENV['GOOGLE_CREDENTIAL_FILE']}"
        storage = Google::Cloud::Storage.new(credentials: keyfile)
      else
        storage = Google::Cloud::Storage.new()
      end
      
      return storage.bucket Settings.storage.bucket
    end
  end
end