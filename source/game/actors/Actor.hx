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
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxDirectionFlags;
import game.GameState;
import game.util.Facing;
import game.util.GEA;
import game.util.State;

/**
 * The base class for all actors in the game.
 * Actors represent entities that can be controlled by the player or the computer.
 * This class serves as the parent class for both players and enemies.
 *
 * Note: Do not confuse the Actor class with the `actor:FlxSprite` variable.
 * The Actor class handles all the base logic, including the `actor` variable.
 * The `actor` variable represents the graphical representation of the Actor class as a FlxSprite.
 */
class Actor
{
	// The parent FlxState instance that contains the Actor
	var game:GameState;			

	/**
	 * Animation slot indices. These aren't just internal labels - they're the exact
	 * second-dimension index used both into `animNames` below AND into the
	 * `animData`/`animFrameRate` arrays that `Player` and `Ninja` build and pass into
	 * `bakeAnimations()`. All three arrays (animNames, animData, animFrameRate) must
	 * keep their entries in this same 0-6 order, or animations will play the wrong
	 * frames. See also `bakeAnimations()` below, which hardcodes `1` and `6`
	 * (== ANIM_RUN and ANIM_CHARGE) to decide which animations loop.
	 */
	final ANIM_IDLE:Int 	= 0;
	final ANIM_RUN:Int 		= 1;
	final ANIM_ATTACK:Int 	= 2;
	final ANIM_DEATH:Int 	= 3;
	final ANIM_DEAD01:Int	= 4;
	final ANIM_DEAD02:Int 	= 5;
	final ANIM_CHARGE:Int 	= 6;

	// side animation names constants
	final ANIM_SIDE_IDLE:String 	= "side_idle";
	final ANIM_SIDE_RUN:String 		= "side_run";
	final ANIM_SIDE_ATTACK:String 	= "side_attack";
	final ANIM_SIDE_DEATH:String 	= "side_death";
	final ANIM_SIDE_DEAD01:String 	= "side_dead01";
	final ANIM_SIDE_DEAD02:String 	= "side_dead02";
	final ANIM_SIDE_CHARGE:String 	= "side_charge";

	// front animation names constants
	final ANIM_FRONT_IDLE:String 	= "front_idle";
	final ANIM_FRONT_RUN:String 	= "front_run";
	final ANIM_FRONT_ATTACK:String 	= "front_attack";
	final ANIM_FRONT_DEATH:String 	= "front_death";
	final ANIM_FRONT_DEAD01:String 	= "front_dead01";
	final ANIM_FRONT_DEAD02:String 	= "front_dead02";
	final ANIM_FRONT_CHARGE:String 	= "front_charge";

	// back animation names constants
	final ANIM_BACK_IDLE:String 	= "back_idle";
	final ANIM_BACK_RUN:String 		= "back_run";
	final ANIM_BACK_ATTACK:String 	= "back_attack";
	final ANIM_BACK_DEATH:String 	= "back_death";
	final ANIM_BACK_DEAD01:String 	= "back_dead01";
	final ANIM_BACK_DEAD02:String 	= "back_dead02";
	final ANIM_BACK_CHARGE:String 	= "back_charge";

	/**
	* `animNames[facingIndex][animSlot]` gives the Flixel animation name to play.
	*
	* - First dimension (facingIndex): which way the actor is facing - use the
	*   `Facing` constants (Facing.SIDE = 0, Facing.FRONT = 1, Facing.BACK = 2).
	* - Second dimension (animSlot): which action - use the ANIM_* constants
	*   above (ANIM_IDLE, ANIM_RUN, etc.).
	*
	* Example: `animNames[Facing.SIDE][ANIM_RUN]` → the side-facing run animation name.
	* Built once in the constructor below; see that array literal for the actual names.
	* Note: for SIDE, the same animation is used for both left and right - the sprite
	* is simply flipped horizontally (see `facing()`), there's no separate "left" entry.
	*/
	var animNames: Array<Array<String>>; 	// Stores the animation names for different facing directions
	var animFacingIndex: Int;				// Current facing (a Facing.* value); selects the first dimension of animNames

	/**
	* Represents the current state of the Actor instance (Player or Ninja).
	*
	* Use the static constants in the State class to access the available states:
	*   - No state: 	State.NO_STATE (set by `deInitialize()`; actor is done and being removed)
	*   - Running: 		State.RUN
	*   - Charging: 	State.CHARGE (Ninja only - Player skips straight to ATTACK)
	*   - Attacking: 	State.ATTACK
	*   - Cooldown: 	State.COOLDOWN
	*   - Death: 		State.DEATH
	*   - Dead: 		State.DEAD
	*
	* Note: `State.INTRO`/`PLAY`/`GAME_OVER`/`RESET` are a *different*, unrelated
	* group of constants used by `GameState.state`, not by this field - see the
	* warning in `State.hx` about the two enumerations sharing integer values.
	*/
	public var state(default, null):Int;

