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

import flixel.FlxSprite;
import game.GameState;
import game.util.Audio;
import game.util.State;
import game.util.Type;
import openfl.display.BitmapData;
import openfl.filters.ColorMatrixFilter;
import openfl.geom.Point;

/**
 * An enemy ninja: AI-controlled (as opposed to Player, which follows the mouse).
 * Comes in two variants selected by `type` (see Type.SWORD / Type.BOW below):
 * sword ninjas close to melee range and lunge; bow ninjas keep their distance
 * and fire arrows. Both share the same state machine (RUN, CHARGE, ATTACK,
 * COOLDOWN, DEATH, DEAD), unlike Player, which never uses CHARGE.
 */
class Ninja extends Actor
{
	final ANIM_SWITCH_THRESHOLD:Int = 2; 	// small dead-zone (compared as squared) so idle/run animation doesn't flicker from tiny leftover velocity as friction decays it toward zero

	// asset/animData/animFrameRate/spriteWidth/spriteHeight below are all parallel
	// arrays indexed by `type` (Type.SWORD = 0, Type.BOW = 1 - see Type.hx). Keep
	// their entries in that same order if you ever add a third ninja variant.
	static var asset:Array<String> = [
								  "assets/images/black-ninja-sword.png",
								  "assets/images/black-ninja-bow.png"
							  ];

	// Animation data for different directions.
	// Note: the Sword and Bow sub-arrays below are byte-for-byte identical (same
	// frame indices, same order) even though they're written out twice. That's
	// not a mistake to "fix" by itself - it just means both ninja spritesheets
	// happen to be laid out with matching frame positions, so the same
	// animData/animFrameRate values work for both, despite having different
	// source images and sprite dimensions (see spriteWidth/spriteHeight below).
	static var animData:Array<Array<Array<Array<Int>>>> = [
				[
					// Sword Ninja animation frames
					[[0], 	[1, 2, 3, 4], 		[7], 	[8, 9], 	[30],	[31], 	[5, 6]], 	//  side animation frames
					[[10], 	[11, 12, 13, 14], 	[17], 	[18, 19], 	[30],	[31],	[15, 16]], 	// front animation frames
					[[20], 	[21, 22, 23, 24], 	[27], 	[28, 29], 	[30],	[31],	[25, 26]]	//  back animation frames
				],
				[
					// Bow Ninja animation frames
					[[0], 	[1, 2, 3, 4], 		[7], 	[8, 9], 	[30],	[31], 	[5, 6]], 	//  side animation frames
					[[10], 	[11, 12, 13, 14], 	[17], 	[18, 19], 	[30],	[31],	[15, 16]], 	// front animation frames
					[[20], 	[21, 22, 23, 24], 	[27], 	[28, 29], 	[30],	[31],	[25, 26]]	//  back animation frames
				]
			];

	// Animation frame rate data for different directions
	static var animFrameRate:Array<Array<Array<Int>>>	= [
				[
					// Sword Ninja animation frame rates
					[1, 5, 1, 1, 1, 1, 15], 	//  side animation frame rates
					[1, 5, 1, 1, 1, 1, 15], 	// front animation frame rates
					[1, 5, 1, 1, 1, 1, 15]	//  back animation frame rates
				],
				[
					// Bow Ninja animation frame rates
					[1, 5, 1, 1, 1, 1, 15], 	//  side animation frame rates
					[1, 5, 1, 1, 1, 1, 15], 	// front animation frame rates
					[1, 5, 1, 1, 1, 1, 15]	//  back animation frame rates
				]
			];

	// Width of the sprites for each ninja type
	static var spriteWidth: Array<Int> = [91, 84];

	// Height of the sprites for each ninja type
	static var spriteHeight: Array<Int> = [64, 60];

	// Cache of the fully-filtered shadow bitmap, computed once per ninja type
	// (Type.SWORD/Type.BOW) instead of re-running the expensive per-pixel
	// ColorMatrixFilter on every single ninja spawn. See bakeNinja() below.
	static var filteredShadowCache:Array<BitmapData> = [null, null];

	/**
	* The type of the ninja.
	* Possible values:
	*   - Type.SWORD: Sword Ninja
	*   - Type.BOW: Bow Ninja
	*
	* Note: `Type` here refers to `game.util.Type` (imported above), NOT Haxe's own
	* built-in `Type` class (the reflection one, usable without import in any file).
	* The explicit `import game.util.Type;` at the top of this file shadows the
	* built-in one for the rest of Ninja.hx - if this file ever needs Haxe's
	* reflection `Type`, it can't be referred to by its plain name here.
	*/
	var type: Int;
	
