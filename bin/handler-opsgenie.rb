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
         short: '-j <config-name>',
         long: '--json <config-name>',
         default: 'opsgenie'

  def handle
    @json_config = settings[config[:json_config]]
    # allow config to be changed by the check
    if @event['check']['opsgenie']
      @json_config.merge!(@event['check']['opsgenie'])
    end
    message = @event['notification'] || [@event['client']['name'], @event['check']['name'], @event['check']['output'].chomp].join(' : ')

    begin
      timeout(30) do
        response = case @event['action']
                   when 'create'
                     create_alert(message)
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

  def event_tags
    @event['client']['tags']
  end

  def client_name
    @event['client']['name']
  end

  def create_alert(message)
    tags = []
    tags << @json_config['tags'] if @json_config['tags']
    tags << 'OverwriteQuietHours' if event_status == 2 && @json_config['overwrite_quiet_hours'] == true
    tags << 'unknown' if event_status >= 3
    tags << 'critical' if event_status == 2
    tags << 'warning' if event_status == 1
    unless event_tags.nil?
      event_tags.each { |tag, value| tags << "#{tag}_#{value}" }
    end

    description = @json_config['description'] if @json_config['description']
    recipients = @json_config['recipients'] if @json_config['recipients']
    teams = @json_config['teams'] if @json_config['teams']

    post_to_opsgenie(:create,
                     alias: event_id,
                     message: message,
                     description: description,
                     entity: client_name,
                     tags: tags.join(','),
                     recipients: recipients,
                     teams: teams)
  end

  def post_to_opsgenie(action = :create, params = {})
    params['customerKey'] = @json_config['customerKey']

    # override source if specified, default is ip
    params['source'] = @json_config['source'] if @json_config['source']

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
