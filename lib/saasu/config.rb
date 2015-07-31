module Saasu
  class Config
    class_attribute :username, :password, :file_id, :api_url

    class << self
      def configure
        yield self
      end
    end
  end
end