	/**
	 * The `actor` variable holds the FlxSprite object that represents the graphical representation of the actor.
	 * This sprite is responsible for displaying the visual appearance of the actor in the game.
	 */
	public var actor(default, null): FlxSprite;

	/**
	 * The `shadow` variable holds the FlxSprite object that represents the shadow sprite for the actor.
	 * This shadow sprite is used to provide a visual effect of the actor's presence in the game world.
	 * It helps to create depth and visual realism by rendering a shadow beneath the actor.
	 */
	public var shadow(default, null): FlxSprite;

	/**
	* An array of color matrix filter values used to modify the appearance of the shadow.
	* The color matrix filter is applied to the sprite to change its color to black and
	* make it semi-transparent, creating a shadow effect.
	*
	* The `shadowColorMatrixFilter` array contains a set of floating-point values that define
	* the transformation matrix used for the color manipulation. By adjusting the values in the array,
	* you can control the intensity, transparency, and color of the shadow.
	*/
	var shadowColorMatrixFilter: Array<Float>;

	/**
	* The DEAD_ANIM variable stores the index of the randomly chosen DEAD animation sprite.
	* It is used to determine which DEAD animation to display for the actor, providing variety
	* in the appearance of the actor's death animation.
	*/
	var DEAD_ANIM:Int;

	// Private instance properties specific to the Actor class (not related to actor:FlxSprite)
	var vector:FlxPoint;		// The vector representing the actor's movement direction
	var speed:Float;			// The speed of the actor's movement
	var attackSpeed:Float;		// The speed of the attack motion towards the target
	var friction:Float;			// The friction applied to the actor's movement, causing it to gradually slow down
	var attackTimer:Float;		// The time that must elapsed before attacking while charging
	var attackLength:Float;		// The lenght of the time that must elapsed before attacking
	var cooldownTimer:Float;	// The time that must elapse before the actor's cooldown period ends
	var cooldownLength:Float;	// The duration of the cooldown period after an attack
	var meleeReach:Int;			// Hit-detection radius: how close an actor's weapon must be to a target to actually land a hit (checked in Player/Ninja checkForKills()).
									// NOT the same as Ninja's own `meleeRange`/`rangedRange` fields, which are AI engage distances
									// (how close the player must get before a ninja starts charging an attack). Similar names, different purposes.

	// Public instance properties specific to the Actor class (not related to actor:FlxSprite)
	// Note: x/y are NOT computed live - they're a snapshot of actor.x/actor.y taken once per
	// frame by updatePosition(). Prefer reading actor.x/actor.y directly if you need the
	// absolute latest position within the same frame (e.g. right after moving `actor`).
	public var x(default, null):Float;		// The x position of the actor (as of the last updatePosition() call)
	public var y(default, null):Float;		// The y position of the actor (as of the last updatePosition() call)
	public var angle(default, null):Float;	// The angle of direction of the actor
	public var alive(default, null):Bool;	// A flag indicating whether the actor is alive or not

	/**
	* Creates a new instance of the Actor class.
	*
	* @param game The parent GameState instance that manages the game (FlxState).
	*/
	public function new(game:GameState):Void
	{
		this.game = game;

		// Builds the animNames lookup described in its field doc above.
		// Row order (SIDE, FRONT, BACK) must match Facing's constants;
		// column order within each row must match the ANIM_* constants.
		animNames = [
			[
				ANIM_SIDE_IDLE,
				ANIM_SIDE_RUN,
				ANIM_SIDE_ATTACK,
				ANIM_SIDE_DEATH,
				ANIM_SIDE_DEAD01,
				ANIM_SIDE_DEAD02,
				ANIM_SIDE_CHARGE
			],
			[
				ANIM_FRONT_IDLE,
				ANIM_FRONT_RUN,
				ANIM_FRONT_ATTACK,
				ANIM_FRONT_DEATH,
				ANIM_FRONT_DEAD01,
				ANIM_FRONT_DEAD02,
				ANIM_FRONT_CHARGE
			],
			[
				ANIM_BACK_IDLE,
				ANIM_BACK_RUN,
				ANIM_BACK_ATTACK,
				ANIM_BACK_DEATH,
				ANIM_BACK_DEAD01,
				ANIM_BACK_DEAD02,
				ANIM_BACK_CHARGE
			]
		];

		// Default facing is SIDE (see animFacingIndex field doc above for what this means)
		animFacingIndex = Facing.SIDE;

		// Builds the semi-transparent black matrix described in shadowColorMatrixFilter's
		// field doc above: RGB rows all zero (forces black), alpha row set to 0.15.
		var a = 0.15; //alpha
		shadowColorMatrixFilter =  [
			0, 0, 0, 0, 0,
			0, 0, 0, 0, 0,
			0, 0, 0, 0, 0,
			0, 0, 0, a, 0
		];

		actor = new FlxSprite(); 	 // Create a new FlxSprite instance to represent the actor's graphic representation
		shadow = new FlxSprite(); 	 // Create a new FlxSprite instance to represent the shadow sprite for the actor
		vector = new FlxPoint(0, 0); // Create a new FlxPoint instance to store the vector of the actor's movement
		friction = 0.75; 			 // Set the friction value to control the actor's movement speed reduction
		meleeReach = 30; 			 // Default hit-detection radius (see meleeReach field doc above for how this differs from Ninja's meleeRange/rangedRange)
	}
	
