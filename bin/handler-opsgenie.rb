#!/usr/bin/env ruby
#
# Opsgenie handler which creates and closes alerts. Based on the pagerduty
# handler.
#

require 'sensu-handler'
require 'net/https'
require 'uri'
require 'json'

class Opsgenie < Sensu::Handler
  option :json_config,
         description: 'Configuration name',
         short: '-j JSONCONFIG',
         long: '--json JSONCONFIG',
         default: 'opsgenie.json'

  def handle
    @json_config = JSON.parse(File.open(config[:json_config]).read)
    description = @event['notification'] || [@event['client']['name'], @event['check']['name'], @event['check']['output'].chomp].join(' : ')

    begin
      timeout(30) do
        response = case @event['action']
                   when 'create'
                     create_alert(description)
                   when 'resolve'
                     close_alert
                   end
        if response['code'] == 200
          puts 'opsgenie -- ' + @event['action'].capitalize + 'd incident -- ' + event_id
        else
          puts 'opsgenie -- failed to ' + @event['action'] + ' incident -- ' + event_id
        end
      end
    rescue Timeout::Error
      puts 'opsgenie -- timed out while attempting to ' + @event['action'] + ' a incident -- ' + event_id
    end
  end

  def event_id
    @event['client']['name'] + '/' + @event['check']['name']
  end

  def event_status
    @event['check']['status']
  end

  def close_alert
    post_to_opsgenie(:close, alias: event_id)
  end

  def create_alert(description)
    tags = []
    tags << @json_config['opsgenie']['tags'] if @json_config['opsgenie']['tags']
    tags << 'OverwriteQuietHours' if event_status == 2 && @json_config['opsgenie']['overwrite_quiet_hours'] == true
    tags << 'unknown' if event_status >= 3
    tags << 'critical' if event_status == 2
    tags << 'warning' if event_status == 1

    recipients = @json_config['opsgenie']['recipients']
    teams = @json_config['opsgenie']['teams']

    post_to_opsgenie(:create, alias: event_id, message: description, tags: tags.join(','), recipients: recipients, teams: teams)
  end

  def post_to_opsgenie(action = :create, params = {})
    params['customerKey'] = @json_config['opsgenie']['customerKey']

    # override source if specified, default is ip
    params['source'] = @json_config['opsgenie']['source'] if @json_config['opsgenie']['source']

    uripath = (action == :create) ? '' : 'close'
    uri = URI.parse("https://api.opsgenie.com/v1/json/alert/#{uripath}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
    request.body = params.to_json
    response = http.request(request)
    JSON.parse(response.body)
  end
end
