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

package game;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import game.Background;
import game.actors.Ninja;
import game.actors.Player;
import game.arrows.Arrow;
import game.arrows.ArrowBroken;
import game.fx.Blood;
import game.fx.Smoke;
import game.fx.StrikeLine;
import game.ui.Cursor;
import game.ui.Credits;
import game.ui.GameOver;
import game.ui.UserInput;
import game.util.Audio;
import game.util.Color;
import game.util.State;
import game.util.Type;
import openfl.filters.BitmapFilter;
import openfl.filters.BlurFilter;
import openfl.filters.ColorMatrixFilter;

/**
 * The main FlxState of the game: the central hub that owns and wires together
 * every other subsystem (player, ninjas, background, pooled FX/projectiles,
 * UI, cameras, scoring). Most other classes reach each other only through a
 * `game:GameState` reference passed in at construction.
 */
class GameState extends FlxState
{

	// Variable to hold an instance of the UserInput class
	var ui				:UserInput;

	// Camera variables
	var uiCamera: FlxCamera; 				// Variable to hold the UI camera
	var gCamera: FlxCamera; 				// Variable to hold the game elements camera
	var blurFilter: BlurFilter; 			// Variable to hold a blur filter for camera effects
	var bF: Float; 							// Variable to control the blur factor
	var grayScaleFilter: ColorMatrixFilter; // Variable to hold a grayscale filter for camera effects
	var dV: Float; 							// Variable to control the decreasing over time values of grayScaleFilter
	var iV: Float; 							// Variable to control the increasing over time values of grayScaleFilter

	// Variable to hold the background object
	public var bg: Background;

	// Variable to hold the player object
	public var player: Player;
	// Array to hold the ninja enemies (not the FlxSprites)
	public var ninjas: Array<Ninja>;

	// The groups that hold both the player and the enemies sprites with their shadows
	public var actors: FlxTypedGroup<FlxSprite>; 	// Group to hold the actor objects of type FlxSprite
	public var shadows: FlxSpriteGroup; 			// Group to hold the shadow objects of type FlxSprite

	// Pooling groups of various visual elements
	public var bloods: FlxTypedGroup<Blood>; 				// Group to hold the blood objects of type Blood
	public var arrows: FlxTypedGroup<Arrow>; 				// Group to hold the arrow objects of type Arrow
	public var arrowsBroken: FlxTypedGroup<ArrowBroken>; 	// Group to hold the broken arrow objects of type ArrowBroken
	public var smokes: FlxTypedGroup<Smoke>; 				// Group to hold the smoke objects of type Smoke
	public var strikes: FlxTypedGroup<StrikeLine>; 			// Group to hold the strike line objects of type StrikeLine

	// Game over variables
	var gameOver:GameOver;				// The game over screen
	public var gameOverLayer: FlxGroup; // Group to hold all game over screen objects

	// Credits variables
	var credits:Credits;				// The credits elements of the game
	public var creditsLayer: FlxGroup; 	// Group to hold all the credits elements objects

	// The cursor object representing an arrow shape that indicates the current direction of the player
	var cursor:Cursor;

	// Variables related to enemy spawning
	var maxNinjas:Int;		// The maximum number of alive ninjas that can be in the game
	var spawnTimer:Float;	// The current timer for spawning enemies
	var spawnLength:Float;	// The total duration until the next spawn

	// Score variables
	public var score(default, default): Int;  	// The current score of the player
	var scoreText: FlxText;                   	// The text display for the score
	var multiplier: Int;                      	// The current score multiplier
	var multiplierText: FlxText;				// The text display for the multiplier
	var multiplierTimer: Float;                 // The remaining time before multiplier resets
	var bestMultiplier: Int;                    // The highest achieved multiplier in the game
	var kills: Int;                             // The total number of kills by the player

	/**
	* The current state of the game.
	*
	* This variable represents the current state of the game, which can be one of the following values:
	* - State.INTRO: 		Represents the initial state of the game.
	* - State.PLAY: 		Represents the game play state of the game.
	* - State.GAME_OVER: 	Represents the game over state of the game.
	* - `State.RESET`: 		Represents the state of the game when resetting its elements in preparation for a new play session.
	*
	* Note: these "game states" are one of THREE unrelated families of state
	* constants that happen to share integer values (see the warning in
	* `State.hx`) - don't confuse this field with `Actor.state` (RUN/CHARGE/...)
	* or `StrikeLine.state` (GROW/SHRINK), which are separate concepts.
	*/
	var state: Int;

