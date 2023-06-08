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
	 */
	function createGraphic():Void
	{
		loadGraphic("assets/images/bg.png", false, true);
	}

	/**
	* Removes the current background graphic and recreates it.
	* Useful for refreshing the background in order to remove any "stamped" ninja corpses.
	*/
	public function removeCorpses():Void
	{
		graphic = null;
		createGraphic();
	}
}