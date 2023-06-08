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
import flixel.text.FlxText;
import flixel.util.FlxColor;
import game.GameState;
import game.util.Color;

/**
 * Class representing the credits and the disclaimer texts.
 */
class Credits
{
	var title:FlxText; 			// The title text
	var clickToStart:FlxText; 	// The "click to start" text
	var createdBy:FlxText; 		// The "Created by" text
	var portedBy:FlxText; 		// The "Ported by" text
	var disclaimerBG:FlxSprite; // The background sprite for the disclaimer
	var disclaimer:FlxText; 	// The disclaimer text

	public function new(game:GameState):Void
	{
		// The color used for the text elements
		var color:FlxColor = Color.RED;

		// The color used for the shadow of the text elements
		var shadowColor:FlxColor = Color.TRANSPARENT_BLACK;

		// The size of the text elements
		var size:Int = 100;

		// Create a new FlxText object for the title and set up its properties
		title = new FlxText(0, 0, 0, "Dojo of Death", size, false);
		title.color = color;
		title.font = "assets/fonts/Zenzai_Itacha.ttf";
		title.alignment = FlxTextAlign.CENTER;
		title.setBorderStyle(FlxTextBorderStyle.SHADOW, shadowColor, 5);
		title.screenCenter();

		// Adjust the text size for the next text
		size = 50;

		// Create a new FlxText object for the "click to start" text and set up its properties
		clickToStart = new FlxText(0, 0, 0, "click to start", size, false);
		clickToStart.color = color;
		clickToStart.font = "assets/fonts/Zenzai_Itacha.ttf";
		clickToStart.alignment = FlxTextAlign.CENTER;
		clickToStart.setBorderStyle(FlxTextBorderStyle.SHADOW, shadowColor, 5);
		clickToStart.screenCenter();
		clickToStart.y += 120;

		// Adjust the text size for the next texts
		size = 25;

		// Change the color of the next texts
		color = Color.ORANGE;

		// Create a new FlxText object for the "Created by" text and set up its properties
		createdBy = new FlxText(0, 0, 0, "Created by Nico Tuason", size, false);
		createdBy.color = color;
		createdBy.font = "Arial";
		createdBy.alignment = FlxTextAlign.CENTER;
		createdBy.setBorderStyle(FlxTextBorderStyle.SHADOW, shadowColor, 5);
		createdBy.screenCenter();
		createdBy.y += 220;

		// Create a new FlxText object for the "Ported by" text and set up its properties
		portedBy = new FlxText(0, 0, 0, "Ported to HaxeFlixel by Harpwood Studio", size, false);
		portedBy.color = color;
		portedBy.font = "Arial";
		portedBy.alignment = FlxTextAlign.CENTER;
		portedBy.setBorderStyle(FlxTextBorderStyle.SHADOW, shadowColor, 5);
		portedBy.screenCenter();
		portedBy.y += 250;

		// Create a new FlxSprite object to serve as the background for the
		// disclaimer in order to enhance visibility of the disclaimer text
		disclaimerBG = new FlxSprite();
		disclaimerBG.makeGraphic(FlxG.width, 220, FlxColor.BLACK);
		disclaimerBG.alpha = .3;

		// Adjust the text size for the next text
		size = 20;

		// The text content for the disclaimer
		var disclaimerText:String = "DISCLAIMER: This game has been recreated and ported to HaxeFlixel for educational and nostalgia purposes. It is important to note that the original version of this game, developed in Flash, is no longer available to play due to the End-of-Life (EOL) of Flash. I want to make it clear that I do not own the rights to this game, as the copyrights rightfully belong to their respective owners. The educational nature of this project lies in the fact that it is open-sourced, allowing everyone to access the source code and study it as a valuable HaxeFlixel resource demo. Additionally, this recreation aims to evoke nostalgia for those who enjoyed the original game.";

		// Create a new FlxText object for the disclaimer and set up its properties
		disclaimer = new FlxText(0, 0, 780, disclaimerText, size, false);
		disclaimer.color = FlxColor.WHITE;
		disclaimer.font = "Arial";
		disclaimer.bold = true;
		disclaimer.alignment = FlxTextAlign.JUSTIFY;
		disclaimer.setBorderStyle(FlxTextBorderStyle.SHADOW, shadowColor, 5);
		disclaimer.screenCenter();
		disclaimer.y -= 190;

		// Add all the elements on the credits layer
		game.creditsLayer.add(title);
		game.creditsLayer.add(clickToStart);
		game.creditsLayer.add(createdBy);
		game.creditsLayer.add(portedBy);
		game.creditsLayer.add(disclaimerBG);
		game.creditsLayer.add(disclaimer);

		// Set the visibility of the credits screen elements to false
		setVisibility();
	}

	/**
	 * Initialize the credits screen.
	 */
	public function initialize():Void
	{
		setVisibility(true);
	}

	/**
	 * Deinitialize the credits screen.
	 */
	public function deInitialize():Void
	{
		setVisibility();
	}

	/**
	 * Set the visibility of the credits screen elements.
	 * @param visible Whether the elements should be visible or not. Default is false.
	 */
	function setVisibility(visible:Bool = false):Void
	{
		title.visible = visible;
		clickToStart.visible = visible;
		createdBy.visible = visible;
		portedBy.visible = visible;
		disclaimerBG.visible = visible;
		disclaimer.visible = visible;
	}
}
