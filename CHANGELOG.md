#Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows the format listed at [Keep A Changelog](http://keepachangelog.com/)

## [Unreleased]
### Added
- Added description support for OpsGenie alerts.

## [1.0.0] - 2016-04-12
### Changed
- Changed the `-j, --jsonconfig` parameter to specify a key in the already-parsed JSON config file
- The `-j, --jsonconfig` parameter no longer takes a JSON config file as input
- Update to rubocop 0.37

## [0.0.3] - 2015-11-26
### Added
- Added team support for OpsGenie alerts.
- Added sensu tags integration.
- Allow check to override default handler config

### Updated
- Moved adding `recipients` parameter to JSON content to `create_alert` function. The `recipients` parameter is not available for `close_alert`.

### Fixed
- Fixed getting `source` field from JSON.

## [0.0.2] - 2015-07-14
### Changed
- updated `sensu-plugin` gem to `1.2.0`

### Removed
- Remove JSON gem dependency that is not longer needed with Ruby 1.9+

## 0.0.1 - 2015-06-27
### Fixed
- initial release
- Fixed json configuration load

[Unreleased]: https://github.com/sensu-plugins/sensu-plugins-opsgenie/compare/0.0.3...HEAD
[1.0.0]: https://github.com/sensu-plugins/sensu-plugins-opsgenie/compare/0.0.3...1.0.0
[0.0.3]: https://github.com/sensu-plugins/sensu-plugins-opsgenie/compare/0.0.2...0.0.3
[0.0.2]: https://github.com/sensu-plugins/sensu-plugins-opsgenie/compare/0.0.1...0.0.2

