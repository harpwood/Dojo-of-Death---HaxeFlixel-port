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
 * A single blood-splatter particle, shown briefly when an actor is killed.
 *
 * Object pooling pattern (shared by every FX/projectile class in game.fx and
 * game.arrows - Smoke, StrikeLine, Arrow, ArrowBroken all follow this same
 * shape, so this explanation isn't repeated in each of them):
 * - The constructor runs ONCE per pool slot (see GameState, which creates a
 *   `FlxTypedGroup<Blood>` pool and never `new Blood()`s more after startup).
 *   It builds the sprite's graphic, then immediately calls `deInitialize()`
 *   to hide/kill it and registers it into the pool group.
 * - To actually show a new blood particle, callers use the pool's
 *   `recycle()` (see GameState.addBlood()) to find a currently-inactive
 *   instance and call `initialize()` on it, rather than ever constructing
 *   a new one. This avoids constantly allocating/destroying sprites.
 * - `isActive` tracks whether a given pooled instance is currently in use;
 *   `deInitialize()` (calling Flixel's `kill()`) marks it available again.
 */
class Blood extends FlxSprite
{

	var game:GameState; // The parent FlxState instance reference
	var dx:Float; 		// Horizontal drift speed (constant, no gravity applied)
	var dy:Float; 		// Vertical "launch" speed - see update() for the sign convention, which is easy to misread
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

		// Set the position of the blood sprite
		x = X;
		y = Y;

		// Random horizontal drift and initial "launch" speed.
		// Note: `r` here is reused for two unrelated things - first as an
		// x-velocity multiplier, then reassigned below as the particle's scale.
		var sign:Float = (Math.random() > .5) ? 1 : -1;				// The random direction on x axis (-1 = LEFT, 1 = RIGHT)
		var r:Float = (Math.random() > .5) ? 1 : Math.random() * 2; // Random velocity modifier on the x-axis
		dx = sign * Math.random() * r;								// Apply the random velocity modifier
		dy = Math.random() * 200 + 300;								// Initial vertical launch speed (see update() for how this decays)
		r = Math.random() + 1;										// Reused: now the initial scale (1.0 - 2.0)

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
	 * Motion model: `dy` starts as a positive "launch" speed and Flixel's Y axis
	 * increases downward, so `y -= dy * elapsed` initially moves the particle UP
	 * the screen. Each frame, `dy -= 800 * elapsed` (simulated gravity) shrinks
	 * that launch speed toward zero and then negative; once `dy` goes negative,
	 * the same `y -= dy * elapsed` line naturally starts moving the particle back
	 * DOWN, producing an arc. This double sign-flip (dy's own sign, and the minus
	 * in `y -=`) is easy to misread as a bug at a glance - it isn't.
	 *
	 * Caution: unlike the vertical motion above (and unlike Smoke.hx's equivalent
	 * effect, which scales all its per-frame changes by `elapsed`), the
	 * horizontal drift (`x += dx`) and the scale shrink (`_scale -= 0.05`) below
	 * are NOT multiplied by `elapsed`. That makes them frame-rate dependent:
	 * on a faster machine (more update() calls per second) blood drifts sideways
	 * faster and shrinks/disappears sooner in real time than on a slower one.
	 *
	 * @param elapsed The time elapsed since the last update.
	 */
	override public function update(elapsed:Float):Void
	{
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