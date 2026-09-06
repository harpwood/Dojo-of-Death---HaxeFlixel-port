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
 * Defines the two Ninja variants. Used only for `Ninja` (Player has no type).
 *
 * Gotcha: `GameState.addNinja()` currently rolls the type with a raw
 * `Math.random() > 0.2 ? 0 : 1` instead of these named constants. It's the
 * same 0/1 values, just spelled out by hand at that one call site - worth
 * knowing so you don't go looking for `Type.SWORD`/`Type.BOW` there and
 * conclude ninja spawning is broken.
 */
class Type 
{
	
	static public inline final SWORD:Int	= 0; // Sword Ninja: melee attacker, short range.
	static public inline final BOW:Int		= 1; // Bow Ninja: ranged attacker, shoots arrows.
	
}