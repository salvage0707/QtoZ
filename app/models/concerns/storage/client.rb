require "google/cloud/storage"
 
module Storage
  class Client
    def self.create
      if Rails.env.development?
        keyfile = "#{Rails.root}/#{ENV['GOOGLE_CREDENTIAL_FILE']}"
      else
        keyfile = ENV['GOOGLE_CREDENTIAL_FILE']
      end
      
      storage = Google::Cloud::Storage.new(credentials: keyfile)
      return storage.bucket Settings.storage.bucket
    end
  end
end