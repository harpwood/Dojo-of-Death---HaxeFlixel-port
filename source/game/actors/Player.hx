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
 * The player character: the only actor controlled by mouse input rather than AI.
 * Movement chases the mouse cursor, and attacking performs a fast "thrust" lunge
 * toward the cursor with a visual trail line (see `line`/`thrustPoint`/`lastActorX`
 * below for how that trail and its hit-detection work together).
 */
class Player extends Actor
{

	var mouse:FlxPoint; 					// Mouse position in the game world; the player always moves toward this
	var thrustPoint:FlxPoint; 				// The leading edge of the attack lunge trail (see block comment below)
	var line:Line;							// Draws the visual trail from lastActorX/Y to thrustPoint during an attack
	final CHASE_STOP_DISTANCE:Int = 55; 	// dead-zone radius: player stops accelerating once this close to the mouse
	final ANIM_SWITCH_THRESHOLD:Int = 2; 	// small dead-zone (compared as squared) so idle/run animation doesn't flicker from tiny leftover velocity as friction decays it toward zero
	/**
	* How the thrust attack's three moving parts work together (see `attack()`,
	* `updateThrust()` below):
	*
	* - `lastActorX/Y`: fixed anchor point, set once when the attack starts
	*   (where the lunge began).
	* - `thrustPoint`: the sweep's current leading edge. Each frame in
	*   `updateThrust()`, it advances step by step from its previous position
	*   toward the actor's new (fast-moving) position.
	* - `actor.x/y`: the actual sprite position, which can jump forward a lot in
	*   a single frame since `attackSpeed` is very high (a "lunge").
	*
	* Advancing thrustPoint in small steps (rather than jumping straight to
	* actor.x/y) serves two purposes at once: it gives `line` something to draw
	* a continuous trail through, AND it lets `checkForKills()` sample multiple
	* points along the lunge path per frame, so a ninja standing between last
	* frame's position and this frame's position still gets hit (a "swept"
	* hit-check) instead of being skipped over because the lunge moved too fast
	* for a single point-to-point distance check to catch it.
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

		// Prepare the sprite and animations for "baking"
		var asset:String = "assets/images/white-ninja.png"; // The player asset

		// Frame indices per facing row, in ANIM_* order (IDLE, RUN, ATTACK, DEATH,
		// DEAD01, DEAD02, CHARGE - see Actor.hx's ANIM_* constants). Note the last
		// column (CHARGE) is just a placeholder pointing at the idle frame [0]:
		// Player never actually enters State.CHARGE (see update() below, which
		// throws if it ever does), but bakeAnimations() expects every row to have
		// an entry for every slot, so this exists purely to keep the array shape valid.
		var animData:Array<Array<Array<Int>>> = [
			[[0], 	[1, 2, 3, 4], 		[5], 	[6, 7], 	[24],	[25], 	[0]], //  side animation frames
			[[8], 	[9, 10, 11, 12], 	[13], 	[14, 15], 	[24],	[25],	[0]], // front animation frames
			[[16], 	[17, 18, 19, 20], 	[21], 	[22, 23], 	[24],	[25],	[0]]  //  back animation frames
		];

		// Frames-per-second for each of the same slots above.
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
	* Note: the case labels below are raw ints rather than `State.RUN` etc.
	* They're the same values (see `State.hx`) - written as literals here just
	* for switch-case brevity, with the state name given in each case's comment.
	*
	* @param elapsed The time elapsed since the last update.
	*/
	override public function update(elapsed:Float):Void
	{
		// Update the mouse position
        mouse.x = FlxG.mouse.viewX;
        mouse.y = FlxG.mouse.viewY;

		// Handle different player states
		switch (state)
		{
			case 0: // RUN
				updateRunState(elapsed);

			case 1: //CHARGE
				// Player has no charge behavior (see class doc) - reaching this
				// case would mean something set state = State.CHARGE by mistake.
				throw("*** Error : Player cannot be in Charge state");

			case 2: // ATTACK
				updateAttackState(elapsed);

			case 3: // COOLDOWN
				updateCooldownState(elapsed);

			case 4: // DEATH
				updateDeathState();

			case 5: // DEAD
				// The death animation (DEATH state) has finished playing and the
				// corpse pose is showing. This is the one place Player pushes the
				// whole GameState into GAME_OVER; NO_STATE marks this Player
				// instance itself as finished so this switch won't run it again.
				game.setState(State.GAME_OVER);
				state = State.NO_STATE;

			default: throw("*** Error : Player has no active state");
		}

		super.update(elapsed);
	}

