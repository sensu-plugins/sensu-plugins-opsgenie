# frozen_string_literal: true

require 'spec_helper'

gem_path = '/usr/local/bin'
handler_name = 'handler-opsgenie.rb'
handler = "#{gem_path}/#{handler_name}"

# Example JSON input to the OpsGenie handler, from Sensu, via stdin.  We write
# it to a file to avoid shell-isms.
create_alert_file = '/tmp/create-alert.json'
create_alert = '{"client":{"name":"test01","address":"127.0.0.1","subscriptions":["all"],"timestamp":1326390159},"check":{"name":"some.fake.check.name","issued":1326390169,"output":"CRITICAL: text\n","status":2,"notification":"check failed","command":"/path/to/some/stuff/here -A do_smoke","subscribers":["all"],"interval":60,"handlers":["default","opsgenie"],"history":["0","0","2"],"flapping":false},"occurrences":1,"action":"create"}'
File.open(create_alert_file, 'w') { |f| f.write(create_alert) }

# Example JSON input to the OpsGenie handler, from Sensu, via stdin.
resolve_alert_file = '/tmp/resolve-alert.json'
resolve_alert = '{"client":{"name":"test01","address":"127.0.0.1","subscriptions":["all"],"timestamp":1326390159},"check":{"name":"some.fake.check.name","issued":1326390169,"output":"CRITICAL: text\n","status":2,"notification":"check failed","command":"/path/to/some/stuff/here -A do_smoke","subscribers":["all"],"interval":60,"handlers":["default","opsgenie"],"history":["0","0","2"],"flapping":false},"occurrences":1,"action":"resolve"}'
File.open(resolve_alert_file, 'w') { |f| f.write(resolve_alert) }

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
