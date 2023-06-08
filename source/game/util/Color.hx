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

package game.util;

import flixel.util.FlxColor;

/**
 * Utility class for defining colors used in the game.
 */
class Color
{

	static public inline final RED:FlxColor 				= 0xFFDA0000;    // The color red.
	static public inline final GREY:FlxColor 				= 0xFFD3C7BC;    // The color grey.
	static public inline final YELLOW:FlxColor 				= 0xFFFFEA00;    // The color yellow.
	static public inline final ORANGE:FlxColor 				= 0xFFC3A255;    // The color orange.
	static public inline final TRANSPARENT_BLACK:FlxColor 	= 0x22000000;    // The color black with transparency.
	static public inline final SEMI_TRANSP_BLACK:FlxColor 	= 0x55000000;    // The color black with transparency.

	/**
	 * Returns a color based on the given timer value.
	 * The color transitions from white to red as the timer increases.
	 *
	 * @param timer The timer value used to determine the color.
	 * @return The corresponding color based on the timer value.
	 */
	static public function get(timer:Float):FlxColor
	{
		if (timer <= 0) return Color.RED;
		//218 + (255 - 218)
		var red:Int = 218 + Math.round((255 - 218) * timer);
		var green:Int = Math.round(255 * timer);
		var blue:Int = Math.round(255 * timer);

		return FlxColor.fromRGB(red, green, blue);
	}
}
