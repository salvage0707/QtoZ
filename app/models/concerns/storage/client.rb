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

    def self.article_body(filepath)
      # TODO: 途中
      client = create()

      # ファイルの存在チェック
      if filepath.present?
        file = client.file self.filepath 
      end
      return nil if !file.nil?

      downloaded = file.download

      downloaded.each_line


      client.create_file StringIO.new(@body), self.filepath
    end
  end
end