	// which type this instance's sprites are currently baked as (-1 = never baked yet)
	var bakedType:Int = -1; 

	// The current charge timer for the ninja before attacking
	var chargeTimer: Float;

	// The duration of the ninja's charging
	var chargeLength: Float;

	// AI engage distances (how close the player must get before this ninja starts
	// charging an attack) - NOT the same as Actor's `meleeHitRadius`, which is the
	// actual hit-detection radius used once attacking. See meleeHitRadius's field doc
	// in Actor.hx for the full distinction.
	var meleeEngageRange: Int;	// engage distance for Sword ninjas

	var rangedEngageRange: Int;	// engage distance for Bow ninjas
	
	var id:Int;
	/**
	* Creates a new instance of an enemy ninja.
	*
	* @param game The parent GameState instance that manages the game (FlxState).
	*/
	public function new(game:GameState):Void
	{
		super(game);

		// Add the ninja's sprite and shadow to their corresponding groups in the parent game instance
		game.actors.add(actor);
		game.shadows.add(shadow);

		// Set initial visibility of actor and shadow to false
		actor.visible = false;
		shadow.visible = false;

		// Flip the shadow vertically to mirror the ninja's sprite
		shadow.flipY = true;

	}

	/**
	 * ---------------------------------------------
	 *
	 *		INITIALIZE-DEINITIALIZE FUNCTIONS
	 *
	 * ---------------------------------------------
	 */

	/**
	* Initializes the Ninja with the specified type and sets its initial properties.
	* @param type The type of the Ninja (optional, default value is 0  which corresponds to Type.SWORD)
	*/
	override public function initialize(type:Int = 0):Void
	{
		super.initialize();

		this.type = type;

		// "bake" the ninja animations
		bakeNinja(type);

		// Set initial values for movement and attack parameters.
		// Three different "distance" concepts get set here - see the field docs
		// above/in Actor.hx if the names are confusing:
		//   meleeHitRadius  = 20  -> hit-detection radius (overrides Actor's default of 30)
		//   meleeEngageRange  = 100 -> Sword ninja's AI engage distance
		//   rangedEngageRange = 300 -> Bow ninja's AI engage distance
		speed = 50;
		meleeHitRadius = 20;
		meleeEngageRange = 100;
		rangedEngageRange = 300;
		attackSpeed = 500;
		attackTimer = 0;
		attackLength = 0.3;
		chargeLength = 1;
		chargeTimer = 1;
		cooldownLength = 1;
		cooldownTimer = .5;

		// Set the initial state of the ninja character to running
		state = State.RUN;

		// Set a random initial position of the ninja
		actor.x = Math.random() * 500 + 100;
		actor.y = Math.random() * 400 + 100;

		// Revive (Flixel's own exists/alive flags) in case this instance is being
		// reused from the pool (see Ninja.deInitialize(), which calls kill() on
		// both sprites) - a freshly-constructed sprite defaults to exists=true, so
		// this was never needed before pooling existed, but a killed sprite stays
		// exists=false forever without an explicit revive().
		actor.revive();
		shadow.revive();

		// Make the ninja character and shadow visible, flag his as alive
		actor.visible = true;
		shadow.visible = true;
		alive = true;

		// Update the ninja position
		updatePosition();

		// Generate smoke particles around the ninja character
		var count:Int = 0;
		while (count < 8)
		{
			game.addSmoke(x, y);
			count++;
		}

		// Play the sound effect for ninja character appearing
		Audio.playAppear();
	}

	/**
	* Perform cleanup tasks when the Ninja is being deinitialized.
	*/
	override function deInitialize():Void
	{
		super.deInitialize();

		
		// Clear any pending onFinish listener the moment this life ends - see the
    	// note in hit() for why this can't wait until the NEXT hit() call.
    	actor.animation.onFinish.removeAll();

		actor.kill();
		shadow.kill();
	}

	/**
	 * ---------------------------------------------
	 *
	 *  			PUBLIC FUNCTIONS
	 *
	 * ---------------------------------------------
	 */

