/** 
 * ------------------------------------------------------------
 * @author Harpwood Studio
 * https://harpwood.itch.io/
 * ------------------------------------------------------------
 * ------------------------------------------------------------
 * Original Game Created by Nico Tuason
 * Ported to HaxeFlixel by Harpwood Studio
 * ------------------------------------------------------------
 * GitHub project repository:
 * https://github.com/harpwood/Dojo-of-Death---HaxeFlixel-port
 * ------------------------------------------------------------
 */

package;
 
import flixel.FlxGame;
import game.GameState;
import openfl.display.Sprite;

/**
 * The entry point of the game.
 * Initializes the game and sets up the initial game state.
 */
class Main extends Sprite
{
	public function new()
	{
		super();

		addChild(new FlxGame(800, 600, GameState));
	}
}

