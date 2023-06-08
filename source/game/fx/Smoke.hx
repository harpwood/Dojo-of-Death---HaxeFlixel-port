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
 * Represents a smoke sprite that is used for visual effects in the game.
 * It is stored in a pool available to be reused.
 * The smoke sprite is created when a new actor appears, triggering a smoke effect.
 * It provides movement and fading animations for the smoke effect.
 */
class Smoke extends FlxSprite
{
	var game:GameState; // The parent FlxState instance reference
	var dx:Float;		// The horizontal movement speed of the smoke sprite
	var dy:Float;		// The vertical movement speed of the smoke sprite

	public var isActive(default, null):Bool; // Flag indicating if the smoke sprite is currently being used

	/**
	 * Creates a new Smoke instance.
	 *
	 * @param game 			The parent GameState instance that manages the game (FlxState).
	 * @param X 			The initial x-coordinate of the smoke sprite.
	 * @param Y 			The initial y-coordinate of the smoke sprite.
	 * @param SimpleGraphic The graphic asset for the smoke sprite.
	 */
	public function new(game:GameState, ?X:Float = 0, ?Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset)
	{
		super(X, Y, SimpleGraphic);

		this.game = game;

		// Define the color for the smoke sprite
		var color:FlxColor = Color.GREY;

		// Create the smoke sprite
		makeGraphic(20, 20, color);

		// Deinitialize the smoke sprite and add it to the smokes pool
		deInitialize();
		game.smokes.add(this);
	}

	/**
	 * Initializes the smoke sprite with the specified position.
	 *
	 * @param X The x-coordinate of the smoke sprite.
	 * @param Y The y-coordinate of the smoke sprite.
	 */
	public function initialize(X:Float, Y:Float):Void
	{
		// Revive the smoke sprite to make it visible and usable
		revive();

		// Mark the smoke sprite that is being used
		isActive = true;

		// Set the initial alpha value to fully opaque
		alpha = 1;

		// Set the x and y coordinate of the smoke sprite with some random offset
		x = X + Math.random() * 40 - 20;
		y = Y + Math.random() * 40 - 20;

		// Calculate the random movement values for the smoke sprite
		dx = Math.random() * 10 + 5;
		dy = Math.random() * 50 + 20;

		// Set the initial scale of the smoke sprite randomly
		var r:Float = Math.random() + .5;
		scale.set(r, r);
	}

	/**
	 * Deactivates the smoke sprite. It can be reused anytime.
	 */
	function deInitialize():Void
	{
		isActive = false;
		kill();
	}

	/**
	 * Updates the smoke sprite's position and animations.
	 *
	 * @param elapsed The time elapsed since the last update.
	 */
	override public function update(elapsed:Float):Void
	{
		// Apply levitation-like effect to the smoke sprite
		dy -= 50 * elapsed;
		x += dx * elapsed;
		y -= dy * elapsed;

		// Fade out the smoke sprite over time
		alpha -= elapsed;

		// Deinitialize the smoke sprite if it has completely faded out
		if (alpha <= 0)
			deInitialize();

		super.update(elapsed);
	}
}
