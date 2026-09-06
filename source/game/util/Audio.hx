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
 * Static, stateless wrapper around `FlxG.sound` for playing this game's
 * sound effects and background music.
 *
 * Sound effect variants: several effects (appear, footstep, slash, dash) have
 * multiple numbered variants on disk (e.g. `appear01.wav` .. `appear04.wav`)
 * and a random one is picked each time to avoid repetition. The upper bound
 * in `Math.random() * N` MUST match how many numbered files actually exist -
 * if you add/remove a variant file, update that N too, or you'll either never
 * pick the new file or try to play a file that doesn't exist.
 *
 * Every playXxx() function starts with `if (!isSoundOn) return;` as a manual
 * mute switch - there's no shared helper for this, it's just repeated at the
 * top of each function below.
 */
class Audio
{
	static public var isSoundOn(default, default):Bool = true;
	static public var isMusicOn(default, default):Bool = true;
	
	static inline final path:String = "assets/sounds/";
	static inline final wav:String = ".wav";
	
	/**
	 * Plays a random "actor appeared" sound (4 variants: appear01-04.wav).
	 */
	public static function playAppear():Void
	{
		if (!isSoundOn) return;
		
		var id:String = Std.string(Math.ceil(Math.random() * 4));
		FlxG.sound.play(path + "appear0" + id + wav);
	}
	
	/**
	 * Plays a random footstep sound (4 variants: footstep01-04.wav), quieter
	 * than other effects (fixed volume 0.5) since it repeats often.
	 */
	public static function playFootStep():Void
	{
		if (!isSoundOn) return;
		
		var id:String = Std.string(Math.ceil(Math.random() * 4));
		FlxG.sound.play(path + "footstep0" + id + wav, 0.5);
	}
	
	/**
	 * Plays a random melee slash sound (3 variants: slash01-03.wav).
	 */
	public static function playSlash():Void
	{
		if (!isSoundOn) return;
		
		var id:String = Std.string(Math.ceil(Math.random() * 3));
		FlxG.sound.play(path + "slash0" + id + wav);
	}
	
	/**
	 * Plays a random dash/lunge sound (2 variants: dash01-02.wav).
	 */
	public static function playDash():Void
	{
		if (!isSoundOn) return;
		
		var id:String = Std.string(Math.ceil(Math.random() * 2));
		FlxG.sound.play(path + "dash0" + id + wav);
	}
	
	/**
	 * Plays the sound for an arrow hitting/being blocked (single fixed file,
	 * no numbered variants).
	 */
	public static function playBowHit():Void
	{
		if (!isSoundOn) return;
		
		FlxG.sound.play(path + "bow_hit" + wav);
	}
	
	/**
	 * Plays the sound for a bow ninja drawing/charging its bow.
	 */
	public static function playBowPull():Void
	{
		if (!isSoundOn) return;
		
		FlxG.sound.play(path + "bow_pull" + wav);
	}
	
	/**
	 * Plays the sound for a bow ninja releasing an arrow.
	 */
	public static function playBowFire():Void
	{
		if (!isSoundOn) return;
		
		FlxG.sound.play(path + "bow_fire" + wav);
	}
	
	/**
	 * Plays the player death sound.
	 */
	public static function playDeath():Void
	{
		if (!isSoundOn) return;
		
		FlxG.sound.play(path + "death" + wav);
	}
	
	/**
	 * Starts the background music, unless it's muted (`isMusicOn == false`)
	 * or already playing. Called every time gameplay starts/restarts
	 * (see `GameState.setState`, PLAY case).
	 *
	 * Note: if `isMusicOn` is false the first time this runs, `FlxG.sound.music`
	 * is simply never assigned (stays null) - see the warning on
	 * `isMusicPlaying()` below for why that matters.
	 */
	public static function playMusic():Void
	{
		if (!isMusicOn) return;
		
		if (FlxG.sound.music == null) // don't restart the music if it's already playing
			FlxG.sound.playMusic("assets/music/bgm.ogg");
	}
	
	/**
	 * Stops the background music completely and clears `FlxG.sound.music`
	 * back to null (as opposed to `pauseMusic()`, which keeps the Sound
	 * object alive so it can be resumed). Called on player death.
	 */
	public static function stopMusic():Void
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();
		FlxG.sound.music = null;
	}
	
	/**
	 * Pauses the background music in place (keeps `FlxG.sound.music` alive,
	 * unlike `stopMusic()`), so `resumeMusic()` can continue it later.
	 */
	public static function pauseMusic():Void
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.pause();
	}
	
	/**
	 * Resumes previously-paused background music.
	 *
	 * Caution: does not null-check `FlxG.sound.music` before calling
	 * `.resume()` on it. Only safe to call if music has actually been
	 * started at least once via `playMusic()` (see the note there and on
	 * `isMusicPlaying()` below).
	 */
	public static function resumeMusic():Void
	{
		if (!isMusicOn) return;
		
		FlxG.sound.music.resume();
	}
	
	/**
	 * Checks if the game's background music is currently playing.
	 *
	 * Caution: does not null-check `FlxG.sound.music`. This will throw if
	 * called before music has ever been started - which can genuinely happen:
	 * if the player disables music (`isMusicOn = false`) before ever starting
	 * gameplay, `playMusic()`'s early-return means `FlxG.sound.music` stays
	 * null. Re-enabling music via the 'M' key during play
	 * (see `UserInput.update()`) calls this function first, which would then
	 * crash on the null `.playing` access. Not fixed here - only documented.
	 *
	 * @return True if the music is playing, false otherwise.
	 */
	public static function isMusicPlaying():Bool
	{
		return FlxG.sound.music.playing;
	}
}
