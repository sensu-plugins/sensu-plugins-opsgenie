require 'json'

# encoding: utf-8
module SensuPluginsOpsgenie
  # This defines the version of the gem
  module Version
    MAJOR = 4
    MINOR = 1
    PATCH = 2

    VER_STRING = [MAJOR, MINOR, PATCH].compact.join('.')

    NAME   = 'sensu-plugins-opsgenie'.freeze
    BANNER = "#{NAME} v%s".freeze

    module_function

    def version
      format(BANNER, VER_STRING)
    end

    def json_version
      {
        'version' => VER_STRING
      }.to_json
    end
  end
end
