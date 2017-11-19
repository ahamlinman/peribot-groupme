# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog], and while pre-1.0 development is in
progress this project adheres to a form of Semantic Versioning (see README.md).

[Keep a Changelog]: http://keepachangelog.com/en/1.0.0/

## [Unreleased]
### Added
- Changelog for all notable modifications going forward.

### Changed
- Upgraded Peribot dependency to 0.10.0.
- Modified bot mode filtering functionality to use the Peribot 0.10.0 "filter"
  stage (rather than the "preprocessor" stage).

### Fixed
- GroupMe messages without text (e.g. when an image is sent to a group via the
  GroupMe web app) no longer cause exceptions in Peribot::Service.

[Unreleased]: https://github.com/ahamlinman/peribot/compare/0.9.0...HEAD
