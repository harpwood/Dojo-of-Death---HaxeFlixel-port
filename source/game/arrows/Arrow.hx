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
package game.arrows;

import flixel.FlxSprite;
import flixel.math.FlxAngle;
import flixel.system.FlxAssets.FlxGraphicAsset;
import game.util.Audio;
import game.GameState;
import game.util.ArrowSplitDirection;
import game.util.GEA;
import game.util.State;

/**
 * A bow ninja's arrow projectile. Same pooling pattern as `Blood`
 * (see Blood.hx's class doc). Flies in a straight line and checks for a
 * collision with the Player each frame.
 */
class Arrow extends FlxSprite
{
	var game:GameState; 	// The parent FlxState instance reference
	var arrowAngle:Float; 	// The angle of the arrow
	var arrowSpeed:Int;		// The speed of the arrow
	
	public var isActive(default, null):Bool; // Flag indicating if the arrow is currently being used

	/**
	 * Creates a new Arrow instance.
	 *
	 * @param game 			The parent GameState instance that manages the game (FlxState).
	 * @param X 			The initial x-coordinate of the arrow.
	 * @param Y				The initial y-coordinate of the arrow.
	 * @param SimpleGraphic The graphic asset for the arrow.
	 */
	public function new(game:GameState, ?X:Float = 0, ?Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset)
	{
		super(X, Y, SimpleGraphic);
		this.game = game;

		// Load the graphic for the arrow
		loadGraphic("assets/images/arrow.png", false, 60, 4);
		
		// Set the offset and origin for the arrow
		offset.set(20, -8);
		centerOrigin();
		
		// Define the arrow speed
		arrowSpeed = 500;

		// Deinitialize the arrow and add it to the arrows pool
		deInitialize();
		game.arrows.add(this);
	}

	/**
	 * Initializes the arrow with the specified angle and position.
	 *
	 * @param arrowAngle 	The angle of the arrow.
	 * @param X 			The x-coordinate of the arrow.
	 * @param Y 			The y-coordinate of the arrow.
	 */
	public function initialize(arrowAngle:Float, X:Float, Y:Float)
	{
		// Revive the arrow to make it visible and usable
		revive();

		// Set the angle and position of the arrow
		this.arrowAngle = arrowAngle;
		angle = FlxAngle.asDegrees(arrowAngle);
		x = X;
		y = Y;

		// Mark the arrow that is being used
		isActive = true;
	}

	/**
	 * Deactivates the arrow. It can be reused anytime.
	 */
	function deInitialize():Void
	{
		isActive = false;
		kill();
	}

	/**
	 * Updates the arrow's position and handles collisions.
	 *
	 * @param elapsed The time elapsed since the last update.
	 */
	override public function update(elapsed:Float):Void
	{
		// Move the arrow based on its angle and speed as the time passes
		x += Math.cos(arrowAngle) * arrowSpeed * elapsed;
		y += Math.sin(arrowAngle) * arrowSpeed * elapsed;

		// Check collision with the player and if the player is alive.
		// Comparing squared distance against 20*20 avoids an expensive sqrt()
		// call, since we only need a threshold check here (see Player.updateThrust()
		// for the one place in this codebase where the actual distance value IS
		// needed, e.g. as a loop bound - not just a threshold comparison).
		var dx:Float = this.x - game.player.x;
		var dy:Float = this.y - game.player.y;
		if (dx * dx + dy * dy < 20 * 20 && game.player.alive)
		{
			// 20px here is the arrow's own hit-radius against the player -
			// unrelated to Actor.meleeHitRadius, which only applies to melee weapons.
			//
			// Parry window: the player can deflect the arrow not just while
			// actively ATTACK-ing, but also during the brief COOLDOWN right
			// after - the sword is still effectively "up" during that recovery,
			// so an incoming arrow gets knocked away instead of landing a hit.
			if (game.player.state == State.ATTACK || game.player.state == State.COOLDOWN)
			{
				// If the player is attacking or in cooldown state, break the arrow and deinitialize it
				game.addArrowBroken(ArrowSplitDirection.LEFT, x, y);
				game.addArrowBroken(ArrowSplitDirection.RIGHT, x, y);
				deInitialize();
				
				// Play the appropriate sound
				Audio.playBowHit();
			}
			else
			{
				// Otherwise, the player gets hit by the arrow
				deInitialize();
				game.player.hit("arrow");
			}
		}

		// Check if the arrow is outside the screen
		if (GEA.isNotWithinScreen(x, y))
		{
			// Deinitialize the arrow if it's outside the screen
			deInitialize();
			
			// Play the appropriate sound
			Audio.playBowHit();
		}

		super.update(elapsed);
	}

}
