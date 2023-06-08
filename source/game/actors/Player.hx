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

package game.actors;

import flixel.FlxG;
import flixel.math.FlxPoint;
import game.GameState;
import game.actors.Actor;
import game.actors.Ninja;
import game.fx.Line;
import game.util.Audio;
import game.util.State;
import openfl.filters.ColorMatrixFilter;
import openfl.geom.Point;

/**
 * Represents the player character in the game
 */
class Player extends Actor
{

	var mouse:FlxPoint; 		// The position of the mouse in the game world
	var thrustPoint:FlxPoint; 	// The point used for thrust calculations during attack
	var line:Line;				// The line used for visual effects when the player is thrusting

	/**
	* The previous X and Y position of the player character at the start of an attack.
	* The line will be drawn from (lastActorX, lastActorY) to (actor.x, actor.y) while the player is attacking.
	*/
	var lastActorX:Float;
	var lastActorY:Float;

	var footstepLength:Float; 	// The duration between each step of the player character to play the footstep audio
	var footstepTimer:Float; 	// The remaining time until the next footstep audio is played

	/**
	* Creates a new instance of the Player class.
	*
	* @param game The parent GameState instance that manages the game (FlxState).
	*/
	public function new(game:GameState):Void
	{
		super(game);

		this.game = game;

		// Prepare the sprite and animations for "baking"
		var asset:String = "assets/images/white-ninja.png"; // The player asset

		// Animation data for different directions
		var animData:Array<Array<Array<Int>>> = [
			[[0], 	[1, 2, 3, 4], 		[5], 	[6, 7], 	[24],	[25], 	[0]], //  side animation frames
			[[8], 	[9, 10, 11, 12], 	[13], 	[14, 15], 	[24],	[25],	[0]], // front animation frames
			[[16], 	[17, 18, 19, 20], 	[21], 	[22, 23], 	[24],	[25],	[0]]  //  back animation frames
		];

		// Animation frame rate data for different directions
		var animFrameRate:Array<Array<Int>>	= [
			[1, 5, 1, 1, 1, 1, 1], 	//  side animation frame rates
			[1, 5, 1, 1, 1, 1, 1], 	// front animation frame rates
			[1, 5, 1, 1, 1, 1, 1]	//  back animation frame rates
		];

		// "bake" the player and adjust his offset
		bakeAnimations(actor, asset, true, 91, 64, false, animData, animFrameRate);
		actor.offset.set(36, 28);

		// "bake" the player's shadow, adjust its offset
		bakeAnimations(shadow, asset, true, 91, 64, true, animData, animFrameRate);
		shadow.offset.set(36, -10);

		// scale the shadow sprite to look like a real shadow
		shadow.scale.y = 0.5;

		// Flip the shadow vertically to mirror the player's sprite
		shadow.flipY = true;

		// Apply a semi-transparent black color to the shadow
		shadow.pixels.applyFilter(shadow.pixels, shadow.pixels.rect, new Point(), new ColorMatrixFilter(shadowColorMatrixFilter));

		// Initialize the FlxPoint to store mouse data
		mouse = new FlxPoint(-1, -1);

		// Initialize the FlxPoint to store thrust attack data
		thrustPoint = new FlxPoint(0, 0);

		// Set the initial value for the player's direction angle
		angle = 0;

		// Initialize the line used for visual effects when the player is thrusting
		line = new Line();
		game.add(line);

		// Add the player's sprite and shadow to their corresponding groups in the parent game instance
		game.actors.add(actor);
		game.shadows.add(shadow);

		// Set initial visibility of actor and shadow to false
		actor.visible = false;
		shadow.visible = false;
	}

	/**
	 * ---------------------------------------------
	 *
	 *		INITIALIZE-DEINITIALIZE FUNCTIONS
	 *
	 * ---------------------------------------------
	 */

	/**
	* Initializes the player character and sets its initial properties.
	* @param type The type of initialization (optional, default value is 0).
	*
	* @note The inherited `type` parameter is not used by the Player class,
	* but it can potentially be used for skinning the player with different sprites.
	*/
	override public function initialize(type:Int = 0):Void
	{
		super.initialize();

		// Stops current animation and resets its frame index to zero.
		actor.animation.reset();

		// Set initial values for movement and attack parameters
		speed = 100;
		attackSpeed = 2000;
		attackLength = 0.075;
		cooldownLength = 0.3;

		// Set the initial state of the player character to running
		state = State.RUN;

		// Set the initial position of the player character to the center of the screen
		actor.x = FlxG.width * .5;
		actor.y = FlxG.height * .5;

		// Make the player character and shadow visible, flag his as alive
		actor.visible = true;
		shadow.visible = true;
		alive = true;

		// Set the initial animation for the player character and shadow to idle
		actor.animation.play(ANIM_SIDE_IDLE);
		shadow.animation.play(ANIM_SIDE_IDLE);

		// Set the parameters for footstep sound timing
		footstepLength = 0.24;
		footstepTimer = 0;

		// Update the player position
		updatePosition();

		// Generate smoke particles around the player character
		var count:Int = 0;
		while (count < 8)
		{
			game.addSmoke(x, y);
			count++;
		}

		// Play the sound effect for player character appearing
		Audio.playAppear();
	}
	
