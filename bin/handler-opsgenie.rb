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
  attr_reader :json_config, :message_template, :verbose

  PRIORITIES = %w[P1 P2 P3 P4 P5].freeze
  DEFAULT_PRIORITY = 'P3'.freeze

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

  option :api_endpoint,
         description: 'Opsgenie API endpoint',
         long: '--api endpoint',
         default: 'api.opsgenie.com'

  option :proxy_url,
         long: '--proxy Proxy',
         description: 'Proxy URL',
         default: ''

  option :verbose,
         description: 'Enable verbose/debugging output',
         short: '-v',
         long: '--verbose',
         default: false

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
      case response.code.to_s
      when '200', '202'
        puts "opsgenie -- #{@event['action'].capitalize}d incident -- #{event_id}"
      when '401'
        puts "opsgenie -- failed to #{@event['action']} incident -- #{event_id}: not authorized"
      when '404'
        puts "opsgenie -- failed to #{@event['action']} incident -- #{event_id} not found"
      else
        puts "opsgenie -- failed to #{@event['action']} incident -- #{event_id}"
        puts "HTTP #{response.code} #{response.message}: #{response.body}"
      end
    end
  rescue Timeout::Error
    puts "opsgenie -- timed out while attempting to #{@event['action']} a incident -- #{event_id}"
  end

  def description
    return json_config['description'] unless json_config['description'].nil?
    @event['check']['output'].chomp
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
    [@event['client']['name'], @event['check']['name']].join(' : ')
  end

  def event_id
    return @event['check']['opsgenie']['alias'] unless @event['check']['opsgenie'].nil? || @event['check']['opsgenie']['alias'].nil?

    # Do not use slashes in the event ID, as this alias becomes part of the URI
    # in the RESTful interactions with OpsGenie; use characters which can be
    # easily embedded into a URI.
    @event['client']['name'] + ':' + @event['check']['name']
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
                     description: description,
                     entity:      client_name,
                     tags:        tags,
                     recipients:  json_config['recipients'],
                     teams:       json_config['teams'])
  end

  def event_priority
    return DEFAULT_PRIORITY unless json_config['priority']
    priority = json_config['priority']

    canonical_priority = priority.upcase
    unless PRIORITIES.include? canonical_priority
      puts "opsgenie -- ignoring unsupported priority '#{priority}'"
      canonical_priority = DEFAULT_PRIORITY
    end

    canonical_priority
  end

  def tags
    tags = []
    tags += json_config['tags'] if json_config['tags']
    tags << 'OverwriteQuietHours' if event_status == 2 && json_config['overwrite_quiet_hours'] == true
    tags << 'unknown' if event_status >= 3
    tags << 'critical' if event_status == 2
    tags << 'warning' if event_status == 1
    event_tags.each { |tag, value| tags << "#{tag}_#{value}" } unless event_tags.nil?
    tags
  end

  def post_to_opsgenie(action = :create, params = {})
    # Override source if specified, default is ip
    params['source'] = json_config['source'] if json_config['source']

    # Override priority, if specified.
    priority = event_priority
    params['priority'] = priority if priority

    encoded_alias = URI.escape(params[:alias])
    # TODO: come back and asses if this logic is correct, I left it functionally
    # as it was originally written but I suspect we should have at least three
    # cases to check: create, close, and else for catching errors but I don't
    # really know the opsgenie API and am not terribly motivated to look into it
    # right now.
    uripath = if action == :create
                ''
              else
                "#{encoded_alias}/close?identifierType=alias"
              end
    uri = URI.parse("https://#{config[:api_endpoint]}/v2/alerts/#{uripath}")

    if config[:verbose]
      # Note that the ordering of these lines roughly follows the order
      # alert fields are displayed in the OpsGenie web UI.
      puts "URL: #{uri}"
      puts "Message: #{params[:message]}"
      puts "Tags: #{params[:tags]}"
      puts "Entity: #{params[:entity]}"
      puts "Teams: #{params[:teams]}"
      puts "Alias: #{params[:alias]}"
      puts "Description: #{params[:description]}"
    end

    u = URI.parse(config[:proxy_url])
    proxy = [u.host, u.port, u.user, u.password].compact

    Net::HTTP.start(uri.host, uri.port, *proxy, :use_ssl => true, :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
      request = Net::HTTP::Post.new(uri.request_uri, 'Authorization' => "GenieKey #{json_config['customerKey']}", 'Content-Type' => 'application/json')
      request.body = params.to_json
      http.request(request)
    end
  end
end
