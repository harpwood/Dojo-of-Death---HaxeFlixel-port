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

package game;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import game.GameState;

/**
 * Represents the background of the game.
 * Handles the creation and removal of the background graphic.
 * Ninja (their corresponding FlxSprite) corpses are "stamped" onto the
 * background image for performance reasons using the `stamp()` method.
 * When starting a new game, the background image is refreshed
 * without the "stamped" corpses to provide a clean slate.
 *
 * Note: `stamp()` isn't defined anywhere in this class - it's inherited from
 * Flixel's `FlxSprite` (draws another sprite's pixels directly onto this
 * sprite's own bitmap). The actual stamping calls live in
 * `Ninja.killActor()`, which stamps both the dead ninja and its shadow onto
 * `game.bg` (this class) before destroying the live sprites.
 */
class Background extends FlxSprite
{
	
	/**
	 * Creates a new instance of the Background class.
	 *
	 * @param game			The parent GameState instance that manages the game (FlxState).
	 * @param X             The X coordinate of the background.
	 * @param Y             The Y coordinate of the background.
	 * @param SimpleGraphic The graphic asset to use for the background.
	 */
	public function new(game:GameState, ?X:Float = 0, ?Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset):Void
	{
		super(X, Y, SimpleGraphic);
		createGraphic();
		
		game.add(this);
		
	}

	/**
	 * Creates the graphic for the background by loading an image file.
	 *
	 * Note: Flixel's `loadGraphic()` source (checked versions 4.0 through
	 * 6.2, including the exact version this project builds against) always
	 * lists the third parameter as `frameWidth:Int`, not `Bool`. Passing the
	 * literal `true` here still compiles and runs correctly in practice, so
	 * whatever Haxe does with a Bool literal in an Int slot here is a real,
	 * working language behavior, not a bug - this note is just here so a
	 * future reader who notices the same apparent mismatch doesn't need to
	 * re-investigate it.
	 */
	function createGraphic():Void
	{
		loadGraphic("assets/images/bg.png", false, true);
	}

	/**
	* Removes the current background graphic and recreates it.
	* Useful for refreshing the background in order to remove any "stamped" ninja corpses.
	*
	* Why this works: `stamp()` (see class doc above) mutates this sprite's
	* bitmap directly - there's no list of "stamped corpses" to remove
	* individually, just pixels baked into one image. Discarding the whole
	* bitmap (`graphic = null`) and reloading the original file from disk via
	* `createGraphic()` is the only way to undo all of them at once.
	*/
	public function removeCorpses():Void
	{
		graphic = null;
		createGraphic();
	}
}