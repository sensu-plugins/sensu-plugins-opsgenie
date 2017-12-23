# frozen_string_literal: true

require 'spec_helper'

gem_path = '/usr/local/bin'
handler_name = 'handler-opsgenie.rb'
handler = "#{gem_path}/#{handler_name}"
name = 'some.fake.check.name'

create_alert = {
  :client => {
    :name => 'test01',
    :address => '127.0.0.1',
    :subscriptions => %w[
      all
    ]
    :timestamp => 1326390159
  },
  :check => {
    :name => name,
    :issued => 1326390169
    :output => "HTTP CRITICAL: HTTP/1.1 503 Service Temporarily Unavailable - pattern not found - 593 bytes in 0.001 second response time |time=0.000500s;;;0.000000 size=593B;;;0\n",
    :status => 2,
    :notification => 'Smoke Check failed',
    :command => '/path/to/some/stuff/here -A do_stuff',
    :subscribers => %w[
      all
    ],
    :interval => 60,
    :handlers => %w[
      default
      opsgenie
    ],
    :history => %w[ 0 0 2 ],
    :flapping => false
  },
  :occurrences => 1,
  :action => 'create'
}

resolve_alert = create_alert
resolve_alert[:action] = 'resolve'

# These tests would require a valid OpsGenie API key and heartbeat name
# configured in order to succeed.  Thus for now, we limit ourselves to the
# expected failure cases.

describe 'handler-opsgenie' do
  describe command("echo "#{create_alert} | #{handler}") do
    its(:stdout) { should match(/failed to create incident.*not authorized/) }
  end

  describe command("echo "#{resolve_alert} | #{handler}") do
    its(:stdout) { should match(/failed to resolve incident.*not authorized/) }
  end
end
