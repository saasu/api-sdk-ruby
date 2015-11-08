class Saasu::FileIdentity < Saasu::Base
  allowed_methods :show, :index

  def self.find(file_id)
    Saasu::Client.request(:get, 'FileIdentity', { FileId: file_id })
  end
end