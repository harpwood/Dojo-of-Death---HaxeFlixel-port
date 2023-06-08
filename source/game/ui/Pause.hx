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

package game.ui;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import game.GameState;
import game.util.Color;

/**
 * The Pause class represents a pause screen in the game.
 * The game can be paused from the `UserInput` class
 * and resume gameplay from the `Pause` class.
 */
class Pause extends FlxSubState 
{
	
	var game:GameState; 	// The parent FlxState instance
	var pauseText:FlxText;
	
	public function new(game:GameState, BGColor:FlxColor=FlxColor.TRANSPARENT) 
	{
		super(Color.SEMI_TRANSP_BLACK);
		
		this.game = game;
		
		// Inform the parent instance that the game is paused
		game.setPause(true);
		
		// Create and display the pause text
		pauseText = new FlxText(0, 0, 0, "Pause", 100, false);
		pauseText.screenCenter();
		add(pauseText);
	}
	
	/**
     * Updates the pause screen.
     *
     * @param elapsed The elapsed time since the last update.
     */
	override public function update(elapsed:Float):Void
	{
		// Press 'P' to unpause the game
		if (FlxG.keys.justPressed.P)
		{
			// hide the pause text
			remove(pauseText);
			// Inform the parent instance that the game is unpaused
			game.setPause(false);
			close();
		}
	}
	
}