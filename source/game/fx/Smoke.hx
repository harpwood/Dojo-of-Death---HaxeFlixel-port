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
 * A single smoke puff particle, shown briefly when an actor (Player or Ninja)
 * appears. Follows the same pool-of-pre-built-instances pattern as `Blood` -
 * see the class doc on `Blood.hx` for how that pooling works in general.
 */
class Smoke extends FlxSprite
{
	var game:GameState; // The parent FlxState instance reference
	var dx:Float;		// Horizontal drift speed - always positive (see initialize()), so every puff drifts the same direction, unlike Blood's symmetric left/right drift
	var dy:Float;		// Vertical "lift" speed - same sign convention as Blood.dy (see Blood.hx's update() doc), just tuned weaker/slower for a floating rather than arcing motion

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
	 * Same rising/decelerating motion idea as Blood (see Blood.hx's update()
	 * doc for the dy sign-convention explanation) - here tuned to look like a
	 * slow-rising, decelerating puff rather than an arc, and it fades out via
	 * `alpha` well before dy would go negative. Unlike Blood.hx, every value
	 * here (dx, dy, alpha) is correctly multiplied by `elapsed`, so this
	 * effect's speed and lifetime are frame-rate independent.
	 *
	 * @param elapsed The time elapsed since the last update.
	 */
	override public function update(elapsed:Float):Void
	{
		// Apply levitation-like effect to the smoke sprite
		dy -= 50 * elapsed;
		x += dx * elapsed;
		y -= dy * elapsed;

		// Fade out the smoke sprite over time (alpha starts at 1, so this is a ~1 second lifetime)
		alpha -= elapsed;

		// Deinitialize the smoke sprite if it has completely faded out
		if (alpha <= 0)
			deInitialize();

		super.update(elapsed);
	}
}
