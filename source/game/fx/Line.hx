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

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

/**
 * Represents a line sprite used for visual effects in the game.
 * The line sprite is used to draw a line between two points, creating a trail effect.
 */
class Line extends FlxSprite
{
	// The draw properties of the line
	var lineStyle:LineStyle = {color: FlxColor.WHITE, thickness: 10};
	var drawStyle:DrawStyle = {smoothing: false};
	
	// Flag indicating if the line can be drawn
	var canDraw:Bool = false; 

	public function new()
	{
		super(0, 0, null);

		// Create a transparent canvas for the line to be drawn
		var color:FlxColor = FlxColor.TRANSPARENT;
		makeGraphic(FlxG.width, FlxG.height, color);

		// The initial alpha value of the line
		alpha = 0.5;
	}
	
	/**
	 * Prepare the line to be ready for drawing
	 */
	public function initialize():Void
	{
		alpha = 0.5;
		canDraw = true;
		drawIt(0, 0, 0, 0);
	}
	
	public function deInitialize():Void
	{
		canDraw = false;
	}

	override public function update(elapsed:Float):Void
	{
		// If the line cannot be drawn, fade it out gradually over time
		if (!canDraw) alpha = Math.max(alpha - elapsed, 0);
	}

	/**
	* Draws a line between two points.
	*
	* @param x1 The x-coordinate of the starting point.
	* @param y1 The y-coordinate of the starting point.
	* @param x2 The x-coordinate of the ending point.
	* @param y2 The y-coordinate of the ending point.
	*/
	public function drawIt(x1:Float, y1:Float, x2:Float, y2:Float):Void
	{
		// Erase the previous line by filling the canvas with a transparent color
		this.fill(FlxColor.TRANSPARENT);

		// Draw the next line on the canvas using the provided points and line style
		this.drawLine(x1, y1, x2, y2, lineStyle, drawStyle);
	}

}