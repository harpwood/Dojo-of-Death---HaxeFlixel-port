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

import flixel.FlxSprite;
import flixel.math.FlxAngle;
import game.GameState;

/*
 * Class representing an arrow sprite that rotates around the player, pointing to his direction.
 */
class Cursor
{
	var cursor:FlxSprite;

	public function new(game:GameState):Void
	{
		// Create a new FlxSprite object for the cursor, centers its origin and adds it to the game
		cursor = new FlxSprite();
		cursor.loadGraphic("assets/images/cursor.png", false);
		cursor.centerOrigin();
		game.add(cursor);

		// Adjust the offset, size, alpha
		cursor.offset.x = cursor.frameWidth / 2 - 10;
		cursor.setSize(0, 0);
		cursor.alpha = .25;
	}

	/**
	 * Update the position and rotation angle of the cursor.
	 * @param X 	The x-coordinate of the cursor.
	 * @param Y 	The y-coordinate of the cursor.
	 * @param angle The rotation angle of the cursor.
	 */
	public function updatePosition(X:Float, Y:Float, angle:Float):Void
	{
		cursor.x = X;
		cursor.y = Y;
		cursor.angle = FlxAngle.asDegrees(angle);
	}

}