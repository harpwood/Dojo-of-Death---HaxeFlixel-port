# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2026-08-31

### Fixed
- Fixed HaxeFlixel signal binding syntax in `Ninja.hx` (`actor.animation.onFinish.add(...)` instead of invalid rebinding operator `=`).
- Updated deprecated mouse screen coordinate accessors in `Player.hx` to use `FlxG.mouse.viewX` and `FlxG.mouse.viewY`.
- Restored build compatibility with modern HaxeFlixel releases.

## [1.0.0] - 2023-06-09

### Added
- Initial public open-source release of the HaxeFlixel port.