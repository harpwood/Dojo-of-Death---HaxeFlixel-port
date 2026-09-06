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
import flixel.text.FlxText;
import flixel.util.FlxColor;
import game.GameState;
import game.util.Color;
import game.util.State;

/**
 * The game over screen: title + kills/score/best-combo readout, shown after
 * the player dies, with a staggered fade-in and an automatic return to the
 * title screen after 30 seconds (see update() below).
 *
 * Layout note: the constructor below reuses a handful of local variables
 * (x, y, size, color, width) as a mutable "layout cursor" - each block
 * reassigns x/y/size before creating the next text element, rather than each
 * block declaring its own fresh values. The initial text strings ("100",
 * "0000000", "x321") are just placeholders for layout/testing - they're
 * always overwritten by real numbers in initialize() (misspelled as
 * `inititialize` below - see that method's doc) once a game actually ends.
 */
class GameOver
{

	var game:GameState;
	var title:FlxText;
	var killsText:FlxText;
	var scoreText:FlxText;
	var comboText:FlxText;
	var killsNum:FlxText;
	var scoreNum:FlxText;
	var comboNum:FlxText;
	var textTimer:Float;
	var resetTimer:Float;

	public function new(game:GameState):Void
	{
		this.game = game;
		// The color used for the text elements
		var color:FlxColor = Color.RED;

		// The position of the text elements
		var x:Float = 200;
		var y:Float = 95;

		// The size of the text elements
		var size:Int = 80;

		// Create a new FlxText object for the title and set up its properties
		title = new FlxText(x, y, 0, "Honorable Death", size, false);
		title.color = color;
		title.font = "assets/fonts/Zenzai_Itacha.ttf";

		// The position of the next text elements
		x = 230;
		y = 220;

		// Adjust the text size for the next text
		size = 55;

		// Create a new FlxText object for the "Kills" text and set up its properties
		killsText = new FlxText(x, y, 0, "Kills", size, false);
		killsText.color = color;
		killsText.font = "assets/fonts/Zenzai_Itacha.ttf";

		// The width is given for better alignment
		var width = 340;

		// Create a new FlxText object for the number of kills and set up its properties
		killsNum = new FlxText(x, y, width, "100", size, false);
		killsNum.color = color;
		killsNum.font = "assets/fonts/Zenzai_Itacha.ttf";
		killsNum.alignment = FlxTextAlign.RIGHT;

		// The position of the next text elements
		y = 290;

		// Create a new FlxText object for the score text and set up its properties
		scoreText = new FlxText(x, y, 0, "Score", size, false);
		scoreText.color = color;
		scoreText.font = "assets/fonts/Zenzai_Itacha.ttf";

		// Create a new FlxText object for the score and set up its properties
		scoreNum = new FlxText(x, y, width, "0000000", size, false);
		scoreNum.color = color;
		scoreNum.font = "assets/fonts/Zenzai_Itacha.ttf";
		scoreNum.alignment = FlxTextAlign.RIGHT;

		// The position of the next text elements
		y = 360;

		// Create a new FlxText object for the best combo (multiplier) text and set up its properties
		comboText = new FlxText(x, y, 0, "Best Combo", size, false);
		comboText.color = color;
		comboText.font = "assets/fonts/Zenzai_Itacha.ttf";

		// Create a new FlxText object for the best combo (multiplier) and set up its properties
		comboNum = new FlxText(x, y, width, "x321", size, false);
		comboNum.color = color;
		comboNum.font = "assets/fonts/Zenzai_Itacha.ttf";
		comboNum.alignment = FlxTextAlign.RIGHT;

		// Add all the elements on the game over layer
		game.gameOverLayer.add(title);
		game.gameOverLayer.add(killsText);
		game.gameOverLayer.add(killsNum);
		game.gameOverLayer.add(scoreText);
		game.gameOverLayer.add(scoreNum);
		game.gameOverLayer.add(comboText);
		game.gameOverLayer.add(comboNum);

		// Set the visibility of the credits screen elements to false
		setVisibility();
	}

	/**
	* Initializes the game over screen with the specified values.
	*
	* Note: this method's name has a typo ("inititialize" - extra "i") baked
	* into the public API; `GameState.setState()` calls it by this exact
	* misspelled name. Renaming it correctly would mean updating both files
	* together, so it's left as-is here (comment-only pass) but logged for a
	* future cleanup.
	*
	* @param kills The number of kills achieved by the player.
	* @param score The final score earned by the player.
	* @param combo The best combo achieved by the player.
	*/
	public function inititialize(kills:Int, score:Int, combo:Int):Void
	{
		// Hide all text elements initially
		setVisibility();

		// Reset the timers
		textTimer = 0;
		resetTimer = 0;

		// Apply the kills, score, and combo values to the corresponding text elements.
		// Note: the line below is a duplicate (was almost certainly meant to be
		// two different assignments) - it sets killsNum.text twice and never
		// causes a visible problem only because both duplicate calls compute
		// the exact same value.
		killsNum.text = Std.string(kills);
		killsNum.text = Std.string(kills);
		scoreNum.text = Std.string(score);
		comboNum.text = "x" + Std.string(combo);
	}

	/**
	* Deinitializes the game over screen, hiding all text elements.
	*/
	public function deInitialize():Void
	{
		setVisibility();
	}

	/**
	* Sets the visibility of the game over screen text elements.
	*
	* @param visible Whether the text elements should be visible or not. Default is false.
	*/
	function setVisibility(visible:Bool = false):Void
	{
		title.visible = visible;
		title.alpha = 0; // will fade in
		killsText.visible = visible;
		killsNum.visible = visible;
		scoreText.visible = visible;
		scoreNum.visible = visible;
		comboText.visible = visible;
		comboNum.visible = visible;
	}

	/**
	* Updates the game over screen based on the elapsed time.
	*
	* Staggered reveal: the title fades in continuously via alpha, while
	* kills/score/combo each pop in (as a visibility toggle, not a fade) at
	* fixed time thresholds - 1.25s, 1.5s, 1.75s - for a one-at-a-time reveal
	* rather than everything appearing at once. `resetTimer` separately counts
	* up to 30 seconds, at which point the game automatically returns to
	* State.INTRO (see the note on `GameState.setState()` about this being its
	* only caller).
	*
	* @param elapsed The elapsed time since the last update.
	*/
	public function update(elapsed:Float):Void
	{
		// Fade in the title
		title.visible = true;
		title.alpha = Math.min(1, title.alpha + elapsed);

		// Increment the timers with the elapsed time
		textTimer += elapsed;
		resetTimer += elapsed;

		// Show kills text elements after 1.25 seconds
		if (textTimer > 1.25)
		{
			killsText.visible = true;
			killsNum.visible = true;
		}

		// Show score text elements after 1.5 seconds
		if (textTimer > 1.5)
		{
			scoreText.visible = true;
			scoreNum.visible = true;
		}

		// Show combo text elements after 1.75 seconds
		if (textTimer > 1.75)
		{
			comboText.visible = true;
			comboNum.visible = true;
		}
		
		// Set game state into INTRO state after 30 seconds.
		if (resetTimer >= 30) game.setState(State.INTRO);
	}

}