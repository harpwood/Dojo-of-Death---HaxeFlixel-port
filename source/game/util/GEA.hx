/**
 * ----------------------------------------
 * @author Harpwood Studio
 * https://harpwood.itch.io/
 * ----------------------------------------
 * ----------------------------------------
 * Original Game Created by Nico Tuason
 * Ported to HaxeFlixel by Harpwood Studio
 * ----------------------------------------
 */
package game.util;

import flixel.FlxG;

/**
 * GEA stands for Game Effective Area: the inner rectangle where the player
 * and ninjas are allowed to move, inset `MARGIN` pixels from each edge of
 * the game canvas. This is a smaller area than the full screen (see
 * `isNotWithinScreen` below, which checks the full canvas instead).
 *
 * Used by `Actor.updatePosition()` to clamp the player/ninjas so they can't
 * walk all the way to the screen edge.
 */
class GEA
{
	/**
	 * The inset margin, in pixels, applied to all four edges of the canvas
	 * to get the playable area. This is a genuine constant - it doesn't
	 * depend on canvas size, so `inline final` is correct and safe here
	 * (see TOP/LEFT/RIGHT/BOTTOM below for why the same isn't true of them).
	 */
	static public inline final MARGIN:Int = 50;

	/**
	 * TOP/LEFT/RIGHT/BOTTOM below are written as `(get, never)` properties -
	 * they read like plain fields (`GEA.RIGHT`), but each access actually
	 * runs a small function that computes the value fresh. This matters for
	 * two separate, real reasons - not just "it's good practice":
	 *
	 * 1. `inline final` (the pattern MARGIN above uses) requires the compiler
	 *    to know the value at COMPILE time, so it can literally substitute
	 *    the number everywhere the field is used - much like a C `#define`.
	 *    `FlxG.width`/`FlxG.height` are only known at RUNTIME (after the game
	 *    window actually opens), so `inline final RIGHT = FlxG.width - MARGIN;`
	 *    doesn't have a valid compile-time value to inline and won't compile.
	 *
	 * 2. Even a plain (non-inline) `static final RIGHT = FlxG.width - MARGIN;`
	 *    would only run that calculation ONCE - whenever this class first
	 *    gets loaded, which could theoretically happen before `FlxG.width`
	 *    has its real value set up. Being `final`, that wrong value would
	 *    then be locked in permanently, with no error to warn you.
	 *
	 * A `(get, never)` property sidesteps both problems: nothing is computed
	 * until the moment someone actually reads `GEA.RIGHT`, using whatever
	 * `FlxG.width` genuinely is at that exact moment - always correct,
	 * regardless of initialization order or if the canvas size ever changes.
	 */
	static public var TOP(get, never):Float;
	static function get_TOP():Float return MARGIN;

	static public var LEFT(get, never):Float;
	static function get_LEFT():Float return MARGIN;

	static public var RIGHT(get, never):Float;
	static function get_RIGHT():Float return FlxG.width - MARGIN;

	static public var BOTTOM(get, never):Float;
	static function get_BOTTOM():Float return FlxG.height - MARGIN;

	/**
	 * Checks whether a point falls outside the inset "effective area" above
	 * (i.e. whether an actor is trying to walk past the playable boundary).
	 *
	 * Note this function's own code hasn't changed at all from before this
	 * class was reworked - `LEFT`/`RIGHT`/`TOP`/`BOTTOM` still read exactly
	 * like plain field access here. That's the point of using properties
	 * instead of, say, turning these into `left()`/`right()` functions: this
	 * call site (and the one in `Actor.updatePosition()`) never needed to
	 * change to pick up the new, dynamic behavior.
	 *
	 * @param x The X coordinate to check.
	 * @param y The Y coordinate to check.
	 * @return True if the point is outside the effective area, false otherwise.
	 */
	static public function isNotWithin(x:Float, y:Float):Bool
	{
		return (x < LEFT || x > RIGHT || y < TOP || y > BOTTOM);
	}
	
	/**
	 * Checks whether a point falls outside the full game canvas (not the
	 * smaller effective area above). Used by `Arrow` to detect when a fired
	 * arrow has flown completely off-screen so it can be recycled back into
	 * the arrow pool. This one already read `FlxG.width`/`FlxG.height`
	 * directly even before GEA's own bounds were reworked - it was always
	 * the "correct" pattern that TOP/LEFT/RIGHT/BOTTOM now also follow.
	 *
	 * @param x The X coordinate to check.
	 * @param y The Y coordinate to check.
	 * @return True if the point is outside the visible screen, false otherwise.
	 */
	static public function isNotWithinScreen(x:Float, y:Float):Bool
	{
		return (x < 0 || x > FlxG.width || y < 0 || y > FlxG.height);
	}
}