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
 * `Actor.hx`), a separate, unrelated LEFT/RIGHT enum from the Flixel
 * library used for sprite facing/flipping. Different purpose entirely -
 * this class's narrower name is meant to make that distinction obvious
 * without needing this note, but it's kept here for anyone who still
 * lands on this file wondering.
 */
class ArrowSplitDirection
{
	static public inline final LEFT:Int = 0;    // Broken arrow half launches to the left.
	static public inline final RIGHT:Int = 1;   // Broken arrow half launches to the right.
}