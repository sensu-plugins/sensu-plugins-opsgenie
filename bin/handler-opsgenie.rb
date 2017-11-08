#!/usr/bin/env ruby
#
# Opsgenie handler which creates and closes alerts. Based on the pagerduty
# handler.
#

require 'sensu-handler'
require 'net/https'
require 'uri'
require 'json'
require 'erb'

class Opsgenie < Sensu::Handler
  attr_reader :json_config, :message_template

  OPSGENIE_URL = 'https://api.opsgenie.com/v1/json/alert'.freeze

  option :json_config,
         description: 'Configuration name',
         short: '-j <config-name>',
         long: '--json <config-name>',
         default: 'opsgenie'

  option :message_template,
         description: 'Location of custom erb template for advanced message formatting',
         short: '-t <file_path>',
         long:  '--template <file_path>',
         default: nil

  def handle
    init
    process
  end

  private

  def init
    @json_config      = settings[config[:json_config]] || {}
    @message_template = config[:message_template]
    # allow config to be changed by the check
    json_config.merge!(@event['check']['opsgenie']) if @event['check']['opsgenie']
  end

  def process
    timeout = json_config[:timeout] || 30
    Timeout.timeout(timeout) do
      response = case @event['action']
                 when 'create'
                   create_alert
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

  def message
    return @event['notification'] unless @event['notification'].nil?
    return default_message if message_template.nil? || !File.exist?(message_template)
    custom_message
  rescue StandardError
    default_message
  end

  def custom_message
    ERB.new(File.read(message_template)).result(binding)
  end

  def default_message
    [@event['client']['name'], @event['check']['name'], @event['check']['output'].chomp].join(' : ')
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

  def create_alert
    post_to_opsgenie(:create,
                     alias:       event_id,
                     message:     message,
                     description: json_config['description'],
                     entity:      client_name,
                     tags:        tags.join(','),
                     recipients:  json_config['recipients'],
                     teams:       json_config['teams'])
  end

  def tags
    tags = []
    tags << json_config['tags'] if json_config['tags']
    tags << 'OverwriteQuietHours' if event_status == 2 && json_config['overwrite_quiet_hours'] == true
    tags << 'unknown' if event_status >= 3
    tags << 'critical' if event_status == 2
    tags << 'warning' if event_status == 1
    event_tags.each { |tag, value| tags << "#{tag}_#{value}" } unless event_tags.nil?
    tags
  end

  def post_to_opsgenie(action = :create, params = {})
    params['customerKey'] = json_config['customerKey']

    # override source if specified, default is ip
    params['source'] = json_config['source'] if json_config['source']

    uripath = (action == :create) ? '' : 'close'
    uri = URI.parse("#{OPSGENIE_URL}/#{uripath}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
    request.body = params.to_json
    response = http.request(request)
    JSON.parse(response.body)
  end
end
