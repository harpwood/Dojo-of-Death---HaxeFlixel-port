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
 * Utility class for defining game states, strike states and actor states.
 */

class State 
{
	static public inline final NO_STATE:Int = -1;
	
	// Actor states
	static public inline final RUN:Int 			= 0;  // Represents the running state of an actor.
	static public inline final CHARGE:Int 		= 1;  // Represents the charging state of an actor.
	static public inline final ATTACK:Int 		= 2;  // Represents the attacking state of an actor.
	static public inline final COOLDOWN:Int 	= 3;  // Represents the cooldown state of an actor.
	static public inline final DEATH:Int 		= 4;  // Represents the death state of an actor.
	static public inline final DEAD:Int 		= 5;  // Represents the dead state of an actor.
	
	// Strike states
	static public inline final GROW:Int			= 0;  // Represents the growing state of a strike.
	static public inline final SHRINK:Int		= 1;  // Represents the shrinking state of a strike.
	
	// Game states
	static public inline final INTRO:Int 		= 0;  // Represents the introduction state of the game.
	static public inline final PLAY:Int 		= 1;  // Represents the playing state of the game.
	static public inline final GAME_OVER:Int 	= 2;  // Represents the game over state of the game.
	static public inline final RESET:Int 		= 3;  // Represents the reset state of the game.
}
