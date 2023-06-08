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

package game.arrows;

import flixel.FlxSprite;
import flixel.math.FlxAngle;
import flixel.system.FlxAssets.FlxGraphicAsset;
import game.util.Color;
import game.GameState;
import game.util.Direction;

/**
 * Represents a broken arrow part projectile in the game.
 * When an arrow breaks, is splitted into two parts.
 * To fully represent a broken arrow, two ArrowBroken instanses are used.
 * It is stored in a pool available to be reused.
 * It provides movement and visual effects when an arrow breaks.
 */
class ArrowBroken extends FlxSprite
{
	var game:GameState;		// The parent FlxState instance reference
	var dx:Float;			// The horizontal speed of the broken arrow part
	var dy:Float;			// The vertical speed of the broken arrow part
	var rotation:Float;		// The rotation speed of the broken arrow part
	
	public var isActive(default, null):Bool;	// Flag indicating if the broken arrow is currently being used

	/**
	 * Creates a new ArrowBroken instance.
	 *
	 * @param game 			The parent GameState instance that manages the game (FlxState).
	 * @param X 			The initial x-coordinate of the broken arrow.
	 * @param Y 			The initial y-coordinate of the broken arrow.
	 * @param SimpleGraphic The graphic asset for the broken arrow.
	 */
	public function new(game:GameState, ?X:Float = 0, ?Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset):Void
	{
		super(X, Y, SimpleGraphic);
		this.game = game;
		
		// Create a graphic for the broken arrow
		makeGraphic(22, 4, Color.YELLOW);
		
		// Set the offset for the broken arrow
		offset.set(11, 2);
		
		// Deinitialize the broken arrow and add it to the arrowsBroken pool
		deInitialize();
		game.arrowsBroken.add(this);
	}

	/**
	 * Initializes the broken arrow with the specified direction and position.
	 *
	 * @param direction The direction of the broken arrow (left or right).
	 * @param X 		The x-coordinate of the broken arrow.
	 * @param Y 		The y-coordinate of the broken arrow.
	 */
	public function initialize(direction:Int, X:Float, Y:Float):Void
	{
		// Revive the broken arrow to make it visible and usable
		revive();
		
		// Determine the sign (direction modifier) based on the arrow part direction
		var sign:Int = (direction == Direction.LEFT) ? -1 : 1;
		
		// Apply the velocity modifier on the x-axis with the determined direction
		dx = (Math.random() * 40 + 60) * sign;
		
		// Set the velocity modifier on the y-axis
		dy = (Math.random() * 100 + 300); 
		
		// Set the initial rotation speed, position, and alpha of the broken arrow
		rotation = 16 * sign;
		x = X;
		y = Y;
		alpha = 1;
		angle = 0;
		
		// Mark the broken arrow that is being used
		isActive = true;
	}

	/**
	 * Deactivates the broken arrow. It can be reused anytime.
	 */
	function deInitialize():Void
	{
		isActive = false;
		kill();
	}
	
	/**
	 * Updates the broken arrow's position and visual effects.
	 *
	 * @param elapsed The time elapsed since the last update.
	 */
	override public function update(elapsed:Float):Void
	{
		// Update the position, rotation, and visual effects of the broken arrow
		dy -= 650 * elapsed; 	// Apply gravity on the y-axis modifier
		x += dx * elapsed;		// Apply the horizontal velocity
		y -= dy * elapsed;		// Apply the vertical velocity
		angle += FlxAngle.asDegrees(rotation * elapsed); // Apply the rotation
		alpha -= 0.03;	// Fade it out
		
		// Deinitialize the broken arrow if its alpha value reaches 0
		if (alpha <= 0) deInitialize();
	}
}
