module GovFakeNotify
  module CurrentService
    def current_service(store: Store.instance)
      header = request.headers['Authorization'].gsub(/^Bearer /, '')
      store.transaction do
        store.roots.each do |root|
          next unless root.start_with?('apikey')

          return store[root].dup if validate_jwt(header, store[root]['secret_token'])
        end
      end
      nil
    end

    def validate_jwt(token, secret)
      JWT.decode token, secret, 'HS256'
      true
    rescue JWT::DecodeError
      false
    end
  end
end