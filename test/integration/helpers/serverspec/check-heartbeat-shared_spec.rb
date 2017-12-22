# frozen_string_literal: true

require 'spec_helper'

gem_path = '/usr/local/bin'
check_name = 'check-opsgenie-heartbeat.rb'
check = "#{gem_path}/#{check_name}"
name = 'some.fake.heartbeat.name'
key = 'some.fake.api.key'

# These tests would require a valid OpsGenie API key and heartbeat name
# configured in order to succeed.  Thus for now, we limit ourselves to the
# expected failure cases.

describe 'check-opsgenie-heartbeat' do
  describe command("#{check} --key #{key} --name #{name}") do
    its(:exit_status) { should eq 3 }
    its(:stdout) { should match(/UNKNOWN: unexpected response code 401/) }
  end
end
