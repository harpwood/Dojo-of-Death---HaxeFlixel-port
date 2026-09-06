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

/**
 * Which way an `ArrowBroken` half flies off after an arrow is deflected.
 * Used only by `Arrow` (to trigger the split) and `ArrowBroken` (to pick
 * a leftward or rightward launch velocity).
 *
 * Not to be confused with `flixel.util.FlxDirectionFlags` (imported in
 * `Actor.hx`/`Ninja.hx`), which is a separate, unrelated LEFT/RIGHT enum
 * from the Flixel library used for sprite facing/flipping. Same names,
 * different classes, different purposes - don't mix them up.
 */
class Direction
{
	static public inline final LEFT:Int = 0;    // Broken arrow half launches to the left.
	static public inline final RIGHT:Int = 1;   // Broken arrow half launches to the right.
}