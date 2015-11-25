#Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows the format listed at [Keep A Changelog](http://keepachangelog.com/)

## [Unreleased]
### Added
- Added team support for OpsGenie alerts.
- Added sensu tags integration.

### Updated
- Moved adding "recipients" parameter to JSON content to create_alert function. Recipients parameter is not available for close_alert.

### Fixed
- Fixed getting "source" field from JSON.

## [0.0.2] - 2015-07-14
### Changed
- updated sensu-plugin gem to 1.2.0

### Removed
- Remove JSON gem dep that is not longer needed with Ruby 1.9+

## [0.0.1] - 2015-06-27
### Fixed
- initial release
- Fixed json configuration load
