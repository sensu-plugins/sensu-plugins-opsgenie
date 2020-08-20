#! /usr/bin/env ruby
#
#   check-opsgenie-heartbeat
#
# DESCRIPTION:
#   Sends heartbeat signal to Opsgenie. If Opsgenie does not receive one at least every 10 minutes
#   it will alert. Fails with a warning if heartbeat is not configured in the Opsgenie admin
#   interface.
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: uri
#   gem: json
#   gem: net-https
#
# USAGE:
#   check-opsgenie-heartbeat.rb -k aaaaaa-bbbb-cccc-dddd-eeeeeeeee -n 'My Awesome Heartbeat'
#
# NOTES:
#   Recommended plugin interval: 200 and occurences: 3
#
# LICENSE:
#   Copyright 2014 Sonian, Inc. and contributors. <support@sensuapp.org>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'
require 'net/https'
require 'uri'
require 'json'

class OpsgenieHeartbeat < Sensu::Plugin::Check::CLI
  option :api_key,
         short: '-k apiKey',
         long: '--key apiKey',
         description: 'Opsgenie API key',
         required: true

  option :api_endpoint,
         long: '--api endpoint',
         description: 'Opsgenie API endpoint',
         default: 'api.opsgenie.com'

  option :name,
         short: '-n Name',
         long: '--name Name',
         description: 'Heartbeat Name',
         default: 'Default'

  option :timeout,
         short: '-t Secs',
         long: '--timeout Secs',
         description: 'Plugin timeout',
         proc: proc(&:to_i),
         default: 10

  option :proxy_url,
         long: '--proxy Proxy',
         description: 'Proxy URL',
         default: ''

  def run
    Timeout.timeout(config[:timeout]) do
      response = opsgenie_heartbeat
      puts response
      case response.code.to_s
      when '200', '202'
        puts JSON.parse(response.body)
        ok 'heartbeat sent'
      when 8
        warning 'heartbeat not enabled'
      else
        unknown 'unexpected response code ' + response.code.to_s
      end
    end
  rescue Timeout::Error
    warning 'heartbeat timed out'
  end

  def opsgenie_heartbeat
    encoded_name = URI.escape(config[:name])
    uri = URI.parse("https://#{config[:api_endpoint]}/v2/heartbeats/#{encoded_name}/ping")

    u = URI.parse(config[:proxy_url])
    proxy = [u.host, u.port, u.user, u.password].compact

    Net::HTTP.start(uri.host, uri.port, *proxy, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
      request = Net::HTTP::Post.new(uri.request_uri, 'Authorization' => "GenieKey #{config[:api_key]}")
      http.request(request)
    end
  end
end
