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

If the check definition uses the custom `alias` attribute, _e.g._:
```
{
  "checks": {
    "check_mysql_access": {
      "opsgenie": {
        "alias": "MyCustomAlias",

```
then the `handler-opsgenie.rb` handler will use that attribute value as the
OpsGenie event ID.  This can be useful for alert deduplication; checks on
different clients for the same downstream resource can specify the same
`alias` attribute, so that multiple alerts for the same resource are
de-duplicated.

By default, `handler-opsgenie.rb` creates an event ID from the client name
and the check name.  Thus:
```
{
  "checks": {
    "check_mysql_access": {
      "command": "/opt/sensu/embedded/bin/check-database.rb -h mysqldb",
      "interval": 60,
      "handlers": [ "opsgenie" ],
      "standalone": true
    }
  }
```
running on a client named `web01` will create an alert using an event ID of
`web01:check_mysql_access`.  And on a client named `web02`, it would create an
alert with a _different_ event ID of `web02:check_mysql_access`, even though
the `mysqldb` server being checked is the same for these clients.

We can define a custom `alias` attribute in this check:
```
{
  "checks": {
    "check_mysql_access": {
      "command": "/opt/sensu/embedded/bin/check-database.rb -h mysqldb",
      "interval": 60,
      "handlers": [ "opsgenie" ],
      "standalone": true,

      "opsgenie": {
        "alias": "mysqldb"
      }
    }
  }
```
And with this, running on multiple clients, any alerts would be generated
with the same event ID of `mysqldb`, by using that `alias` attribute as the
event ID.
