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
import flixel.FlxSprite;
import flixel.input.mouse.FlxMouseEvent;
import flixel.util.FlxColor;
import game.GameState;
import game.ui.Pause;
import game.util.Audio;
import game.util.State;

/**
 * Handles user input interactions and triggers appropriate actions in the game.
 */
class UserInput
{

	var isPaused:Bool;
	var inputLayer:FlxSprite;
	var game:GameState;

	/**
	 * Creates a new UserInput instance.
	 *
	 * @param game The parent GameState instance that manages the game (FlxState).
	 */
	public function new(game:GameState):Void
	{
		this.game = game;

		// Create a FlxSprite as input layer sprite to capture mouse events.
		// Solid black and covers the whole screen, but this is created first
		// in GameState.create() (before Background and everything else), so
		// every later-added object draws on top of it - it's never actually
		// visible, just present to catch clicks anywhere on screen.
		inputLayer = new FlxSprite();
		inputLayer.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		this.game.add(inputLayer);

		// Register the onMouseDown callback for mouse events on the input layer.
		// Signature (checked against the installed Flixel version): add(object,
		// onMouseDown, onMouseUp, onMouseOver, onMouseOut, mouseChildren=false,
		// mouseEnabled=true, pixelPerfect=true, mouseButtons). Only onMouseDown
		// is used here (the rest are null); mouseChildren=false since this
		// plain sprite has no children; mouseEnabled=true is explicit but
		// matches the default anyway. pixelPerfect is left at its default
		// (true), though it makes no practical difference here since
		// inputLayer is fully opaque everywhere - pixel-perfect and
		// bounding-box hit-testing agree on a sprite with no transparent pixels.
		FlxMouseEvent.add(inputLayer, onMouseDown, null, null, null, false, true);

		isPaused = false;

	}

	/**
	 * Handles the onMouseDown event when the user clicks on the input layer.
	 * Case labels are raw ints matching State.* (see State.hx), same pattern
	 * as the other state-machine switches in this codebase.
	 *
	 * @param sprite The sprite that triggered the mouse event.
	 */
	function onMouseDown(sprite:FlxSprite):Void
	{
		// Accept user input only if the game is not paused
		if (isPaused) return;

		var state:Int = game.getState();

		switch (state)
		{
			case 0: // INTRO
				// Transition from intro to gameplay
				game.setState(State.PLAY);

			case 1: // PLAY
				// Trigger the player's attack action
				game.player.attack();

			case 2: // GAME_OVER
				// Restart the game by transitioning to gameplay
				game.setState(State.PLAY);
		}
	}

	/**
	* Updates the game state based on user input.
	* Handles key presses for game controls such as restarting, muting sound effects,
	* muting music, and pausing the game.
	*/
	public function update():Void
	{
		// Press 'R' to restart the game
		if (FlxG.keys.justPressed.R) FlxG.resetGame();

		// Press 'S' to mute/unmute the sound fx
		if (FlxG.keys.justPressed.S) Audio.isSoundOn = !Audio.isSoundOn;

		// Press 'M' to mute/unmute the music
		if (FlxG.keys.justPressed.M)
		{
			// Toggle the music mute state
			Audio.isMusicOn = !Audio.isMusicOn;

			// Mute/unmute the music only during gameplay and when the player is alive.
			// Caution: see the warning on Audio.isMusicPlaying()/resumeMusic() -
			// if music was disabled before gameplay ever started, this branch
			// (specifically isMusicPlaying() below) can throw on a null
			// FlxG.sound.music. Not fixed here, just noting the reachable path.
			if (game.getState() == State.PLAY  && game.player.alive)
			{
				// Check if the music is playing and mute or unmute accordingly
				if (Audio.isMusicPlaying()) Audio.pauseMusic();
				else Audio.resumeMusic();
			}
		}

		// Press 'P' to pause the game
		if (FlxG.keys.justPressed.P)
		{
			// Pause the game only in PLAY state and if the player is alive
			if (game.getState() == State.PLAY && game.player.alive)
			{
				// Flag that the game is paused
				isPaused = true;

				// Invoke pause screen
				game.openSubState(new Pause(game));
			}
		}
	}

	/**
	* Resumes the game by setting the paused state to false.
	*/
	public function resume():Void
	{
		isPaused = false;
	}

	/**
	 * Pauses the game by setting the paused state to true.
	 */
	public function pause():Void
	{
		isPaused = true;
	}

}