	/**
	 * Warms up the per-type shadow filter cache (see filteredShadowCache above)
	 * without spawning a real, visible gameplay ninja - a throwaway FlxSprite
	 * is used purely to load the shadow spritesheet and run the filter once,
	 * then discarded. Meant to be called once per type during loading (see
	 * GameState.create()), so the one-time hitch happens before the player
	 * ever sees gameplay, instead of mid-fight on the first real spawn.
	 */
	static public function preBakeShadow(type:Int):Void
	{
		if (filteredShadowCache[type] != null) return; // already baked

		var temp = new FlxSprite();
		temp.loadGraphic(asset[type], true, spriteWidth[type], spriteHeight[type], true);
		temp.pixels.applyFilter(temp.pixels, temp.pixels.rect, new Point(), new ColorMatrixFilter(Actor.shadowColorMatrixFilter));
		filteredShadowCache[type] = temp.pixels.clone();
		temp.destroy();
	}
	/**
	* Updates the ninja's state and behavior.
	*
	* Note: case labels below are raw ints matching the State.* constants
	* (see State.hx) - written as literals here for brevity, named in each
	* case's comment. Unlike Player, DEAD here calls `killActor()` (stamps the
	* corpse onto the background and removes this ninja) rather than ending
	* the game.
	*
	* @param elapsed The time elapsed since the last update.
	*/
	override public function update(elapsed:Float):Void
	{
		// Handle different ninja states
		switch (state)
		{
			case 0: // RUN
				updateRunState(elapsed);

			case 1: //CHARGE
				updateChargeState(elapsed);

			case 2: //ATTACK
				updateAttackState(elapsed);

			case 3: // COOLDOWN
				updateCooldownState(elapsed);

			case 4: //DEATH
				updateDeathState();

			case 5: // DEAD
				killActor();

			default: throw("*** Error : Ninja has no active state");
		}

		super.update(elapsed);
	}

	/**
	* Handles the ninja being hit to death.
	*/
	public function hit():Void
	{
		 
		// update the ninja's state and alive flag
		state = State.DEATH;
		alive = false;

		// Play death animation for the ninja and shadow
		actor.animation.play(animNames[animFacingIndex][ANIM_DEATH], true);
		shadow.animation.play(animNames[animFacingIndex][ANIM_DEATH]);

		// Clear any listener from a previous life before registering a fresh one.
		// Currently a no-op (each ninja is destroyed after one death today - see
		// deInitialize()), but onFinish is a persistent signal that's only ever
		// cleared when the whole sprite is destroyed. Without this guard, reusing
		// this same instance in the future (pooling) would let listeners from
		// every previous death stack up here, all firing together on the next one.
		actor.animation.onFinish.removeAll();

		// Callback function to handle the logic when death animation ends
		actor.animation.onFinish.add(function(s:String):Void
		{
			actor.animation.stop();
			updatePosition();
			if (vector.x < 0) actor.flipX = true;

			actor.animation.play(animNames[animFacingIndex][DEAD_ANIM]);
			shadow.animation.play(animNames[animFacingIndex][DEAD_ANIM]);
			state = State.DEAD;
		});

		// Add a strike effect at the ninja's position
		game.addStrike(actor.x, actor.y);

		// Play audio effect
		Audio.playSlash();
	}

	/**
	 * ---------------------------------------------
	 *
	 * 			PRIVATE STATE FUNCTIONS
	 *
	 * ---------------------------------------------
	 */

