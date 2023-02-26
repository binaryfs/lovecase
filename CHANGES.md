# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.0.0] - 2023-02-26

### Added

- Specify data providers for test cases (see `TestSet.run`)
- Allow to override the formatting options for reports, e.g. to show only failed tests

### Changed

- Replace LDoc with annotations from [Lua Language Server](https://github.com/LuaLS/lua-language-server)

### Removed

- BREAKING CHANGE: `group` parameter in group callbacks (see `TestSet.group`)
- BREAKING CHANGE: `test` parameter in test run callbacks (see `TestSet.run`)
- Several constants from the TestReport class (these were moved to the default options table)

## [2.0.0] - 2020-12-25

### Added

- `CHANGES.md` file to document notable changes.
- Printed test report in `README.md`.

### Changed

- BREAKING CHANGE: The `message` argument of `TestSet:assert*` functions was replaced by a `name` argument, used to name the asserted value in error messages.