	/**
	 * ---------------------------------------------
	 *
	 *  			PUBLIC FUNCTIONS
	 *
	 * ---------------------------------------------
	 */

	/**
	* Updates the player character's state and behavior.
	*
	* @param elapsed The time elapsed since the last update.
	*/
	override public function update(elapsed:Float):Void
	{
		// Update the mouse position
		mouse.x = FlxG.mouse.screenX;
		mouse.y = FlxG.mouse.screenY;

		// Handle different player states
		switch (state)
		{
			case 0: // RUN
				updateRunState(elapsed);

			case 1: //CHARGE
				throw("*** Error : Player cannot be in Charge state");

			case 2: // ATTACK
				updateAttackState(elapsed);

			case 3: // COOLDOWN
				updateCooldownState(elapsed);

			case 4: // DEATH
				updateDeathState();

			case 5: // DEAD
				// Transition to game over state when the player is dead
				game.setState(State.GAME_OVER);
				state = State.NO_STATE;

			default: throw("*** Error : Player has no active state");
		}

		super.update(elapsed);
	}

	/**
	* Initiates an attack action for the player character.
	*/
	public function attack():Void
	{
		// This function can only be called when the player is in the RUN state
		if (state != State.RUN) return;

		// Calculate the distance between the mouse and player positions per axis
		var dx:Float = mouse.x - actor.x;
		var dy:Float = mouse.y - actor.y;

		// Calculate the attack angle using atan2 function
		angle = Math.atan2(dy, dx);

		// Set the attack timer to its default duration
		attackTimer = attackLength;

		// Get into ATTACK state
		state = State.ATTACK;

		// Prepare the coordinates of the attack
		thrustPoint.x = actor.x;
		thrustPoint.y = actor.y;

		// Store the position of the actor
		lastActorX = thrustPoint.x;
		lastActorY = thrustPoint.y;

		// Prepare the line to be ready for drawing
		line.initialize();

		// Play the dash sound
		Audio.playDash();
	}

	/**
	* Handles the player being hit to death
	* @param by (optional) The source of the hit for debugging purposes
	*/
	public function hit(by:String = ""):Void
	{
		// uncomment the next line for debugging purposes
		//trace("player hit by " + by);

		// update player's state and alive flag
		state = State.DEATH;
		alive = false;

		// Play death animation for the player and shadow
		actor.animation.play(animNames[animFacingIndex][ANIM_DEATH], true);
		shadow.animation.play(animNames[animFacingIndex][ANIM_DEATH]);

		// Add a strike effect at the player's position
		game.addStrike(actor.x, actor.y);

		// Play audio effects
		Audio.playSlash();
		Audio.stopMusic();
		Audio.playDeath();
	}

	/**
	 * ---------------------------------------------
	 *
	 * 			PRIVATE STATE FUNCTIONS
	 *
	 * ---------------------------------------------
	 */

	/**
	* Updates the player's behavior during the RUN state.
	*
	* @param elapsed The elapsed time since the last update.
	*/
	function updateRunState(elapsed:Float):Void
	{
		// If the mouse is outside the valid area, play idle animations and exit the function
		if (mouse.x < 1 || mouse.x > FlxG.width - 5 || mouse.y < 1 || mouse.y > FlxG.height - 5)
		{
			actor.animation.play(animNames[animFacingIndex][ANIM_IDLE]);
			shadow.animation.play(animNames[animFacingIndex][ANIM_IDLE]);
			return;
		}

		// Calculate the distance and the angle between player and mouse position
		var dx:Float = mouse.x - actor.x;
		var dy:Float = mouse.y - actor.y;
		var distance:Float = Math.sqrt(dx * dx + dy * dy);
		angle = Math.atan2(dy, dx);

		// Apply movement if the distance between the mouse and the player is big enough
		if (distance > 55)
		{
			// Calculate the horizontal and vertical components of the movement vector based on the angle and speed
			vector.x += Math.cos(angle) * speed * elapsed;
			vector.y += Math.sin(angle) * speed * elapsed;

			// Update the footstep timer to play footstep audio at regular intervals
			footstepTimer -= elapsed;
			if (footstepTimer <= 0)
			{
				footstepTimer = footstepLength;
				Audio.playFootStep();
			}
		}

		// Apply friction to the actor's movement
		vector.x *= friction;
		vector.y *= friction;

		// Update the actor's position
		actor.x += vector.x;
		actor.y += vector.y;

		facing();

		// Determine the movement speed
		var movementSpeed:Float = Math.sqrt(vector.x * vector.x + vector.y * vector.y);

		if (movementSpeed > 2)
		{
			// Play running animation if movement speed is greater than 2
			actor.animation.play(animNames[animFacingIndex][ANIM_RUN]);
			shadow.animation.play(animNames[animFacingIndex][ANIM_RUN]);
		}
		else
		{
			// Play idle animation if movement speed is less than or equal to 2
			actor.animation.play(animNames[animFacingIndex][ANIM_IDLE]);
			shadow.animation.play(animNames[animFacingIndex][ANIM_IDLE]);
		}
	}

