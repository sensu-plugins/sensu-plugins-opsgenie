## Sensu-Plugins-opsgenie

[ ![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-opsgenie.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-opsgenie)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-opsgenie.svg)](http://badge.fury.io/rb/sensu-plugins-opsgenie)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-opsgenie/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-opsgenie)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-opsgenie/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-opsgenie)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-opsgenie.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-opsgenie)
[![Codeship Status for sensu-plugins/sensu-plugins-opsgenie](https://codeship.com/projects/28709400-e94a-0132-275c-26b28b7b5489/status?branch=master)](https://codeship.com/projects/82931)

## Functionality

## Files
 * `bin/handler-opsgenie.rb`
 * `bin/check-opsgenie-heartbeat.rb`

## Usage

**`handler-opsgenie`**
```json
{
  "opsgenie": {
    "customerKey": "the-key",
    "teams": ["teams"],
    "recipients": "the-recipients",
    "source": "alert-source",
    "overwrite_quiet_hours": true,
    "tags": ["sensu"]
  }
}
```

## Installation

[Installation and Setup](http://sensu-plugins.io/docs/installation_instructions.html)

## Notes