	/**
	 * ---------------------------------------------
	 * 
	 *  			PUBLIC FUNCTIONS
	 * 
	 * ---------------------------------------------
	 */

	/**
	* Base initialization shared by every actor (Player and Ninja alike).
	* Currently just picks a random "dead" pose for variety.
	*
	* @param type For `Ninja`, selects SWORD vs BOW (see `Type` class); unused by `Player`.
	*
	* @note Both `Player.initialize()` and `Ninja.initialize()` override this and call
	* `super.initialize()` first, then add their own actor-specific setup on top
	* (position, speed, animations, etc.). This base version alone does not fully
	* set up an actor.
	*/
	public function initialize(type:Int = 0):Void
	{
		// Randomly select one of the dead animation sprites for variety
		DEAD_ANIM = ANIM_DEAD01;
		if (Math.random() <= 0.5)
			DEAD_ANIM = ANIM_DEAD02;
	}

	/**
	* Deinitializes the Actor instance.
	*/
	public function deInitialize():Void
	{
		//hides the actor and shadow sprites, and sets the state to "NO_STATE"
		actor.visible = false;
		shadow.visible = false;
		state = State.NO_STATE;
	}

	/**
	* Updates the Actor instance.
	*
	* @param elapsed The elapsed time since the last update in seconds.
	*/
	public function update(elapsed:Float):Void
	{
		// Update the actor's position based on its current movement vector and boundary constraints
		updatePosition();
	}
	
	/**
	 * ---------------------------------------------
	 * 
	 *  			PRIVATE FUNCTIONS
	 * 
	 * ---------------------------------------------
	 */

	
	/**
	* Updates the position of the Actor instance based on its current movement and boundary constraints.
	* This method is called by the update method to ensure the actor stays within the defined boundaries.
	*/
	function updatePosition():Void
	{
		// If the actor is not within the Game Effective Area, constrain him
		if (GEA.isNotWithin(actor.x, actor.y))
		{
			actor.x = (actor.x < FlxG.width * .5) ? Math.max(GEA.LEFT, actor.x) : Math.min(GEA.RIGHT, actor.x);
			actor.y = (actor.y < FlxG.height * .5) ? Math.max(GEA.TOP, actor.y) : Math.min(GEA.BOTTOM, actor.y);
		}

		// Update the Actor's x and y properties to match the actor's FlxSprite current position
		x = actor.x;
		y = actor.y;

		// Update the position of the shadow Flxsprite to match the actor's FlxSprite position
		shadow.x = actor.x;
		shadow.y = actor.y;
	}

	/**
	* Determines the actor's facing direction based on its movement vector,
	* and updates actor.facing, shadow.facing, and animFacingIndex to match.
	*
	* Decision rule: horizontal movement (vector.x) decides left/right flip.
	* Then, whichever of |vector.x| / |vector.y| is LARGER decides SIDE vs FRONT/BACK:
	* moving mostly sideways → SIDE; mostly downward → FRONT; mostly upward → BACK.
	* On an exact tie, SIDE wins (the vertical check requires strictly greater, not >=).
	*
	* See `facingRanged()` below for the same rule applied to a fixed target
	* direction instead of the live movement vector.
	*/
	function facing():Void
	{
		if (vector.x > 0) // moving right
		{
			actor.facing = FlxDirectionFlags.RIGHT;
			shadow.facing = FlxDirectionFlags.RIGHT;
			animFacingIndex = Facing.SIDE;

			if (vector.y > 0) // also moving down
			{
				if (vector.y > vector.x) animFacingIndex = Facing.FRONT;
			}
			else if (Math.abs(vector.y) > vector.x) // moving up, and mostly so
				animFacingIndex = Facing.BACK;
		}
		else // moving left (or not moving horizontally at all)
		{
			actor.facing = FlxDirectionFlags.LEFT;
			shadow.facing = FlxDirectionFlags.LEFT;
			animFacingIndex = Facing.SIDE;

			if (vector.y > 0) // also moving down
			{
				if (vector.y > Math.abs(vector.x)) animFacingIndex = Facing.FRONT;
			}
			else if (Math.abs(vector.y) > Math.abs(vector.x)) // moving up, and mostly so
				animFacingIndex = Facing.BACK;
		}

		// FRONT/BACK animations only have one drawn orientation, so always use the
		// RIGHT-facing frames for them and rely on flipping only for true SIDE facing.
		if (animFacingIndex > Facing.SIDE)
		{
			actor.facing = FlxDirectionFlags.RIGHT;
			shadow.facing = FlxDirectionFlags.RIGHT;
		}

		// The shadow sprite is always vertically mirrored (it's drawn "upside down"
		// beneath the actor), regardless of facing.
		shadow.flipY = true;
	}

