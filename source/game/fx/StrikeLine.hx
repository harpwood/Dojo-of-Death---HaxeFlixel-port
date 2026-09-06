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
 * A brief slash-flash effect shown when an actor is hit by a melee attack.
 * Same pooling pattern as `Blood` (see Blood.hx's class doc).
 *
 * Note: this class's own `state` field (below) uses `State.GROW`/`State.SHRINK`.
 * These are a THIRD, unrelated family of state values, distinct from both the
 * actor states (Actor.state: RUN/CHARGE/ATTACK/...) and the game states
 * (GameState.state: INTRO/PLAY/...) - see the big warning in `State.hx` about
 * these three enumerations sharing overlapping integer values by coincidence.
 * This class doesn't extend `Actor`, so its `state` field is a completely
 * separate thing from Actor's, despite the identical field name.
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
	 * Grows 4x faster than it shrinks (scale +20/sec up to 1.0, then -5/sec back
	 * down) for a quick "pop" appearance followed by a gentler fade - roughly
	 * 0.05s to grow, 0.2s to shrink. Unlike the state-machine switches in
	 * Player/Ninja/GameState (which use raw int case labels), this one uses the
	 * named `State.GROW`/`State.SHRINK` constants directly.
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

				// When it grows enough, change the scale to shrink
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
