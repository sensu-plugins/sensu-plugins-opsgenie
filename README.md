## Sensu-Plugins-opsgenie

[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-opsgenie.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-opsgenie)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-opsgenie.svg)](http://badge.fury.io/rb/sensu-plugins-opsgenie)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-opsgenie/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-opsgenie)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-opsgenie/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-opsgenie)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-opsgenie.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-opsgenie)

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

## Configuration
To get this to work you need to specify a few different things. For a list of fields that are required/available look at the [sensu documentation](https://sensuapp.org/docs/0.25/enterprise/integrations/opsgenie.html). These files need to be on the server and the client boxes. Once there restart sensu-server and sensu-api. 

  - declare this as a handler: `/etc/sensu/conf.d/handler_opsgenie.json`
``` json
{
  "handlers": {
    "opsgenie": {
      "type": "pipe",
      "command": "/opt/sensu/embedded/bin/handler-opsgenie.rb"
    }
  },
  "opsgenie": {
    "customerKey": "YOUR-KEY-HERE"
  }
}  
```

  - add it to the check: `/etc/sensu/conf.d/check_xxx.json`
``` json
{
  "checks": {
    "check_elastinats_is_running": {
      "command": "/opt/sensu/embedded/bin/check-process.rb -p cron",
      "interval": 60,
      "handlers": [ "opsgenie" ],
      "subscribers": [ "core" ]
    }
  }
}
```
  
  - optionally add it to the default handler: `/etc/sensu/conf.d/default_handler.json`
``` json
{
  "handlers": {
    "default": {
      "type": "set",
      "handlers": [
        "opsgenie"
      ]
    }
  }
}
```

## Notes
