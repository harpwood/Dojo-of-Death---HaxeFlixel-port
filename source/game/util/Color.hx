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
 * Central place for the game's color palette, plus one small color-interpolation helper.
 */
class Color
{

	static public inline final RED:FlxColor 				= 0xFFDA0000;    // Main UI/HUD color (score, multiplier, game over text).
	static public inline final GREY:FlxColor 				= 0xFFD3C7BC;    // Smoke particle color.
	static public inline final YELLOW:FlxColor 				= 0xFFFFEA00;    // Broken arrow piece color.
	static public inline final ORANGE:FlxColor 				= 0xFFC3A255;    // Credits screen attribution text color.
	static public inline final TRANSPARENT_BLACK:FlxColor 	= 0x22000000;    // Subtle drop-shadow behind text (low alpha).
	static public inline final SEMI_TRANSP_BLACK:FlxColor 	= 0x55000000;    // Pause screen dimming overlay (higher alpha than TRANSPARENT_BLACK).

	/**
	 * Interpolates a color for the "flashing" combo multiplier text.
	 *
	 * Expects `timer` to run from 1 down to 0 (as it does in
	 * `GameState.updateMultiplier`, where it's reset to 1 each time the player
	 * scores and then counts down every frame). At timer == 1 this returns
	 * white; as the timer counts DOWN toward 0 it fades toward RED, landing
	 * exactly on RED once the timer reaches 0. Passing a timer outside the
	 * 0..1 range isn't supported (the color channels aren't clamped).
	 *
	 * @param timer Countdown value in the 0..1 range (1 = just triggered, 0 = expired).
	 * @return White at timer 1, fading to RED as timer approaches 0.
	 */
	static public function get(timer:Float):FlxColor
	{
		if (timer <= 0) return Color.RED;

		// Red channel is interpolated between RED's own red value (218, i.e. 0xDA)
		// and white's (255), while green/blue go from 0 (RED has none) up to 255 (white).
		// This is why timer == 0 naturally lands on the same value as Color.RED.
		var red:Int = 218 + Math.round((255 - 218) * timer);
		var green:Int = Math.round(255 * timer);
		var blue:Int = Math.round(255 * timer);

		return FlxColor.fromRGB(red, green, blue);
	}
}
