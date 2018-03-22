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
    "teams": [
      { "name": "the-team" },
      { "id": "4513b7ea-3b91-438f-b7e4-e3e54af9147c" }
    ],
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

## OpsGenie Alerts

How does the handler map the various Sensu values into the OpsGenie
[alerts and alert fields](https://docs.opsgenie.com/docs/alerts-and-alert-fields) created?

### Message

The OpsGenie _message_ alert field is comprised of the Sensu client name, and
the Sensu check name, _e.g._:
```
web01 : check_mysql_access
```

### Teams

The OpsGenie _team_ alert field uses the values in the Sensu check configuration
if any, otherwise it uses the value from the handler configuration.

### Recipients

The OpsGenie _recipients_ alert field uses the values in the Sensu check
configuration if any, otherwise it uses the value from the handler
configuration.

### Alias

The OpsGenie _alias_ alert is field is comprised of the Sensu client name,
and the Sensu check name to create a unique key, _e.g._:
```
web01:check_mysql_access
```
Note that this can be changed via configuration; see notes below.

### Entity

The OpsGenie _entity_ alert field uses the Sensu client name.

### Description

The OpsGenie _description_ alert field is populated with the Sensu check output.

### Priority

The OpsGenie _priority_ alert field is not explicitly set; OpsGenie will thus
assign the default priority of "P3" to the alert.


## Configuration Notes

### Per Check Attributes

#### `alias`

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

#### `priority`

By default, an OpsGenie alert is created with a default [priority](https://docs.opsgenie.com/docs/priority-settings) value of "P3".  The priority for a specific
check can be explicitly set using the custom `priority` attribute, _e.g._:
```
{
  "checks": {
    "check_mysql_access": {
      "opsgenie": {
        "priority": "P1",

```
The list of valid values, per [OpsGenie alert docs](https://docs.opsgenie.com/docs/alert-api#section-create-alert), are:

* P1
* P2
* P3
* P4
* P5

Any value other than these will be ignored.