	/**
	* Updates the ninja's behavior during the RUN state.
	*
	* Note: `distance` here holds the SQUARED distance (dx*dx + dy*dy), not
	* the actual distance - both comparisons below (meleeEngageRange, rangedEngageRange)
	* square their threshold to match, avoiding an unnecessary sqrt() since
	* only threshold checks are needed here, never the real distance value.
	*
	* @param elapsed The elapsed time since the last update.
	*/
	function updateRunState(elapsed:Float):Void
	{
		// Calculate the distance between player and ninja
		var dx:Float = game.player.x - actor.x;
		var dy:Float = game.player.y - actor.y;
		var distance:Float = dx * dx + dy * dy;

		// Check if the Ninja is a Sword Ninja and if the player is within melee range
		if (type == Type.SWORD && distance < meleeEngageRange * meleeEngageRange)
		{
			// If the player is alive, charge for melee attack
			if (game.player.alive)
				chargeMeleeAttack();
			else
			{
				// if the player is dead set the ninja animation to idle
				actor.animation.play(animNames[animFacingIndex][ANIM_IDLE]);
				shadow.animation.play(animNames[animFacingIndex][ANIM_IDLE]);
			}
			return;
		}

		// Check if the Ninja is a Bow Ninja and if the player is within the bow range
		if (this.type == Type.BOW && distance < rangedEngageRange * rangedEngageRange)
		{
			// If the player is alive, charge for ranged attack
			if (game.player.alive)
				chargeRangedAttack();
			else
			{
				// if the player is dead set the ninja animation to idle
				actor.animation.play(animNames[animFacingIndex][ANIM_IDLE]);
				shadow.animation.play(animNames[animFacingIndex][ANIM_IDLE]);

			}
			return;
		}

		// Calculate the angle between player and ninja
		angle = Math.atan2(dy, dx);
		vector.x += Math.cos(angle) * speed * elapsed;
		vector.y += Math.sin(angle) * speed * elapsed;

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
	* Updates the ninja during the CHARGE state. Neither ninja type moves
	* during charge, but Bow ninjas continuously re-aim toward the player
	* (via facingRanged() below) in case the player moves before the shot
	* fires; Sword ninjas only set their facing once, when the charge starts
	* (see chargeMeleeAttack()). This only affects which way the ninja LOOKS
	* while charging - the actual lunge/arrow direction in attack()/shoot()
	* below is always recalculated fresh from the player's position at the
	* moment the charge finishes, for both types.
	*
	* @param elapsed The elapsed time since the last update.
	*/
	function updateChargeState(elapsed:Float):Void
	{
		chargeTimer -= elapsed;

		// Check if the chargeTimer timer has expired...
		if (chargeTimer <= 0)
		{
			//...and attack!
			attack();
			return;
		}

		// Determine the facing of the bow ninja
		if (type == Type.BOW)
			facingRanged(game.player);

		// Play charge animation
		actor.animation.play(animNames[animFacingIndex][ANIM_CHARGE]);
		shadow.animation.play(animNames[animFacingIndex][ANIM_CHARGE]);
	}

	/**
	* Updates the ninja during the ATTACK state.
	*
	* @param elapsed The elapsed time since the last update.
	*/
	function updateAttackState(elapsed:Float):Void
	{
		attackTimer -= elapsed;

		// Check if the attackTimer timer has expired
		if (attackTimer <= 0)
		{
			// Switch to COOLDOWN state and set the COOLDOWN timer
			state = State.COOLDOWN;
			cooldownTimer = cooldownLength;
			return;
		}

		// Calculate the displacement based on the attack angle and speed
		vector.x = Math.cos(angle) * attackSpeed * elapsed;
		vector.y = Math.sin(angle) * attackSpeed * elapsed;

		// Update the ninja's position
		actor.x += vector.x;
		actor.y += vector.y;

		// Determine the player's facing direction
		facing();

		// Check if the player is killed by the attack
		checkForKills();

		// Update the ninja's animation during the ATTACK state
		actor.animation.play(animNames[animFacingIndex][ANIM_ATTACK]);
		shadow.animation.play(animNames[animFacingIndex][ANIM_ATTACK]);
	}

	/**
	* Updates the COOLDOWN state for the player.
	* @param elapsed The elapsed time since the last update.
	*/
	function updateCooldownState(elapsed:Float):Void
	{
		cooldownTimer -= elapsed;
		// If cooldown timer is complete, transition back to RUN state
		if (cooldownTimer <= 0)	state = State.RUN;

		// Apply friction to the vector values to gradually reduce movement
		vector.x *= friction;
		vector.y *= friction;

		// Update the position of the ninja based on the modified vector
		actor.x += vector.x;
		actor.y += vector.y;
	}

	/**
	* Updates the DEATH state for the ninja.
	*/
	function updateDeathState():Void
	{
		// Apply friction to the vector values to gradually reduce movement
		vector.x *= friction;
		vector.y *= friction;

		// Update the position of the ninja based on the modified vector
		actor.x += vector.x;
		actor.y += vector.y;

		// Add blood effect at the player's position
		game.addBlood(actor.x, actor.y);

		// The rest of death handling is in the death animation callback code
	}

	/**
	 * ---------------------------------------------
	 *
	 * 				PRIVATE FUNCTIONS
	 *
	 * ---------------------------------------------
	 */

	/**
	* Initiates the charging of a melee attack.
	*/
	function chargeMeleeAttack():Void
	{
		// Set the state to Charge and initialize the chargeTimer.
		state = State.CHARGE;
		chargeTimer = chargeLength;

		// update the facing of the ninja
		facing();
	}

	/**
	* Initiates the charging of a bow attack.
	*/
	function chargeRangedAttack():Void
	{
		// Set the state to Charge and initialize the chargeTimer.
		state = State.CHARGE;
		chargeTimer = chargeLength;

		// Play the appropriate sound
		Audio.playBowPull();
	}

	/**
	* Initiates an attack action for the ninja.
	*/
	function attack():Void
	{
		// If not in the charging state, exit the function
		if (state != State.CHARGE) return;

		// If the ninja is bow ninja, shoot the arrow and exit the function
		if (type == Type.BOW)
		{
			shoot();

			return;
		}

		// Calculate the horizontal and vertical distance between the player and the object
		var offsetX:Float = game.player.x - actor.x;
		var offsetY:Float = game.player.y - actor.y;

		// Calculate the angle between the object and the player
		angle = Math.atan2(offsetY, offsetX);

		// Set the timer
		attackTimer = attackLength;

		// Set the state to attack
		state = State.ATTACK;

		// Play the dash sound
		Audio.playDash();
	}

	/**
	* Initiates the shoot arrow action for the Ninja.
	*
	* Sets the state to Cooldown and initializes the cooldownTimer.
	*/
	function shoot():Void
	{
		// Calculate the angle towards the player and shoot the arrow.
		var dx:Float = game.player.x - actor.x;
		var dy:Float = game.player.y - actor.y;
		angle = Math.atan2(dy, dx);
		game.addArrow(angle, actor.x, actor.y);

		// Switch to COOLDOWN state and set the COOLDOWN timer
		state = State.COOLDOWN;
		cooldownTimer = cooldownLength;

		// Play the attack animation
		actor.animation.play(animNames[animFacingIndex][ANIM_ATTACK]);
		shadow.animation.play(animNames[animFacingIndex][ANIM_ATTACK]);

		// Play the appropriate sound
		Audio.playBowFire();
	}

	/**
	* Checks if this ninja kills the player within its attack path.
	*
	* Only ever called from `updateAttackState()` below, which only Sword
	* ninjas reach (Bow ninjas shortcut from CHARGE straight to COOLDOWN via
	* `shoot()`, without ever setting state = State.ATTACK) - hence the
	* hardcoded "sword" debug label below is always accurate here, not an
	* assumption.
	*/
	function checkForKills():Void
	{
		// Check for kill only if the player is alive
		if (!game.player.alive) return;

		// Calculate the squared distance between the ninja and the player
		var dx:Float = game.player.x - x;
		var dy:Float = game.player.y - y;
		var distance:Float = dx * dx + dy * dy;

		// if the player is within the ninja's melee hit radius
		if (distance < meleeHitRadius * meleeHitRadius)
		{
			// but if the player is attacking the ninja is killed
			if (game.player.state == State.ATTACK) hit();
			// else the player is killed
			else game.player.hit("sword"); // debug hint "player killed by"
		}
	}

	/**
	 * Cleans up the ninja's actor and shadow sprites after it got killed.
	 */
	function killActor():Void
	{

		// For performance, "stamp" the dead body and its shadow onto the
		// background image (a static bitmap) instead of keeping them as live
		// sprites - see Background.hx for why. Offsets (-36/-28 and -36/+8)
		// undo this sprite's own offset/anchor so the stamp lands in the right
		// screen position.
		game.bg.stamp(actor, Std.int(actor.x) - 36, Std.int(actor.y) - 28);
		game.bg.stamp(shadow, Std.int(shadow.x) - 36, Std.int(shadow.y) + 8);

		// remove and destroy the sprites
		deInitialize();
	}

	/**
	* Bakes the animations for the Ninja based on his specified type.
	* @param type The type of the Ninja (Type.SWORD or Type.BOW)
	*/
	function bakeNinja(type:Int):Void
	{
		// "bake" the ninja and adjust his offset
		bakeAnimations(actor, asset[type], true, spriteWidth[type], spriteHeight[type], false, animData[type], animFrameRate[type]);
		actor.offset.set(36, 28);

		// "bake" the ninja's shadow, adjust its offset
		bakeAnimations(shadow, asset[type], true, spriteWidth[type], spriteHeight[type], true, animData[type], animFrameRate[type]);
		shadow.offset.set(36, -8);

		// scale the shadow sprite to look like a real shadow
		shadow.scale.y = 0.5;

		if (filteredShadowCache[type] == null)
		{
			// First ninja of this type this session: run the (expensive, especially
			// on native/neko targets) per-pixel color filter once, then cache the
			// result so every subsequent ninja of the same type can skip it.
			shadow.pixels.applyFilter(shadow.pixels, shadow.pixels.rect, new Point(), new ColorMatrixFilter(Actor.shadowColorMatrixFilter));
			filteredShadowCache[type] = shadow.pixels.clone();
		}
		else
		{
			// Already computed for this type: copy the cached, pre-filtered pixels
			// directly (a fast raw memory copy) instead of re-running the filter.
			shadow.pixels.copyPixels(filteredShadowCache[type], filteredShadowCache[type].rect, new Point());
		}
	}
}