	/**
	* Initializes the game state.
	* This function is called when the game state is first created.
	* It sets up the initial state of the game, including creating instances of objects,
	* setting up cameras, adding groups and objects to the game state, and setting the initial game state.
	*/
	override public function create():Void
	{
		super.create();

		// Instantiate the bg, pooling groups and rest of ui and game elements
		ui 				= new UserInput(this);
		bg 				= new Background(this);
		ninjas 			= new Array<Ninja>();
		shadows 		= new FlxSpriteGroup();
		actors 			= new FlxTypedGroup<FlxSprite>();
		player 			= new Player(this);
		bloods 			= new FlxTypedGroup<Blood>();
		arrows 			= new FlxTypedGroup<Arrow>();
		arrowsBroken 	= new FlxTypedGroup<ArrowBroken>();
		smokes 			= new FlxTypedGroup<Smoke>();
		strikes 		= new FlxTypedGroup<StrikeLine>();
		cursor 			= new Cursor(this);
		applyScoreElements();
		gameOverLayer 	= new FlxGroup();
		gameOver 		= new GameOver(this);
		creditsLayer 	= new FlxGroup();
		credits 		= new Credits(this);

		// Initialize the cameras
		initCamera();

		// `FlxG.cameras.setDefaultDrawTarget()` sets which camera newly-`add()`ed
		// objects are drawn to BY DEFAULT - it's global, mutable state, not tied
		// to the objects themselves. The pattern below is: point the default at
		// gCamera, add() all the gameplay-layer groups (so they land on
		// gCamera), then flip the default to uiCamera and add() the UI-layer
		// objects, then flip back to gCamera as the steady-state default for
		// the rest of the game's lifetime (e.g. anything added later).
		FlxG.cameras.setDefaultDrawTarget(gCamera, true);
		FlxG.cameras.setDefaultDrawTarget(uiCamera, false);

		// Add the game element groups to the display tree
		add(shadows);
		add(actors);
		add(bloods);
		add(arrows);
		add(arrowsBroken);
		add(smokes);
		add(strikes);

		// target camera to ui elements
		FlxG.cameras.setDefaultDrawTarget(gCamera, false);
		FlxG.cameras.setDefaultDrawTarget(uiCamera, true);

		// Make the ui elements to be drawn by uiCamera
		var c:Array<FlxCamera> = [uiCamera];
		scoreText.cameras 		= c;
		multiplierText.cameras	= c;
		gameOverLayer.cameras 	= c;
		creditsLayer.cameras 	= c;

		// Add the ui element groups to the display tree
		add(scoreText);
		add(multiplierText);
		add(gameOverLayer);
		add(creditsLayer);

		// target camera to game elements (steady-state default from here on)
		FlxG.cameras.setDefaultDrawTarget(gCamera, true);
		FlxG.cameras.setDefaultDrawTarget(uiCamera, false);

		// Set the initial state
		state = State.INTRO;

		// Start the game
		start();
	}

	/**
	 * ---------------------------------------------
	 *
	 *  INITIALIZATION - DEINITIALIZATION FUNCTIONS
	 *
	 * ---------------------------------------------
	 */

	/**
	 * Initialize the game and the credits
	 */
	function start():Void
	{
		initialize();
		credits.initialize();
	}

	/**
	 * Initialize the core variables of the game
	 */
	function initialize():Void
	{
		// init values
		maxNinjas = 5;
		spawnTimer = 0.5;
		spawnLength = 0.5;
		score = 0;
		multiplier = 1;
		multiplierTimer = 0;
		bestMultiplier = 1;
		kills = 0;
		scoreText.text = "0";
		multiplierText.text = "x1";
	}