	/**
	* Updates the player character during the ATTACK state.
	*
	* @param elapsed The elapsed time since the last update.
	*/
	function updateAttackState(elapsed:Float):Void
	{
		attackTimer -= elapsed;

		// Check if the attackTimer timer has expired
		if (attackTimer <= 0)
		{
			// Fade out the line
			line.deInitialize();

			// Switch to COOLDOWN state and set the COOLDOWN timer
			state = State.COOLDOWN;
			cooldownTimer = cooldownLength;
			return;
		}

		// Calculate the displacement based on the attack angle and speed
		vector.x = Math.cos(angle) * attackSpeed * elapsed;
		vector.y = Math.sin(angle) * attackSpeed * elapsed;

		// Update the player's position
		actor.x += vector.x;
		actor.y += vector.y;

		// Determine the player's facing direction
		facing();

		// Update the player's animation during the ATTACK state
		actor.animation.play(animNames[animFacingIndex][ANIM_ATTACK]);
		shadow.animation.play(animNames[animFacingIndex][ANIM_ATTACK]);

		//Updates the thust effect during player thrust and detects for killing collisions
		updateThrust();
	}

	/**
	* Updates the COOLDOWN state for the player.
	* @param elapsed The elapsed time since the last update.
	*/
	function updateCooldownState(elapsed:Float):Void
	{
		cooldownTimer -= elapsed;

		// If cooldown timer is complete, transition back to RUN state
		if (cooldownTimer <= 0) state = State.RUN;

		// Apply friction to the vector values to gradually reduce movement
		vector.x *= friction;
		vector.y *= friction;

		// Update the position of the player based on the modified vector
		actor.x += vector.x;
		actor.y += vector.y;

		// Updates the thust effect during player thrust and detects for killing collisions
		updateThrust();
	}

	/**
	* Updates the DEATH state for the player.
	*/
	function updateDeathState():Void
	{
		// Apply friction to the vector values to gradually reduce movement
		vector.x *= friction;
		vector.y *= friction;

		// Update the position of the player based on the modified vector
		actor.x += vector.x;
		actor.y += vector.y;

		// Add blood effect at the player's position
		game.addBlood(actor.x, actor.y);

		// Check if the death animation has finished playing
		if (actor.animation.finished)
		{
			actor.animation.stop();
			updatePosition();

			// Flip the player's sprite if moving towards the left
			if (vector.x < 0) actor.flipX = true;

			// Play the dead animation for the player and shadow
			actor.animation.play(animNames[animFacingIndex][DEAD_ANIM]);
			shadow.animation.play(animNames[animFacingIndex][DEAD_ANIM]);

			state = State.DEAD;
		}
	}
	
	/**
	 * ---------------------------------------------
	 *
	 * 				PRIVATE FUNCTIONS
	 *
	 * ---------------------------------------------
	 */
	
	/**
	* Updates the thust effect during player thrust and detects for killing collisions.
	*/
	function updateThrust():Void
	{
		// Define the thrust speed and calculate the distance and thrust angle
		var thrustSpeed:Int = 5;
		var dx:Float = actor.x - thrustPoint.x;
		var dy:Float = actor.y - thrustPoint.y;
		var distance:Float = Math.sqrt(dx * dx + dy * dy);
		angle = Math.atan2(dy, dx);

		// Calculate the offset components based on the angle and thrust speed
		var offsetX:Float = Math.cos(angle) * thrustSpeed;
		var offsetY:Float = Math.sin(angle) * thrustSpeed;

		// If the distance is less than the thrustSpeed speed, there's no need to create more thrust
		if (distance < thrustSpeed) return;

		var steps:Int = 0;
		while (steps < distance)
		{
			// Move the thrust point along the offset
			thrustPoint.x += offsetX;
			thrustPoint.y += offsetY;

			// Draw the effect line at the updated thrust point
			line.drawIt(lastActorX, lastActorY, thrustPoint.x, thrustPoint.y);

			// Kill enemies within the thrust area
			checkForKills();

			// Increment steps by the thrust speed
			steps += thrustSpeed;
		}
	}

	/**
	* Checks for enemy kills within the path of the player thrust.
	*/
	function checkForKills():Void
	{
		// Loop through all enemy ninjas to detect collisions
		var index:Int = game.ninjas.length;
		for (i in 0...index)
		{
			var ninja:Ninja = game.ninjas[i];

			// Exclude the player sprite from collision detection to avoid self-kill
			if (ninja.actor != actor)
			{
				// Check if the ninja is alive before performing collision check
				if (ninja.alive)
				{
					// Calculate the distance between the ninja and the current thrust point
					var dx:Float = ninja.x - thrustPoint.x;
					var dy:Float = ninja.y - thrustPoint.y;
					var distance:Float = Math.sqrt(dx * dx + dy * dy);

					// if the enemy is within the player's melee reach, kill him and update the score
					if (distance < meleeReach)
					{
						ninja.hit();
						game.addScore();

						// uncomment the next line for debugging purposes
						//trace("kill");
					}
				}
			}
		}
	}
}

