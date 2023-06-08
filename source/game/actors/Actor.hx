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

	// animation indexes constants
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
	* Example: animNames[animFacingIndex][ANIM_RUN]
	* Plays the run animation based on the animFacingIndex.
	*
	* The animFacingIndex represents the facing direction:
	*   - Side:   Facing.SIDE = 0
	*   - Front:  Facing.FRONT = 1
	*   - Back:   Facing.BACK = 2
	*
	* Note: For the left side, the side direction sprites are flipped.
	*/
	var animNames: Array<Array<String>>; 	// Stores the animation names for different facing directions
	var animFacingIndex: Int;				// Represents the index for the current facing direction

	/**
	* Represents the current state of the Actor instance.
	*
	* Use the static constants in the State class to access the available states:
	*   - Running: 		State.RUN
	*   - Charging: 	State.CHARGE
	*   - Attacking: 	State.ATTACK
	*   - Cooldown: 	State.COOLDOWN
	*   - Death: 		State.DEATH
	*   - Dead: 		State.DEAD
	*   - Intro: 		State.INTRO
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
	var meleeReach:Int;			// The range of the melee attack reach, specifying how close the target must be for the attack to detect collision

	// Public instance properties specific to the Actor class (not related to actor:FlxSprite)
	public var x(default, null):Float;		// The x position of the actor
	public var y(default, null):Float;		// The y position of the actor
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

		/**
		* Defines the animation names for different facing directions of the actor.
		*
		* The animNames array is a 2D array where each sub-array represents the animation names for a specific facing direction.
		* The index values correspond to the animation indexes/constants defined earlier.
		*
		* Example:
		* - animNames[Facing.SIDE][ANIM_RUN] returns the animation name for the side-facing run animation.
		*
		* Note: The animation names should match the constants defined earlier for consistency.
		*/
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

		/**
		* Represents the current facing direction of the actor.
		*
		* Use the constants defined in the Facing class to set the facing direction:
		* - Facing.SIDE for side-facing direction
		* - Facing.FRONT for front-facing direction
		* - Facing.BACK for back-facing direction
		*
		* The initial value is set to Facing.SIDE by default.
		*/
		animFacingIndex = Facing.SIDE;

		/**
		* An array of color matrix filter values used to modify the appearance of the shadow.
		* The color matrix filter is applied to the sprite to change its color to black and
		* make it semi-transparent, creating a shadow effect.
		*
		* In this case, the alpha value (a) is set to 0.15 to create a semi-transparent shadow.
		*/
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
		meleeReach = 30; 			 // Set the meleeReach value to specify the range of the melee attack reach, indicating how close the target must be for the attack to detect collision
	}
	
	/**
	 * ---------------------------------------------
	 * 
	 *  			PUBLIC FUNCTIONS
	 * 
	 * ---------------------------------------------
	 */

	/**
	* Initializes the player actor with the specified type.
	*
	* @param type The type of the player actor (optional, default value is 0).
	*
	* @note This method overrides the superclass's initialize method and can be
	* further customized for player or enemy specific initialization logic.
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
	* Determines the actor's facing direction based on its movement vector.
	* Updates the actor's facing, shadow facing, and animFacingIndex accordingly.
	*
	*   @Note:  Upwards movement corresponds to the BACK  side animations,
	*   while downwards movement corresponds to the FRONT side animations.
	*/
	function facing():Void
	{
		// Check if the actor is moving towards the right
		if (vector.x > 0)
		{
			// Set the actor and shadow to face right
			actor.facing = FlxDirectionFlags.RIGHT;
			shadow.facing = FlxDirectionFlags.RIGHT;

			// Set the animation facing index to the side direction
			animFacingIndex = Facing.SIDE;

			// Check if the actor is moving downwards
			if (vector.y > 0)
			{
				// Determine facing direction based on the relative magnitude of vertical and horizontal movement
				// Facing front if the vertical movement is greater than the horizontal movement
				if (vector.y > vector.x)
					animFacingIndex = Facing.FRONT;
			}
			// if the actor is moving upwards apply BACK facing
			else if (Math.abs(vector.y) > vector.x)
				animFacingIndex = Facing.BACK;
		}
		else // if the actor is moving towards the left
		{
			// Set the actor and shadow to face left
			actor.facing = FlxDirectionFlags.LEFT;
			shadow.facing = FlxDirectionFlags.LEFT;
			// Set the animation facing index to the side direction
			animFacingIndex = Facing.SIDE;

			// Check if the actor is moving downwards
			if (vector.y > 0)
			{
				// Determine facing direction based on the relative magnitude of vertical and horizontal movement
				// Facing front if the vertical movement is greater than the absolute value of the horizontal movement
				if (vector.y > Math.abs(vector.x))
					animFacingIndex = Facing.FRONT;
			}
			// Check if the actor is moving upwards apply BACK facing for upwards movement
			else if (Math.abs(vector.y) > Math.abs(vector.x))
				animFacingIndex = Facing.BACK;
		}

		// If the facing is not SIDE (either to left or right)
		if (animFacingIndex > Facing.SIDE)
		{
			// Flip image horizontally if facing front or upwards
			actor.facing = FlxDirectionFlags.RIGHT;
			shadow.facing = FlxDirectionFlags.RIGHT;
		}

		// Ensure the shadow is always flipped vertically
		shadow.flipY = true;
	}

	/**
	* Adjusts the facing direction of the actor for ranged attacks based on the relative position of a target.
	* Updates the actor's facing, shadow facing, and animFacingIndex accordingly.
	* 
	*   @Note:  Upwards facing corresponds to the BACK  side animations,
	*   while downwards facing corresponds to the FRONT side animations.
	* 
	* @param target The target actor that the current actor is facing.
	*/
	public function facingRanged(target:Actor):Void
	{
		// Calculate the horizontal and vertical distance between the actor and the target
		var dx:Float = target.x - actor.x;
		var dy:Float = target.y - actor.y;

		// If the target is positioned to the right of the actor
		if (dx > 0)
		{
			// Set the actor and shadow to face right
			actor.facing = FlxDirectionFlags.RIGHT;
			shadow.facing = FlxDirectionFlags.RIGHT;

			// Set the animation facing index to the side direction
			animFacingIndex = Facing.SIDE;

			// If the target is positioned below the actor
			if (dy > 0)
			{
				// Determine facing direction based on the relative magnitude of vertical and horizontal distance
				// Facing front if the vertical distance is greater than the horizontal distance
				if (dy > dx)
					animFacingIndex = Facing.FRONT;
			}
			// If the target is positioned above the actor apply BACK facing
			else if (Math.abs(dy) > dx)
			{
				animFacingIndex = Facing.BACK;
			}
		}
		else // If the target is positioned to the left of the actor
		{
			// Set the actor and shadow to face left
			actor.facing = FlxDirectionFlags.LEFT;
			shadow.facing = FlxDirectionFlags.LEFT;
			// Set the animation facing index to the side direction
			animFacingIndex = Facing.SIDE;

			// If the target is positioned below the actor
			if (dy > 0)
			{
				// Determine facing direction based on the relative magnitude of vertical and horizontal distance
				// Facing front if the vertical distance is greater than the horizontal distance
				if (dy > Math.abs(dx))
					animFacingIndex = Facing.FRONT;
			}
			// If the target is positioned above the actor apply BACK facing
			else if (Math.abs(dy) > Math.abs(dx))
				animFacingIndex = Facing.BACK;
		}

		// If the facing is not SIDE (either to left or right)
		if (animFacingIndex > Facing.SIDE)
		{
			// Flip image horizontally if facing is front or back
			actor.facing = FlxDirectionFlags.RIGHT;
			shadow.facing = FlxDirectionFlags.RIGHT;
		}

		// Ensure the shadow is always flipped vertically
		shadow.flipY = true;
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

		// Iterate through the animation data using nested loops
		for (i in 0...animNames.length)
		{
			for (j in 0...animNames[i].length)
			{
				// Determine if the animation should loop based on the animation index
				var isLooped:Bool = false;

				// Add the animation to the sprite's animation list
				if (j == 1 || j == 6) isLooped = true;
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