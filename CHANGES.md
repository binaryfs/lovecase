# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [4.1.0] - 2025-09-06

### Added

- A `callback` parameter for `lovecase.newSuite()` and `Suite.new()` to wrap tests in a closure

### Deprecated

- The assertions from `lovecase.expect` will be moved to `lovecase` in order to remove the `local expect = lovecase.expect` boilterplate code

## [4.0.1] - 2025-01-30

### Fixed

- Faulty assert in `Report:addSuite`

## [4.0.0] - 2025-01-30

### Added

- BREAKING CHANGE: `lovecase.expect` to make assertions about a value. This function replaces the `assert*` functions of the removed `TestSet` class.
- Internal `Group` class to represent a collection of test cases and subgroups
- Internal `Result` class to represent the result of a test case

### Changed

- Rename internal `helpers` module to `utils`
- BREAKING CHANGE: The `TestSet` class was refactored and renamed to `Suite`
- BREAKING CHANGE: The `TestReport` class was refactored and renamed to `Report`
- BREAKING CHANGE: Renamed `lovecase.newTestSet()` to `lovecase.newSuite()`

### Removed

- BREAKING CHANGE: Custom type checks and equality checks via `TestSet:addTypeCheck()` and `TestSet:addEqualityCheck()`. Define the `__eq` metamethod or an `equal[s]` method for your tables to use custom equality checks.

## [3.1.1] - 2023-11-04

### Added

- Info text in LÖVE demo

### Changed

- Rename repository from "lua-lovecase" to "lovecase"
- BREAKING CHANGE: Move files from lovecase subfolder into root directory. This change should make it easier to use lovecase as a Git submodule.

## [3.1.0] - 2023-09-05

### Added

- The new assertion methods `TestSet:assertSame` and `TestSet:assertNotSame` use `rawequal` for comparison
- Some unit tests for the lovecase module
- `TestSet:assertEqual` and `TestSet:assertNotEqual` perform a simple table comparison if no custom equality function exists and the __eq metamethod is not applicable
- `TestSet:assertAlmostEqual` and `TestSet:assertNotAlmostEqual` compare numbers with a tolerance, to allow a larger margin of error when comparing floating point numbers
- Serialize tables in assertion errors if no `__tostring` metamethod exists
- Relational assertion methods: `assertSmallerThan`, `assertSmallerThanEqual`, `assertGreaterThan` and `assertGreaterThanEqual`
- `TestReport:isFailed` checks if at least one test in a set failed (backported from roguelove)

### Changed

- BREAKING CHANGE: Replace `name` parameter in asserion functions with `message` parameter

### Removed

- The demo unit tests were removed in favor of the actual unit tests for lovecase

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