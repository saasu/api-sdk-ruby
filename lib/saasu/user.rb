class Saasu::User < Saasu::Base
  def self.reset_password(username)
    raise "Username is required." if username.blank?
    Saasu::Client.request(:post, 'User/reset-password', { Username: username })['StatusMessage']
  end
end