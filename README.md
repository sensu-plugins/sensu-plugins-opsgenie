## Sensu-Plugins-opsgenie

[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-opsgenie.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-opsgenie)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-opsgenie.svg)](http://badge.fury.io/rb/sensu-plugins-opsgenie)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-opsgenie/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-opsgenie)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-opsgenie/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-opsgenie)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-opsgenie.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-opsgenie)

## Functionality

## Files
 * bin/handler-opsgenie
 * bin/check-opsgenie-heartbeat

## Usage

**handler-opsgenie**
```
{
  "opsgenie": {
    "customerKey": "the-key",
    "recipients": "the-recipients",
    "source": "alert-source",
    "overwrite_quiet_hours": true,
    "tags": [ "sensu" ]
  }
}
```

## Installation

Add the public key (if you haven’t already) as a trusted certificate

```
gem cert --add <(curl -Ls https://raw.githubusercontent.com/sensu-plugins/sensu-plugins.github.io/master/certs/sensu-plugins.pem)
gem install sensu-plugins-opsgenie -P MediumSecurity
```

You can also download the key from /certs/ within each repository.

#### Rubygems

`gem install sensu-plugins-opsgenie`

#### Bundler

Add *sensu-plugins-disk-checks* to your Gemfile and run `bundle install` or `bundle update`

#### Chef

Using the Sensu **sensu_gem** LWRP
```
sensu_gem 'sensu-plugins-opsgenie' do
  options('--prerelease')
  version '0.0.1'
end
```

Using the Chef **gem_package** resource
```
gem_package 'sensu-plugins-opsgenie' do
  options('--prerelease')
  version '0.0.1'
end
```

## Notes
