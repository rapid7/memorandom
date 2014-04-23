module Memorandom
  class PluginManager
    @@plugins = {}

    def self.register(name, klass)
      @@plugins[name.downcase.gsub(/\s+/, '_')] = klass
    end

    def self.plugins
      @@plugins
    end

    def self.load_plugins
      Memorandom::Plugins.constants.each do |c|
        register(c.to_s, Memorandom::Plugins.const_get(c))
      end
    end
  
  end
end

require 'memorandom/plugins/template'

require 'memorandom/plugins/pem'
require 'memorandom/plugins/der'
require 'memorandom/plugins/rsa'
require 'memorandom/plugins/aes'
require 'memorandom/plugins/capi'
require 'memorandom/plugins/url_params'
require 'memorandom/plugins/hashes'
require 'memorandom/plugins/cc'