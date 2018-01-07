# frozen_string_literal: true

require 'spec_helper'

gem_path = '/usr/local/bin'
handler_name = 'handler-opsgenie.rb'
handler = "#{gem_path}/#{handler_name}"

create_alert_file = '/tmp/kitchen/data/test/fixtures/create-alert.json'
resolve_alert_file = '/tmp/kitchen/data/test/fixtures/resolve-alert.json'

# These tests would require a valid OpsGenie API key and heartbeat name
# configured in order to succeed.  Thus for now, we limit ourselves to the
# expected failure cases.

describe 'handler-opsgenie' do
  describe command("#{handler} < #{create_alert_file}") do
    its(:stdout) { should match(/failed to create incident.*not authorized/) }
  end

  describe command("#{handler} < #{resolve_alert_file}") do
    its(:stdout) { should match(/failed to resolve incident.*not authorized/) }
  end
end
