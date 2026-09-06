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
 * A faint arrow that rotates around the player to hint at their current
 * facing direction. Single instance, created once and never hidden -
 * `updatePosition()` below is only ever called from
 * `GameState.updatePlayState()`, so outside the PLAY state the cursor just
 * stays frozen wherever it last was rather than disappearing.
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
		cursor.offset.x = cursor.frameWidth / 2 - 10; // fine-tuned beyond simple centering, likely to align the arrow's visual tip/pivot rather than its bounding-box center
		cursor.setSize(0, 0); // zero hitbox: purely decorative, never takes part in collision/overlap checks
		cursor.alpha = .25; // intentionally faint - a subtle hint, not a solid UI element
	}

	/**
	 * Update the position and rotation angle of the cursor.
	 * @param X 	The x-coordinate of the cursor.
	 * @param Y 	The y-coordinate of the cursor.
	 * @param angle The rotation angle IN RADIANS (matches Actor.angle,
	 * e.g. player.angle from Math.atan2 calls) - converted to degrees here
	 * since Flixel's sprite `.angle` property expects degrees, not radians.
	 */
	public function updatePosition(X:Float, Y:Float, angle:Float):Void
	{
		cursor.x = X;
		cursor.y = Y;
		cursor.angle = FlxAngle.asDegrees(angle);
	}

}