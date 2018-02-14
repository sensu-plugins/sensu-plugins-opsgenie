# frozen_string_literal: true

require 'spec_helper'

gem_path = '/usr/local/bin'
handler_name = 'handler-opsgenie.rb'
handler = "#{gem_path}/#{handler_name}"

create_alert_file = '/tmp/kitchen/data/test/fixtures/create-alert.json'
resolve_alert_file = '/tmp/kitchen/data/test/fixtures/resolve-alert.json'

create_alert_with_alias_file = '/tmp/kitchen/data/test/fixtures/create-alert-with-alias.json'
resolve_alert_with_alias_file = '/tmp/kitchen/data/test/fixtures/resolve-alert-with-alias.json'

create_alert_with_description_file = '/tmp/kitchen/data/test/fixtures/create-alert-with-description.json'

# These tests would require a valid OpsGenie API key and heartbeat name
# configured in order to succeed.  Thus for now, we limit ourselves to the
# expected failure cases.

describe 'handler-opsgenie' do
  default_event_id_pattern = 'test01:some\.fake\.check\.name'
  describe command("#{handler} -v < #{create_alert_file}") do
    its(:stdout) { should match(/Description:.*CRITICAL.*text/) }
    its(:stdout) { should match(/failed to create incident.*#{default_event_id_pattern}.*not authorized/) }
  end

  describe command("#{handler} -v < #{resolve_alert_file}") do
    its(:stdout) { should match(/failed to resolve incident.*#{default_event_id_pattern}.*not authorized/) }
  end

  custom_event_id_pattern = 'MY_CUSTOM_ALIAS'
  describe command("#{handler} -v < #{create_alert_with_alias_file}") do
    its(:stdout) { should match(/failed to create incident.*#{custom_event_id_pattern}.*not authorized/) }
  end

  describe command("#{handler} -v < #{resolve_alert_with_alias_file}") do
    its(:stdout) { should match(/failed to resolve incident.*#{custom_event_id_pattern}.*not authorized/) }
  end

  custom_description_pattern = 'MY_CUSTOM_DESCRIPTION'
  describe command("#{handler} -v < #{create_alert_with_description_file}") do
    its(:stdout) { should_not match(/Description:.*CRITICAL.*text/) }
    its(:stdout) { should match(/Description:.*#{custom_description_pattern}/) }
  end
end
