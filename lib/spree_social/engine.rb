module SpreeSocial
  OAUTH_PROVIDERS = [
    ["Facebook", "facebook"],
    ["Twitter", "twitter"],
    ["Vkontakte", "vkontakte"],
    ["Github", "github"],
    ["Google", "google_oauth2"]
  ]

  class Engine < Rails::Engine
    engine_name 'spree_social'

    config.autoload_paths += %W(#{config.root}/lib)

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../../app/**/*_decorator*.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc
  end

  # Setup all OAuth providers
  def self.init_provider(provider)
    return unless ActiveRecord::Base.connection.table_exists?('spree_authentication_methods')
    key, secret, options = nil
    Spree::AuthenticationMethod.where(:environment => ::Rails.env).each do |auth_method|
      if auth_method.provider == provider
        key = auth_method.api_key
        secret = auth_method.api_secret
        options = YAML.load(auth_method.options || '')
        puts("[Spree Social] Loading #{auth_method.provider.capitalize} as authentication source")
      end
    end
    self.setup_key_for(provider.to_sym, key, secret, options)
  end

  def self.setup_key_for(provider, key, secret, options = {})
    options ||= {}
    Devise.setup do |config|
      config.omniauth provider, key, secret, options
    end
  end
end