	/**
	 * Resets the game. You call this after a game over to prepare a new game session
	 */
	function reset():Void
	{
		// remove the ninja objects and their sprites
		var i = ninjas.length;
		while (i > 0)
		{
			i--;
			var ninja:Ninja = ninjas[i];
			ninja.deInitialize();
			ninjas.remove(ninja);
			ninja = null; // no-op: `ninja` is a local that goes out of scope next iteration anyway; Haxe doesn't need this for cleanup. Same harmless pattern appears again in updatePlayState() below.
		}

		// Clean the background from the "stamped" corpses
		bg.removeCorpses();

		// Deinitialize the necessary elements
		player.deInitialize();
		gameOver.deInitialize();

		// Reset the cameras
		resetCameraFX();
		updateCamera();
	}

	/**
	 * ---------------------------------------------
	 *
	 *		 		UPDATE FUNCTION
	 *
	 * ---------------------------------------------
	 */

	/**
	 * Updates the game state.
	 *
	 * Note: case labels are raw ints matching State.* (see State.hx), same as
	 * the switches in Player/Ninja. There's no case for State.INTRO (0):
	 * nothing needs per-frame updating on the title screen besides `ui.update()`
	 * above - the "click to start" transition is handled separately by
	 * UserInput's mouse listener, not through this per-frame switch.
	 *
	 * @param elapsed The time elapsed since the last update, in seconds.
	 */
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		// Update the user input
		ui.update();

