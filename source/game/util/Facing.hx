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
 * Which row of animations to use for an actor's current facing.
 *
 * These aren't just descriptive labels - they're used directly as the first-dimension
 * index into `animNames`/`animData` in `Actor.hx` (e.g. `animNames[Facing.SIDE][ANIM_RUN]`).
 * That means the order here (SIDE=0, FRONT=1, BACK=2) must exactly match the row order
 * used when building those arrays in `Actor`, `Player`, and `Ninja`. If you ever reorder
 * one, you must reorder the other, or animations will play from the wrong facing.
 *
 * SIDE covers both left and right - the actual left/right mirroring is done separately
 * via horizontal sprite flipping (see `Actor.facing()`), not by a third/fourth Facing value.
 */
class Facing 
{
	static public inline final SIDE:Int 	= 0;    // Facing left or right; sprite is flipped horizontally as needed.
	static public inline final FRONT:Int 	= 1;    // Facing toward the camera (moving downward on screen).
	static public inline final BACK:Int 	= 2;    // Facing away from the camera (moving upward on screen).
}

