package;

/**
 * Auto-generates a static String constant for every file under the "assets"
 * folder at compile time (via the `@:build` macro below), so paths could be
 * referenced as e.g. `AssetPaths.images__bg__png` instead of typing the raw
 * string. The `true` argument enables recursive scanning into subfolders.
 *
 * Note: despite existing and being auto-populated, none of these generated
 * constants are actually referenced anywhere else in this codebase - every
 * asset path elsewhere (Background.hx, Ninja.hx, Audio.hx, etc.) is written
 * as a raw string literal like `"assets/images/bg.png"` instead. This class
 * currently has no effect on the game beyond existing.
 */
@:build(flixel.system.FlxAssets.buildFileReferences("assets", true))
class AssetPaths {}