	/**
	* Initiates an attack action for the player character: a fast lunge toward
	* the current mouse position. Resets both `thrustPoint` and `lastActorX/Y`
	* to the actor's current position - see the block comment on `lastActorX/Y`
	* above for what these anchor points are used for during the lunge.
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
	* Handles the player being hit to death.
	*
	* @param by Optional debug label for what killed the player - currently
	* passed as "sword" (Ninja.checkForKills, melee) or "arrow" (Arrow.update,
	* projectile). Purely for the commented-out trace below; has no effect on
	* gameplay.
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
		// If the mouse has left (or is right at the edge of) the game window, stop
		// chasing it and just idle. Margins are asymmetric (1px near-left/top vs
		// 5px near-right/bottom) - looks like ad-hoc tuning rather than a
		// deliberate design choice, but kept as-is here.
		if (mouse.x < 1 || mouse.x > FlxG.width - 5 || mouse.y < 1 || mouse.y > FlxG.height - 5)
		{
			actor.animation.play(animNames[animFacingIndex][ANIM_IDLE]);
			shadow.animation.play(animNames[animFacingIndex][ANIM_IDLE]);
			return;
		}

		// Calculate the distance and the angle between player and mouse position
		var dx:Float = mouse.x - actor.x;
		var dy:Float = mouse.y - actor.y;
		var distance:Float = dx * dx + dy * dy;
		angle = Math.atan2(dy, dx);

		// Only accelerate toward the mouse once it's more than 55px away - a dead
		// zone so the player doesn't jitter trying to stand exactly on the cursor.
		if (distance > CHASE_STOP_DISTANCE * CHASE_STOP_DISTANCE)
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

		// Determine the squared movement speed
		var movementSpeed:Float = vector.x * vector.x + vector.y * vector.y;

		// See ANIM_SWITCH_THRESHOLD's field doc above for why this isn't just > 0.
		if (movementSpeed > ANIM_SWITCH_THRESHOLD * ANIM_SWITCH_THRESHOLD)
		{
			actor.animation.play(animNames[animFacingIndex][ANIM_RUN]);
			shadow.animation.play(animNames[animFacingIndex][ANIM_RUN]);
		}
		else
		{
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

		// Continue the thrust sweep/hit-check (see updateThrust() below)
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

		// Lunge still has residual velocity decaying via friction here, so keep
		// sweeping/checking for kills until it fully stops (see updateThrust() below).
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
	* Advances `thrustPoint` toward the actor's current (fast-moving) position
	* in small 5px steps, sampling `checkForKills()` at every step along the way.
	*
	* Why step instead of jumping straight to actor.x/y? Because `attackSpeed`
	* is very high, actor.x/y can move well over 5px in a single frame - a
	* single distance check at the end could miss a ninja standing anywhere in
	* between last frame's position and this one (the lunge would "tunnel"
	* through them). Sampling every 5px along the path closes that gap. As a
	* side effect, it also gives `line` a trail of points to draw through for
	* the visual sword-slash effect (see the block comment on `lastActorX/Y`
	* in the field declarations above).
	*/
	function updateThrust():Void
	{
		var thrustSpeed:Int = 5; // step size in pixels for both the sweep and the trail
		var dx:Float = actor.x - thrustPoint.x;
		var dy:Float = actor.y - thrustPoint.y;
		var distance:Float = Math.sqrt(dx * dx + dy * dy); // how far behind the actor thrustPoint currently is
		angle = Math.atan2(dy, dx);

		var offsetX:Float = Math.cos(angle) * thrustSpeed;
		var offsetY:Float = Math.sin(angle) * thrustSpeed;

		// Already caught up (or very close) - nothing to sweep this frame.
		if (distance < thrustSpeed) return;

		var steps:Int = 0;
		while (steps < distance)
		{
			thrustPoint.x += offsetX;
			thrustPoint.y += offsetY;

			// Redraw the trail from the fixed attack-start anchor to the new leading edge.
			line.drawIt(lastActorX, lastActorY, thrustPoint.x, thrustPoint.y);

			checkForKills(); // hit-check at this step of the sweep

			steps += thrustSpeed;
		}
	}

	/**
	* Checks each alive ninja against the current thrustPoint (see `updateThrust()`
	* above) and kills any within `meleeHitRadius`.
	*/
	function checkForKills():Void
	{
		var index:Int = game.ninjas.length;
		for (i in 0...index)
		{
			var ninja:Ninja = game.ninjas[i];

			// Guards against comparing the player to itself, but as far as this
			// codebase is concerned `game.ninjas` only ever holds Ninja instances
			// (never the Player) - so this condition appears to always be true
			// given the current architecture. Left as a defensive check.
			if (ninja.actor != actor)
			{
				if (ninja.alive)
				{
					var dx:Float = ninja.x - thrustPoint.x;
					var dy:Float = ninja.y - thrustPoint.y;
					var distance:Float = dx * dx + dy * dy;

					if (distance < meleeHitRadius * meleeHitRadius)
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

