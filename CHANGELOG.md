# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.8] - 2026-09-09

### Changed
- Ninja shadow filter caches are now pre-baked once per enemy type during
  the title-screen loading phase (`GameState.create()`), instead of being
  populated lazily on each type's first real spawn - moves the one-time
  hitch introduced by pooling (see 1.0.6) out of live gameplay entirely.
- `Actor.shadowColorMatrixFilter` is now a `static` field (identical
  across every Actor instance) instead of being rebuilt per instance.

### Fixed
- Fixed a Haxe field-visibility issue where `Ninja.hx`/`Player.hx`
  referenced `shadowColorMatrixFilter` without the required `Actor.`
  qualifier (Haxe's default field visibility only auto-resolves through
  `this` for instance fields, not for static fields accessed from a
  subclass).

## [1.0.7] - 2026-09-08

### Changed
- `Ninja` instances are now pooled and reused instead of being permanently
  destroyed on death and reconstructed from scratch on every spawn -
  bringing it in line with every other spawned/recycled object in the game
  (Blood, Arrow, Smoke, etc.). `GameState.addNinja()` now searches for an
  existing dormant instance to reuse before creating a new one;
  `GameState.updatePlayState()` no longer removes dead ninjas from the
  tracking array, keeping them available for reuse instead.

### Fixed
- `Ninja.deInitialize()` now calls `kill()` on its sprites instead of
  `destroy()`-ing them and removing them from their groups, which is what
  makes reuse possible (`FlxGroup.update()`/`draw()` already skip
  `exists == false` members automatically).
- `Ninja.initialize()` was missing `actor.revive()`/`shadow.revive()`.
  Without it, a reused ninja's sprites stayed permanently invisible
  (`exists` never reset to `true`) and their animations never advanced
  (Flixel groups also gate `update()` on `exists`), which in turn meant a
  reused ninja's death animation could never complete and finalize,
  leaving it stuck spawning blood particles indefinitely.
- `Ninja.deInitialize()` now also clears `actor.animation.onFinish`
  (`removeAll()`), not just `hit()` as added in 1.0.6. Root cause of
  ninjas occasionally dying with no attack involved: `onFinish` fires on
  any non-looped animation finishing, not just death, so a reused
  instance's own completed attack animation could trigger a stale
  callback left over from a previous life.

## [1.0.6] - 2026-09-08

### Changed
- `Ninja.bakeNinja()` now caches the shadow's filtered `BitmapData` once
  per enemy type (`Type.SWORD`/`Type.BOW`) instead of re-running the
  per-pixel color filter on every single ninja spawn - fixes a
  long-standing Neko-only stutter on enemy spawn (native/neko targets are
  known to be slow at this specific operation; HTML5 was unaffected).

### Added
- `Ninja.hit()` now clears any previous `onFinish` animation listener
  before registering a new one, in preparation for future object pooling.

## [1.0.5] - 2026-09-08

### Fixed
- Fixed framerate-dependent particle motion in `Blood.hx` and
  `ArrowBroken.hx` - both had per-frame position/fade changes that weren't
  scaled by elapsed time, unlike every other value in the same effects
  (and unlike `Smoke.hx`'s correctly-scaled equivalent). Particles now
  behave identically regardless of framerate.

## [1.0.4] - 2026-09-07

### Changed
- Replaced several `Math.sqrt()` distance checks with squared-distance
  comparisons where only a threshold check was needed (Arrow, Ninja,
  Player) - avoids an unnecessary square root in hot paths.
- Renamed several confusingly-similar identifiers for clarity:
  `meleeReach` -> `meleeHitRadius`, `meleeRange` -> `meleeEngageRange`,
  `rangedRange` -> `rangedEngageRange`, and `Direction` (class + file) ->
  `ArrowSplitDirection`, to remove naming overlap with Flixel's own
  `FlxDirectionFlags`.

### Fixed
- Replaced a recursive pool-retry pattern in `GameState`'s pooling
  functions with a simple skip, removing a latent stack-overflow risk if
  pool size limits are ever introduced in the future.
- Removed two unused imports in `Ninja.hx`.

## [1.0.3] - 2026-09-07

### Fixed
- Fixed a null-reference crash in `Audio.isMusicPlaying()`/`resumeMusic()`
  reachable if music was disabled before gameplay ever started.
- Fixed camera fade-in tweens on the game-over screen never being
  cancelled, which could leak a stale grayscale/blur effect into a new
  play session if the player restarted quickly after dying.

## [1.0.2] - 2026-09-06

### Changed
- Full documentation pass across the entire codebase (all 25 `.hx` files):
  clarified comments throughout, explained non-obvious design decisions
  and Flixel-specific behavior, and corrected several stale or inaccurate
  comments left over from earlier changes. Aimed at making the project
  easier to learn from, in line with its goal as an educational HaxeFlixel
  resource.

### Fixed
- Fixed the pause screen not darkening the background at all - an unused
  constructor parameter meant it always rendered fully transparent.
- Removed miscellaneous dead code (redundant assignments, a duplicate
  line) and replaced several magic numbers with named constants.

## [1.0.1] - 2026-08-31

### Fixed
- Fixed HaxeFlixel signal binding syntax in `Ninja.hx` (`actor.animation.onFinish.add(...)` instead of invalid rebinding operator `=`).
- Updated deprecated mouse screen coordinate accessors in `Player.hx` to use `FlxG.mouse.viewX` and `FlxG.mouse.viewY`.
- Restored build compatibility with modern HaxeFlixel releases.

## [1.0.0] - 2023-06-09

### Added
- Initial public open-source release of the HaxeFlixel port.
