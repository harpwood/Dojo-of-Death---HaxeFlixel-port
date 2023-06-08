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
import flixel.math.FlxAngle;
import flixel.system.FlxAssets.FlxGraphicAsset;
import game.GameState;
import game.util.State;

/**
 * Represents a strike effect displayed on the actor when he get hit by a melee attack.
 * It is stored in a pool and reused when needed.
 * It provides animations for the strike effect, including growth and shrinkage.
 */
class StrikeLine extends FlxSprite
{
	var game:GameState; // The parent FlxState instance reference
	var state:Int; 		// The state of the strike effect
	var _scale:Float; 	// The scale of the strike effect

	public var isActive(default, null):Bool; // Flag indicating if the strike effect is currently being used

	/**
	 * Creates a new StrikeLine instance.
	 *
	 * @param game 			The parent GameState instance that manages the game (FlxState).
	 * @param X 			The initial x-coordinate of the strike line.
	 * @param Y 			The initial y-coordinate of the strike line.
	 * @param SimpleGraphic The graphic asset for the strike line.
	 */
	public function new(game:GameState, ?X:Float = 0, ?Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset)
	{
		super(X, Y, SimpleGraphic);

		this.game = game;

		// Load the graphic for the strike line
		loadGraphic("assets/images/strike.png", false, 300, 11);

		// Set the offset and origin for the strike line
		offset.set(150, 6);
		centerOrigin();

		// Deinitialize the strike sprite and add it to the strike pool
		deInitialize();
		game.strikes.add(this);
	}

	/**
	 * Initializes the strike line with the specified position.
	 *
	 * @param X The x-coordinate of the strike line.
	 * @param Y The y-coordinate of the strike line.
	 */
	public function initialize(X:Float, Y:Float):Void
	{
		// Revive the strike line to make it visible and usable
		revive();

		// Set the position of the strike line
		x = X;
		y = Y;

		// Randomize the rotation of the strike line
		var rotation = Math.random() * 0.5;
		rotation *= Math.random() < 0.5 ? 1 : -1;
		angle = FlxAngle.asDegrees(rotation);

		// Set the initial state and scale of the strike line
		state = State.GROW;
		_scale = 0;
		scale.set(_scale, _scale);

		// Mark the strike line that is being used
		isActive = true;
	}

	/**
	 * Deactivates the strike line. It can be reused anytime.
	 */
	function deInitialize():Void
	{
		isActive = false;
		kill();
	}

	/**
	 * Updates the strike line's animations and state.
	 *
	 * @param elapsed The time elapsed since the last update.
	 */
	override public function update(elapsed:Float):Void
	{
		switch (state)
		{
			case State.GROW:
				// Increase the scale of the strike line
				_scale += elapsed * 20;

				// When it grows enough, change the scate to shrink
				if (_scale >= 1)
				{
					_scale = 1;
					state = State.SHRINK;
				}

			case State.SHRINK:
				// Decrease the scale of the strike line
				_scale -= elapsed * 5;

			  // If the scale becomes zero or negative, deinitialize the strike sprite;
			  if (_scale <= 0)
				  deInitialize();
		}

		// Apply scaling
		scale.set(_scale, _scale);

		super.update(elapsed);
	}
}
