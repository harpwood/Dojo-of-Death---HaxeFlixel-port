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
 * and ninjas are allowed to move, inset 50px from each edge of the game canvas.
 * This is a smaller area than the full screen (see `isNotWithinScreen` below).
 *
 * Used by `Actor.updatePosition()` to clamp the player/ninjas so they can't
 * walk all the way to the screen edge.
 *
 * Caution: these bounds (50, 50, 750, 550) are hardcoded numbers, not derived
 * from `FlxG.width`/`FlxG.height`. They only line up with a 50px margin because
 * the game canvas is currently fixed at 800x600 in `Main.hx`
 * (750 = 800-50, 550 = 600-50). If the canvas size ever changes, these
 * constants must be updated by hand to match - unlike `isNotWithinScreen()`,
 * which reads `FlxG.width`/`FlxG.height` directly and adapts automatically.
 */
class GEA
{
	static public inline final TOP:Int 		= 50;    // Top edge of the effective (playable) area.
	static public inline final LEFT:Int 	= 50;    // Left edge of the effective (playable) area.
	static public inline final RIGHT:Int 	= 750;   // Right edge of the effective (playable) area.
	static public inline final BOTTOM:Int 	= 550;   // Bottom edge of the effective (playable) area.

	/**
	 * Checks whether a point falls outside the inset "effective area" above
	 * (i.e. whether an actor is trying to walk past the playable boundary).
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
	 * the arrow pool. Bounds are read live from `FlxG.width`/`FlxG.height`,
	 * so this one DOES adapt automatically if the canvas size changes.
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
