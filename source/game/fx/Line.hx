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
 * Draws the Player's attack-trail visual: a single line segment redrawn onto
 * a full-screen transparent canvas each time `drawIt()` is called.
 *
 * Unlike Blood/Smoke/StrikeLine/Arrow/ArrowBroken, this is NOT one of a pool
 * of interchangeable instances - there's exactly one `Line`, created once by
 * `Player`'s constructor and kept for the whole game. `initialize()`/
 * `deInitialize()` here just toggle the `canDraw` flag (whether the trail is
 * actively being drawn or fading out); they don't use Flixel's kill()/revive()
 * or belong to a pool group the way the FX classes' same-named methods do.
 *
 * Performance note: the backing graphic is `FlxG.width` x `FlxG.height`
 * (the full screen), and every `drawIt()` call clears and redraws that whole
 * canvas - `Player.updateThrust()` can call this several times in a single
 * frame during an attack. Fine at this game's scale, but worth knowing if a
 * fast-drawn effect like this is ever reused somewhere hotter.
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
		// canDraw == false means the attack just ended: drawIt() has stopped
		// being called, so the last-drawn line stays on the canvas as-is while
		// this just fades the whole sprite's alpha down to fully transparent.
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