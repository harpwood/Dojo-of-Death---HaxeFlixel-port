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

import flixel.FlxG;

/**
 * Utility class for managing game audio.
 */
class Audio
{
	static public var isSoundOn(default, default):Bool = true;
	static public var isMusicOn(default, default):Bool = true;
	
	static inline final path:String = "assets/sounds/";
	static inline final wav:String = ".wav";
	
	/**
	 * Plays the sound effect for an appearance.
	 */
	public static function playAppear():Void
	{
		if (!isSoundOn) return;
		
		var id:String = Std.string(Math.ceil(Math.random() * 4));
		FlxG.sound.play(path + "appear0" + id + wav);
	}
	
	/**
	 * Plays the sound effect for a footstep.
	 */
	public static function playFootStep():Void
	{
		if (!isSoundOn) return;
		
		var id:String = Std.string(Math.ceil(Math.random() * 4));
		FlxG.sound.play(path + "footstep0" + id + wav, 0.5);
	}
	
	/**
	 * Plays the sound effect for a slash.
	 */
	public static function playSlash():Void
	{
		if (!isSoundOn) return;
		
		var id:String = Std.string(Math.ceil(Math.random() * 3));
		FlxG.sound.play(path + "slash0" + id + wav);
	}
	
	/**
	 * Plays the sound effect for a dash.
	 */
	public static function playDash():Void
	{
		if (!isSoundOn) return;
		
		var id:String = Std.string(Math.ceil(Math.random() * 2));
		FlxG.sound.play(path + "dash0" + id + wav);
	}
	
	/**
	 * Plays the sound effect for a bow hit.
	 */
	public static function playBowHit():Void
	{
		if (!isSoundOn) return;
		
		FlxG.sound.play(path + "bow_hit" + wav);
	}
	
	/**
	 * Plays the sound effect for a bow pull.
	 */
	public static function playBowPull():Void
	{
		if (!isSoundOn) return;
		
		FlxG.sound.play(path + "bow_pull" + wav);
	}
	
	/**
	 * Plays the sound effect for a bow fire.
	 */
	public static function playBowFire():Void
	{
		if (!isSoundOn) return;
		
		FlxG.sound.play(path + "bow_fire" + wav);
	}
	
	/**
	 * Plays the sound effect for a death.
	 */
	public static function playDeath():Void
	{
		if (!isSoundOn) return;
		
		FlxG.sound.play(path + "death" + wav);
	}
	
	/**
	 * Plays the game's background music.
	 * If the music is already playing, it won't restart.
	 */
	public static function playMusic():Void
	{
		if (!isMusicOn) return;
		
		if (FlxG.sound.music == null) // don't restart the music if it's already playing
			FlxG.sound.playMusic("assets/music/bgm.ogg");
	}
	
	/**
	 * Stops the game's background music.
	 */
	public static function stopMusic():Void
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();
		FlxG.sound.music = null;
	}
	
	/**
	 * Pauses the game's background music.
	 */
	public static function pauseMusic():Void
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.pause();
	}
	
	/**
	 * Resumes the game's background music.
	 */
	public static function resumeMusic():Void
	{
		if (!isMusicOn) return;
		
		FlxG.sound.music.resume();
	}
	
	/**
	 * Checks if the game's background music is currently playing.
	 *
	 * @return True if the music is playing, false otherwise.
	 */
	public static function isMusicPlaying():Bool
	{
		return FlxG.sound.music.playing;
	}
}
