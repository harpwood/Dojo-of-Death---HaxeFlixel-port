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
 * Utility class for defining facing directions of actor sprites.
 * The side-facing direction (both left and right) sprites will be flipped horizontally as needed.
 */

class Facing 
{
	static public inline final SIDE:Int 	= 0;    // Side-facing direction for actor sprites. Sprites will be flipped horizontally.
	static public inline final FRONT:Int 	= 1;    // Front-facing direction for actor sprites.
	static public inline final BACK:Int 	= 2;    // Back-facing direction for actor sprites.
}

