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
 * Central place for every state constant used in the game.
 *
 * IMPORTANT: this class actually defines THREE separate, unrelated enumerations
 * (actor states, strike states, game states) that just happen to share the same
 * `State` class for convenience. Their integer values overlap on purpose
 * (e.g. State.RUN == State.GROW == State.INTRO == 0) but that overlap is meaningless -
 * each group is only ever compared against objects of its own kind
 * (an Actor checks its state against Actor states, a StrikeLine against Strike states,
 * and so on). Don't assume two constants are related just because their values match.
 */

class State 
{
	// --- Actor states (used by Actor, Player, Ninja) ---
	static public inline final NO_STATE:Int = -1; // No active state; the actor is finished and about to be removed/cleaned up.
	static public inline final RUN:Int 			= 0;  // Moving toward a target / idle, ready to act.
	static public inline final CHARGE:Int 		= 1;  // Winding up before an attack (used by Ninja only; the Player skips straight to ATTACK).
	static public inline final ATTACK:Int 		= 2;  // Actively performing the attack lunge/animation.
	static public inline final COOLDOWN:Int 	= 3;  // Brief recovery period right after attacking, before returning to RUN.
	static public inline final DEATH:Int 		= 4;  // Playing the death animation (still transitioning, not yet a "corpse").
	static public inline final DEAD:Int 		= 5;  // Death animation finished; the actor is now a static corpse.
	
	// --- Strike states (used by StrikeLine only) ---
	static public inline final GROW:Int			= 0;  // The strike effect is scaling up from 0 to full size.
	static public inline final SHRINK:Int		= 1;  // The strike effect is scaling back down before it's removed.
	
	// --- Game states (used by GameState) ---
	static public inline final INTRO:Int 		= 0;  // Title/credits screen, waiting for the player to click to start.
	static public inline final PLAY:Int 		= 1;  // Gameplay is running.
	static public inline final GAME_OVER:Int 	= 2;  // Player has died; showing the game over screen.
	static public inline final RESET:Int 		= 3;  // Transitional state while the game is being cleared and set up again (currently unused in code, but reserved here alongside INTRO/PLAY/GAME_OVER).
}