	/**
	* Same facing/animFacingIndex logic as `facing()` above, but driven by the
	* direction toward a fixed `target` (dx/dy) instead of the live movement
	* vector. Used by Ninja's bow-charge to keep facing the player while
	* standing still. See `facing()` for the exact decision rule.
	*
	* @param target The target actor that the current actor is facing.
	*/
	public function facingRanged(target:Actor):Void
	{
		var dx:Float = target.x - actor.x; // horizontal distance to target
		var dy:Float = target.y - actor.y; // vertical distance to target

		if (dx > 0) // target is to the right
		{
			actor.facing = FlxDirectionFlags.RIGHT;
			shadow.facing = FlxDirectionFlags.RIGHT;
			animFacingIndex = Facing.SIDE;

			if (dy > 0) // target is also below
			{
				if (dy > dx) animFacingIndex = Facing.FRONT;
			}
			else if (Math.abs(dy) > dx) // target is above, and mostly so
			{
				animFacingIndex = Facing.BACK;
			}
		}
		else // target is to the left (or directly above/below)
		{
			actor.facing = FlxDirectionFlags.LEFT;
			shadow.facing = FlxDirectionFlags.LEFT;
			animFacingIndex = Facing.SIDE;

			if (dy > 0) // target is also below
			{
				if (dy > Math.abs(dx)) animFacingIndex = Facing.FRONT;
			}
			else if (Math.abs(dy) > Math.abs(dx)) // target is above, and mostly so
				animFacingIndex = Facing.BACK;
		}

		// Same reasoning as in facing(): FRONT/BACK frames are only drawn one way.
		if (animFacingIndex > Facing.SIDE)
		{
			actor.facing = FlxDirectionFlags.RIGHT;
			shadow.facing = FlxDirectionFlags.RIGHT;
		}

		shadow.flipY = true; // shadow is always vertically mirrored
	}

	/**
	* Bakes animations into the specified sprite based on the provided animation data.
	*
	* @param sprite 		The FlxSprite to bake the animations into.
	* @param asset 			The asset path for the sprite's graphic.
	* @param animated 		Determines whether the sprite should be animated.
	* @param width 			The width of each frame in pixels.
	* @param height 		The height of each frame in pixels.
	* @param unique 		Determines if the graphic should be a unique instance.
	* @param animData 		The animation frame data for each animation.
	* @param animFrameRate 	The frame rate for each animation.
	*/
	function bakeAnimations(sprite:FlxSprite, asset:String, animated:Bool, width:Int, height:Int, unique:Bool = false, animData:Array<Array<Array<Int>>>, animFrameRate:Array<Array<Int>>):Void
	{
		sprite.loadGraphic(asset, animated, width, height, unique);

		for (i in 0...animNames.length) // for each facing row (SIDE, FRONT, BACK)
		{
			for (j in 0...animNames[i].length) // for each animation slot (IDLE, RUN, ATTACK, ...)
			{
				var isLooped:Bool = false;

				// j == 1 and j == 6 are ANIM_RUN and ANIM_CHARGE (see the constants above) -
				// these are the only two animations that loop continuously while the actor
				// keeps running/charging. Every other animation (idle, attack, death, dead)
				// plays once and holds/finishes. Written as literal 1/6 rather than
				// `j == ANIM_RUN || j == ANIM_CHARGE` - functionally identical, but the
				// named form would self-document this without needing this comment.
				if (j == ANIM_RUN || j == ANIM_CHARGE) isLooped = true;
				sprite.animation.add(animNames[i][j], animData[i][j], animFrameRate[i][j], isLooped);
			}
		}

		// Set the default animation to play
		sprite.animation.play(ANIM_SIDE_IDLE);

		// Set the facing flip for left and right
		sprite.setFacingFlip(FlxDirectionFlags.LEFT, true, false);
		sprite.setFacingFlip(FlxDirectionFlags.RIGHT, false, false);
	}
}