		// Handle different game states
		switch (state)
		{
			case 1: //PLAY
				updatePlayState(elapsed);

			case 2: //GAME_OVER
				updateGameOverState(elapsed);
		}
	}

	/**
	 * ---------------------------------------------
	 *
	 *		 		GET-SET FUNCTIONS
	 *
	 * ---------------------------------------------
	 */

	/**
	* Sets the pause state of the game.
	*
	* @param pause True to pause the game, false to resume.
	*/
	public function setPause(pause:Bool):Void
	{
		if (pause) ui.pause();
		else ui.resume();
	}

	/**
	* Retrieves the current state.
	*
	* @return The current state as an Int value.
	*/
	public function getState():Int
	{
		return state;
	}

	/**
	* Sets the state to the specified State value.
	* Handles the logic between state transitions.
	*
	* Note: entering PLAY behaves differently depending on where you're coming
	* from. From INTRO, everything is already freshly set up by create()/start()
	* - only the credits need to be hidden. From GAME_OVER (restarting after a
	* death), the previous round's leftovers (dead ninjas, stamped corpses,
	* score) are still around and must be cleared first via reset()+initialize().
	* The only caller of setState(State.INTRO) is GameOver's 30-second
	* auto-reset timer (see GameOver.update()).
	*
	* @param state The new state to set.
	*/
	public function setState(state:Int):Void
	{
		switch (state)
		{
			case 0: // INTRO
				reset();
				start();

			case 1: //PLAY
				// If the current state is INTRO, deinitialize the credits.
				if (this.state == State.INTRO) credits.deInitialize();
				else
				{
					// Otherwise, reset and initialize the game.
					reset();
					initialize();
				}
				Audio.playMusic();
				scoreElementsVisibility(true);
				player.initialize();

			case 2: //GAME OVER
				scoreElementsVisibility(false);
				applyCameraFX();
				gameOver.inititialize(kills, score, bestMultiplier);
		}

		// Update the current state
		this.state = state;
	}

	/**
	 * ---------------------------------------------
	 *
	 *			PRIVATE STATE FUNCTIONS
	 *
	 * ---------------------------------------------
	 */

	/**
	* Updates the game during the PLAY state.
	*
	* @param elapsed The elapsed time since the last update.
	*/
	function updatePlayState(elapsed:Float):Void
	{
		// Update the player logic
		player.update(elapsed);

		// Two-pass removal: collect dead ninjas here first rather than calling
		// ninjas.remove() while iterating the array above. Removing elements
		// mid-loop would shift every later index down by one, causing this
		// loop (which walks a fixed 0...ninjas.length range) to skip the
		// element that slides into the just-vacated slot. Doing all the
		// removals in a separate pass afterward avoids that.
		var ninjasToRemove:Array<Ninja> = [];

		for (i in 0...ninjas.length)
		{
			// Update each ninja's logic
			ninjas[i].update(elapsed);
			// Check if its state is NO_STATE
			// Ninjas with NO_STATE are dead and their corpses are stamped on the bg
			if (ninjas[i].state == State.NO_STATE)
				ninjasToRemove.push(ninjas[i]);	// Copy the dead ninja into the array to be destroyed
		}

		// Remove the ninjas that need to be removed from the ninjas array and destroy them
		for (j in 0...ninjasToRemove.length)
		{
			var i:Int = ninjas.indexOf(ninjasToRemove[j]);
			var ninja:Ninja = ninjas[i];
			ninjas.remove(ninja);
			ninja = null; // no-op, see the same pattern in reset() above
		}

		// Update the cursor that shows the player's direction
		cursor.updatePosition(player.x, player.y, player.angle);

		// Sort the actors in the scene by their Y-coordinate to determine their display order
		actors.sort(FlxSort.byY);

		// Spawn new enemies if necessary
		spawnEnemies(elapsed);

		// Update the combo multiplier
		updateMultiplier(elapsed);

		// Check if the difficulty level should be raised
		checkDifficulty();
	}

	/**
	* Updates the game logic during the GAME OVER state.
	*
	* @param elapsed The elapsed time since the last update.
	*/
	function updateGameOverState(elapsed:Float):Void
	{
		// Update the game over logic
		gameOver.update(elapsed);

		// Update the camera to apply the active visual filters
		// The filters include blur and saturation effects
		updateCamera();
	}

	/**
	 * ---------------------------------------------
	 *
	 * 				PRIVATE FUNCTIONS
	 *
	 * ---------------------------------------------
	 */

	/**
	* Spawns enemies at regular intervals based on elapsed time.
	* The enemy spawning is controlled by the spawnTimer and maxNinjas variables.
	*
	* Note: `spawnLength` (adjusted by checkDifficulty() below) can go negative
	* at high difficulty (floor of -0.5 once kills reach 200). Since
	* `Math.random()` only adds up to 1, a very negative spawnLength can make
	* the new spawnTimer land at or below zero immediately, so at max
	* difficulty ninjas spawn almost every frame - the only thing still
	* limiting them at that point is the `maxNinjas` cap just below.
	*
	* @param elapsed The elapsed time since the last update.
	*/
	function spawnEnemies(elapsed: Float): Void
	{
		// Check if the player is alive, if not, do not spawn enemies
		if (!player.alive) return;

		// Calculate the current number of active ninjas
		var ninjaCount = activeNinjas();

		// Decrease the spawn timer based on elapsed time
		spawnTimer -= elapsed;

		// Check if it's time to spawn a new enemy
		if (spawnTimer <= 0)
		{
			// Check if the maximum number of ninjas has not been reached
			if (ninjaCount < maxNinjas)
				addNinja();	// Spawn a new ninja

			// Reset the spawn timer with a minor random variation
			spawnTimer = Math.random() + spawnLength;
		}
	}

	/**
	* Counts the number of active (alive) ninjas in the game.
	*
	* @return The number of active ninjas.
	*/
	function activeNinjas():Int
	{
		// The var that will count the active ninjas
		var count:Int = 0;

		// Loop through all ninjas
		for (i in 0...ninjas.length)
		{
			// if the ninja is alive count him as active
			if (ninjas[i].alive) count++;
		}
		return count;
	}

	/**
	* Adds a new ninja enemy to the game.
	* The type of ninja (Type.SWORD(=0) or Type.BOW(=1)) is randomly determined.
	*/
	function addNinja():Void
	{
		// Randomly determine the type of ninja (80% Sword, 20% Bow)
		var type = Math.random() > 0.2 ? Type.SWORD : Type.BOW;

		// Create a new instance of the Ninja class
		var ninja = new Ninja(this);

		// Initialize the ninja with the determined type
		ninja.initialize(type);

		// Add the ninja to the ninjas array
		ninjas.push(ninja);
	}

	/**
	* Adjusts the game difficulty based on the player's kills.
	* Modifies the maximum number of ninjas and spawn length.
	*
	* Concrete milestones: `maxNinjas` gains +1 every 10 kills (starts at 5).
	* `spawnLength` shrinks toward its floor of -0.5, reaching that floor
	* exactly at 200 kills and staying there beyond it (see spawnEnemies()
	* above for what a negative spawnLength does).
	*/
	public function checkDifficulty():Void
	{
		// Update the maxNinjas based on the kills of the player
		maxNinjas = Std.int(kills / 10) + 5;

		// Decrease the time until the next spawn
		spawnLength = Math.max(0.5 - kills / 100 * 0.5, -0.5);
	}

	/**
	 * ---------------------------------------------
	 *
	 *			PUBLIC POOLING FUNCTIONS
	 *
	 * ---------------------------------------------
	 */

	/**
	* Adds a blood effect at the specified coordinates.
	*
	* Pooling pattern used by every addXxx() function below: ask the pool
	* group to `recycle()` a currently-inactive member (Flixel picks one for
	* you), or create a brand new one if the pool has none free yet. The
	* `if (x.isActive) addXxx(...)` retry guards against the rare case where
	* `recycle()` had to hand back something still in use (pool momentarily
	* exhausted) - it just tries again, since a freshly-`new`'d instance is
	* never itself already active (its constructor always calls
	* `deInitialize()` - see e.g. Blood.hx's constructor).
	*
	* @param X The x-coordinate of the blood effect.
	* @param Y The y-coordinate of the blood effect.
	*/
	public function addBlood(X:Float, Y:Float):Void
	{
		// Skip 3 out of 4 requests - addBlood() is called every frame during a
		// ninja's death animation (see Ninja.updateDeathState()), so spawning
		// a full blood particle every single frame would be far too dense;
		// this throttles the visible rate down to roughly 1 in 4 frames.
		if (Math.random() < 0.25) return;

		// Recycle a blood instance from the bloods pool
		var blood:Blood = bloods.recycle();

		// If no blood instance is available in the pool, create a new one
		if (blood == null) blood = new Blood(this);

		// Check if the blood instance is already in use
		// If in use, recursively call the function to try again
		if (blood.isActive) addBlood(X, Y);
		// If not in use, initialize the blood instance at the specified coordinates
		else blood.initialize(X, Y);
	}

	/**
	* Adds an arrow at the specified angle and coordinates.
	* Same recycle-or-create(-then-retry) pooling pattern as addBlood() above.
	*
	* @param angle The angle of the arrow.
	* @param X The x-coordinate of the arrow.
	* @param Y The y-coordinate of the arrow.
	*/
	public function addArrow(angle:Float, X:Float, Y:Float):Void
	{
		// Recycle an arrow instance from the arrows pool
		var arrow:Arrow = arrows.recycle();

		// If no arrow instance is available in the pool, create a new one
		if (arrow == null) arrow = new Arrow(this);

		// Check if the arrow instance is already in use
		// If in use, recursively call the function to try again
		if (arrow.isActive) addArrow(angle, X, Y);
		// If not in use, initialize the arrow instance with the specified angle and coordinates
		else arrow.initialize(angle, X, Y);
	}

	/**
	* Adds a broken arrow effect at the specified direction and coordinates.
	* Same recycle-or-create(-then-retry) pooling pattern as addBlood() above.
	*
	* @param direction The direction of the broken arrow effect. It should be either Direction.LEFT or Direction.RIGHT.
	* @param X The x-coordinate of the broken arrow effect.
	* @param Y The y-coordinate of the broken arrow effect.
	*/
	public function addArrowBroken(direction:Int, X:Float, Y:Float):Void
	{
		// Recycle an arrowBroken instance from the arrowsBroken pool
		var arrowBroken:ArrowBroken = arrowsBroken.recycle();

		// If no arrowBroken instance is available in the pool, create a new one
		if (arrowBroken == null) arrowBroken = new ArrowBroken(this);

		// Check if the arrowBroken instance is already in use
		// If in use, recursively call the function to try again
		if (arrowBroken.isActive) addArrowBroken(direction, X, Y);
		// If not in use, initialize the arrowBroken instance with the specified direction and coordinates
		else arrowBroken.initialize(direction, X, Y);
	}

	/**
	* Adds a smoke effect at the specified coordinates.
	* Same recycle-or-create(-then-retry) pooling pattern as addBlood() above.
	*
	* @param X The x-coordinate of the smoke effect.
	* @param Y The y-coordinate of the smoke effect.
	*/
	public function addSmoke(X: Float, Y: Float):Void
	{
		// Recycle a smoke instance from the smokes pool
		var smoke:Smoke = smokes.recycle();

		// If no smoke instance is available in the pool, create a new one
		if (smoke == null) smoke = new Smoke(this);

		// Check if the smoke instance is already in use
		// If in use, recursively call the function to try again
		if (smoke.isActive) addSmoke(X, Y);
		// If not in use, initialize the smoke instance at the specified coordinates
		else smoke.initialize(X, Y);
	}

	/**
	* Adds a strike line effect at the specified coordinates.
	* Same recycle-or-create(-then-retry) pooling pattern as addBlood() above.
	*
	* @param X The x-coordinate of the strike line effect.
	* @param Y The y-coordinate of the strike line effect.
	*/
	public function addStrike(X:Float, Y:Float):Void
	{
		// Recycle a strike line instance from the strikes pool
		var strike:StrikeLine = strikes.recycle();

		// If no strike line instance is available in the pool, create a new one
		if (strike == null) strike = new StrikeLine(this);

		// Check if the strike line instance is already in use
		// If in use, recursively call the function to try again
		if (strike.isActive) addStrike(X, Y);
		// If not in use, initialize the strike line instance at the specified coordinates
		else strike.initialize(X, Y);
	}

	/**
	 * ---------------------------------------------
	 *
	 *			SCORE RELATED FUNCTIONS
	 *
	 * ---------------------------------------------
	 */

	/**
	* Initializes and applies the score elements in the game.
	* This includes the score text and multiplier text.
	*/
	function applyScoreElements():Void
	{
		// Define the color for the score elements
		var color:FlxColor = Color.RED;

		// Create the score text object
		scoreText = new FlxText(25, 0, 300, "0", 50, false);
		scoreText.color = color;
		scoreText.font = "assets/fonts/Zenzai_Itacha.ttf";

		// Create the multiplier text object
		multiplierText = new FlxText(650, 450, 300, "x1", 80, false);
		multiplierText.color = color;
		multiplierText.font = "assets/fonts/Zenzai_Itacha.ttf";

		// Set the visibility of the score elements to false
		scoreElementsVisibility();
	}

	/**
	* Sets the visibility of the score elements.
	*
	* @param visible Determines whether the score elements should be visible or not.
	*/
	function scoreElementsVisibility(visible:Bool = false)
	{
		scoreText.visible = visible;
		multiplierText.visible = visible;
	}

	/**
	* Adds score based on the current multiplier and updates the score display.
	*/
	public function addScore():Void
	{
		// Calculate the score based on the multiplier
		var resultedScore = 100 * multiplier;

		// Increment the total score
		score += resultedScore;

		// Update the score text display
		scoreText.text = Std.string(score);

		// Increment the multiplier
		multiplier++;

		// Update the multiplier text display
		multiplierText.text = "x" + Std.string(multiplier);

		// Increment the number of kills
		kills++;

		// Reset the multiplier timer
		multiplierTimer = 1;

		// Update the best multiplier if the current multiplier surpasses it
		if (multiplier > bestMultiplier)
			bestMultiplier = multiplier;
	}

	/**
	* Updates the multiplier timer and its visual representation.
	*
	* @param elapsed The elapsed time since the last update.
	*/
	function updateMultiplier(elapsed:Float):Void
	{
		// Decrease the multiplier timer based on the elapsed time
		multiplierTimer -= elapsed;

		// Update the color of the multiplier text based on the remaining timer
		/** This is "flashing" color effect. The multiplierText is "flashing" to
		 * white color and transition to its original red color when the timer expires
		 */
		multiplierText.color = Color.get(multiplierTimer);

		// Check if the multiplier timer has expired
		if (multiplierTimer <= 0)
		{
			// Reset the multiplier to 1
			multiplier = 1;

			// Update the multiplier text display
			multiplierText.text = "x" + Std.string(multiplier);

			// Reset the multiplier timer and position the multiplier text
			multiplierTimer = 0;
			multiplierText.x = 650;
			multiplierText.y = 460;

			// Exit the function early
			return;
		}

		// Shake effect on multiplier text based on the current multiplier.
		// `Math.random() * multiplier` ranges 0..multiplier; subtracting
		// `multiplier * 0.5` re-centers that range to -multiplier/2..+multiplier/2,
		// so the text jitters evenly around its anchor (650, 460) rather than
		// drifting to one side - the `- multiplier * 0.5` is intentional
		// centering, not a stray extra term.
		multiplierText.x = 650 + Math.random() * multiplier - multiplier * 0.5;
		multiplierText.y = 460 + Math.random() * multiplier - multiplier * 0.5;
	}

	/**
	 * ---------------------------------------------
	 *
	 *				CAMERA FUNCTIONS
	 *
	 * ---------------------------------------------
	 */

	/**
	* Resets the camera effects.
	* Sets the initial values for the blur filter, decrease value, and increase value.
	*/
	function resetCameraFX():Void
	{
		bF = 0.0;	// blur filter value
		dV = 1.0;	// value to decrease
		iV = 0.0;	// value to increase
	}

	/**
	* Initializes the game camera.
	* Sets up the camera effects, filters, and camera objects.
	*/
	function initCamera():Void
	{
		// Reset the camera effect values
		resetCameraFX();

		// Create a matrix for the grayScaleFilter
		var matrix:Array<Float> = [
			dV,  iV,  iV,  0.0, 0.0,
			iV,  dV,  iV,  0.0, 0.0,
			iV,  iV,  dV,  0.0, 0.0,
			0.0, 0.0, 0.0, 1.0, 0.0,
		];

		// Create the grayscale filter using the matrix
		grayScaleFilter = new ColorMatrixFilter(matrix);

		// Create the blur filter with the current blur value
		blurFilter = new BlurFilter(bF, bF);

		// Create an array of filters with the grayscale and blur filters
		var filters:Array<BitmapFilter> = [blurFilter, grayScaleFilter];

		// Create the UI camera and game elements camera
		uiCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		gCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);

		// Set the background color for each camera
		gCamera.bgColor = FlxColor.BLACK;
		uiCamera.bgColor = FlxColor.TRANSPARENT;

		// Set the filters for the game camera and enable them
		gCamera.filters = filters;
		gCamera.filtersEnabled = true;

		// Disable the filters for the UI camera
		uiCamera.filtersEnabled = false;

		// Reset and add the cameras to the FlxG camera list
		FlxG.cameras.reset(gCamera);
		FlxG.cameras.add(uiCamera, false);
	}

	/**
	* Applies camera effects by tweening the values of dV, iV, and bF.
	* The effects include changes saturation and blur.
	*
	* `FlxTween.tween(this, {dV: 0.5}, 1)` mutates `this.dV` directly, every
	* frame, over 1 second, via reflection - it doesn't know or care that dV
	* feeds into a ColorMatrixFilter. Tweening the field alone doesn't update
	* the filter that was built from its old value; that's why
	* `updateGameOverState()` calls `updateCamera()` (below) every frame while
	* these tweens are running, to rebuild the grayscale/blur filters from
	* whatever dV/iV/bF currently are mid-tween.
	*/
	function applyCameraFX():Void
	{
		// Tween the value of dV (value to be decreased) from 1.0 to 0.5 over a duration of 1 second
		FlxTween.tween(this, {dV : 0.5}, 1);

		// Tween the value of iV (value to be increased) from 0.0 to 0.5 over a duration of 1 second
		FlxTween.tween(this, {iV : 0.5}, 1);

		// Tween the blur filter value from 0.0 to 8.0 over a duration of 1 second
		FlxTween.tween(this, {bF : 8.0}, 1);
	}

	/**
	* Rebuilds the grayscale and blur filter objects from the current dV/iV/bF
	* field values (see applyCameraFX() above for why this rebuild is needed
	* every frame rather than happening automatically).
	*/
	function updateCamera():Void
	{
		// Update the matrix of the grayscale filter while the dV and iV values are being tweened
		grayScaleFilter.matrix = [
			dV,  iV,  iV,  0.0, 0.0,
			iV,  dV,  iV,  0.0, 0.0,
			iV,  iV,  dV,  0.0, 0.0,
			0.0, 0.0, 0.0, 1.0, 0.0,
		];

		// Destroy the last blur filter
		blurFilter = null;
		
		// Create a new blur filter with the updated blur values
		blurFilter = new BlurFilter(bF, bF);
		
		// Create an array of filters with the grayscale and blur filters
		var filters:Array<BitmapFilter> = [blurFilter, grayScaleFilter];
		
		// Set the filters on the game camera
		gCamera.filters = filters;

		// No filters on the UI camera
		uiCamera.filters= [];
	}
}