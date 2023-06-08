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
 * GEA stands for Game Effective Area
 * Utility class for defining the game's effective area and providing related helper functions.
 */
class GEA
{
	static public inline final TOP:Int 		= 50;    // The top boundary of the game's effective area.
	static public inline final LEFT:Int 	= 50;    // The left boundary of the game's effective area.
	static public inline final RIGHT:Int 	= 750;   // The right boundary of the game's effective area.
	static public inline final BOTTOM:Int 	= 550;   // The bottom boundary of the game's effective area.

	/**
	 * Checks if the specified coordinates are outside the game's effective area.
	 * @param x The X coordinate to check.
	 * @param y The Y coordinate to check.
	 * @return True if the coordinates are outside the effective area, false otherwise.
	 */
	static public function isNotWithin(x:Float, y:Float):Bool
	{
		return (x < LEFT || x > RIGHT || y < TOP || y > BOTTOM);
	}
	
	/**
	 * Checks if the specified coordinates are outside the screen bounds.
	 * @param x The X coordinate to check.
	 * @param y The Y coordinate to check.
	 * @return True if the coordinates are outside the screen, false otherwise.
	 */
	static public function isNotWithinScreen(x:Float, y:Float):Bool
	{
		return (x < 0 || x > FlxG.width || y < 0 || y > FlxG.height);
	}
}
