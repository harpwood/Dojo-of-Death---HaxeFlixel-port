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

package game.fx;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import game.GameState;
import game.util.Color;

/**
 * Represents a blood sprite that is used for visual effects in the game.
 * It is stored in a pool available to reused.
 * The blood sprite is created when an actor is killed.
 * It provides animations and movement for the blood effect.
 */
class Blood extends FlxSprite
{

	var game:GameState; // The parent FlxState instance reference
	var dx:Float; 		// The horizontal movement speed of the blood sprite
	var dy:Float; 		// The vertical movement speed of the blood sprite
	var _scale:Float; 	// The current scale of the blood sprite

	public var isActive(default, null):Bool; // Flag indicating if the blood sprite is currently being used

	/**
	 * Creates a new Blood instance.
	 *
	 * @param game 			The parent GameState instance that manages the game (FlxState).
	 * @param X 			The initial x-coordinate of the blood sprite.
	 * @param Y 			The initial y-coordinate of the blood sprite.
	 * @param SimpleGraphic The graphic asset for the blood sprite.
	 */
	public function new(game:GameState, ?X:Float=0, ?Y:Float=0, ?SimpleGraphic:FlxGraphicAsset)
	{
		super(X, Y, SimpleGraphic);

		this.game = game;

		// Define the color for the blood sprite
		var color:FlxColor = Color.RED;

		// Create the blood sprite
		makeGraphic(6, 6, color);

		// Deinitialize the blood sprite and add it to the bloods pool
		deInitialize();
		game.bloods.add(this);
	}

	/**
	 * Initializes the blood sprite with the specified position.
	 *
	 * @param X The x-coordinate of the blood sprite.
	 * @param Y The y-coordinate of the blood sprite.
	 */
	public function initialize(X:Float, Y:Float):Void
	{
		// Revive the blood sprite to make it visible and usable
		revive();

		// Mark the blood sprite that is being used
		isActive = true;

		// Set the position of of the blood sprite
		x = X;
		y = Y;

		// Calculate the random movement values for the blood sprite
		var sign:Float = (Math.random() > .5) ? 1 : -1;				// The random direction on x axis (-1 = LEFT, 1 = RIGHT)
		var r:Float = (Math.random() > .5) ? 1 : Math.random() * 2; // Random velocity modifier on the x-axis
		dx = sign * Math.random() * r;								// Apply the random velocity modifier
		dy = Math.random() * 200 + 300;								// Random velocity modifier on the y-axis
		r = Math.random() + 1;										// Set the initial scale randomly

		// Apply the random scale
		scale.set(r, r);
		_scale = r;

	}

	/**
	 * Deactivates the blood sprite. It can be reused any time.
	 */
	function deInitialize():Void
	{
		isActive = false;
		kill();
	}

	/**
	 * Updates the blood sprite's position and animations.
	 *
	 * @param elapsed The time elapsed since the last update.
	 */
	override public function update(elapsed:Float):Void
	{
		// Move the blood sprite horizontally
		x += dx;

		// Apply gravity effect to the blood sprite
		dy -= 800 * elapsed;
		y -= dy * elapsed;

		// Decrease the scale of the blood sprite over time
		_scale -= 0.05;
		scale.set(_scale, _scale);

		// If the scale becomes zero or negative, deinitialize the blood sprite
		if (scale.x <= 0 || scale.y <= 0) deInitialize();

		super.update(elapsed);
	}
}