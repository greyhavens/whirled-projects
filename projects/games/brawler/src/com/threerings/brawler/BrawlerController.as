package com.threerings.brawler {

import flash.display.DisplayObject;
import flash.display.LoaderInfo;
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.*;
import flash.geom.Point;
import flash.utils.ByteArray;
import flash.utils.getTimer;
import flash.utils.Timer;

import com.threerings.ezgame.MessageReceivedEvent;
import com.threerings.ezgame.MessageReceivedListener;
import com.threerings.ezgame.OccupantChangedEvent;
import com.threerings.ezgame.OccupantChangedListener;
import com.threerings.ezgame.PropertyChangedEvent;
import com.threerings.ezgame.PropertyChangedListener;
import com.threerings.ezgame.StateChangedEvent;
import com.threerings.ezgame.StateChangedListener;

import com.threerings.flash.KeyRepeatLimiter;

import com.threerings.util.ArrayUtil;
import com.threerings.util.Controller;
import com.threerings.util.EmbeddedSwfLoader;
import com.threerings.util.StringUtil;

import com.whirled.WhirledGameControl;
import com.whirled.FlowAwardedEvent;

import com.threerings.brawler.actor.Actor;
import com.threerings.brawler.actor.Coin;
import com.threerings.brawler.actor.Enemy;
import com.threerings.brawler.actor.Health;
import com.threerings.brawler.actor.Pawn;
import com.threerings.brawler.actor.Player;
import com.threerings.brawler.actor.Weapon;
import com.threerings.brawler.util.MessageThrottle;

/**
 * Controls the state of the Brawler game.
 */
public class BrawlerController extends Controller
    implements OccupantChangedListener, MessageReceivedListener, PropertyChangedListener,
        StateChangedListener
{
    public function BrawlerController (disp :DisplayObject)
    {
        // create the whirled control
        _control = new WhirledGameControl(disp, false);

        // create the throttle to limit message output (to about eight messages per second)
        _throttle = new MessageThrottle(disp, _control, 200);

        // create the view
        _view = new BrawlerView(disp, this);

        // create the SWF loader and use it to load the raw data, one swf at a time
        _loader = new EmbeddedSwfLoader();
        var idx :int = 0;
        _loader.addEventListener(Event.COMPLETE, function (event :Event) :void {
            if (++idx == INIT_SWFS.length) {
                init();
            } else {
                _loader.load(new INIT_SWFS[idx] as ByteArray);
            }
        });
        _loader.load(new INIT_SWFS[0] as ByteArray);
    }

    /**
     * Returns a reference to the embedded SWF loader.
     */
    public function get loader () :EmbeddedSwfLoader
    {
        return _loader;
    }

    /**
     * Creates an instance of the asset with the supplied class name.
     */
    public function create (name :String) :*
    {
        var clazz :Class = _loader.getClass(name);
        return new clazz();
    }

    /**
     * Returns a reference to the Whirled game control.
     */
    public function get control () :WhirledGameControl
    {
        return _control;
    }

    /**
     * Returns a reference to the throttle through which messages are sent.
     */
    public function get throttle () :MessageThrottle
    {
        return _throttle;
    }

    /**
     * Returns a reference to the game view.
     */
    public function get view () :BrawlerView
    {
        return _view;
    }

    /**
     * Returns the game's difficulty level.
     */
    public function get difficulty () :int
    {
        return _difficulty;
    }

    /**
     * Checks whether we're playing or just watching.
     */
    public function get amPlaying () :Boolean
    {
        return _control.seating.getMyPosition() > -1;
    }

    /**
     * Returns a reference to the local player.
     */
    public function get self () :Player
    {
        return _self;
    }

    /**
     * Returns the player the camera is tracking (ourself, if playing).
     */
    public function get cameraTarget () :Player
    {
        if (amPlaying) {
            return _self;
        }
        // prefer a live player (TODO: allow watchers to cycle between players)
        var dplayer :Player = null;
        for each (var actor :Actor in _actors) {
            if (actor is Player) {
                var player :Player = actor as Player;
                if (!player.dead) {
                    return player;
                } else if (dplayer == null) {
                    dplayer = player;
                }
            }
        }
        return dplayer;
    }

    /**
     * Returns the value of the game clock.
     */
    public function get clock () :int
    {
        return _clock;
    }

    /**
     * Returns the local score.
     */
    public function get score () :int
    {
        return _score;
    }

    /**
     * Modifies the local score.
     */
    public function set score (value :int) :void
    {
        var oscore :int = _score;
        _score = value;
		if(_score < 0){
			_score = 0;
		}
        _view.hud.updateScore(_score - oscore);
    }

    /**
     * Returns the index of the currently occupied room.
     */
    public function get room () :int
    {
        return _room;
    }

    /**
     * Sets the currently occupied room.
     */
    public function set room (number :int) :void
    {
        if (_room == number) {
            return;
        }
        _room = number;
        _view.exitRoom();
    }

	/**
	 * Called by the view when the post-room fade has completed.
	 */
	public function fadedOut () :void
	{
	    // clear out the old actors, replace with the new
        for each (var actor :Actor in _actors) {
            if (actor.amOwner && actor != _self) {
                actor.destroy();
            }
        }
        createEnemies();
        if (_clear) {
			endGame();
            // post our score to the dobj and show the game results
            //_view.showResults();
			//_grade = calculateGrade();
			//if (amPlaying) {
            //    _throttle.set("scores", _grade, _control.seating.getMyPosition());
            //}
        } else {
            _view.enterRoom();
        }
	}

	/**
     * Ends the game and brings up the Grade Card.
     */
    public function endGame () :void
    {
		_disableEnemies = true;
		_disableControls = true;

        // post our score to the dobj
		_grade = calculateGrade();

		// show the game results
		_view.showResults();

		//Set up Exit key.
		_view.results.exit_btn.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown_exit);

		//Listen to flow award.
		control.addEventListener(FlowAwardedEvent.FLOW_AWARDED, flowAwarded);

		if (amPlaying) {
            _throttle.set("scores", _grade, _control.seating.getMyPosition());
        }
    }

	/**
     * The game is over and flow has been awarded.
     */
    public function flowAwarded (event :FlowAwardedEvent) :void
    {
		control.localChat("You recieved "+event.amount+" bits!");
		control.localChat("[DEBUG] Performance Rate: "+event.percentile+"%");
		control.removeEventListener(FlowAwardedEvent.FLOW_AWARDED, flowAwarded);
		_control.playerReady();
	}

	/**
     * The button to exit the game has been hit.
     */
    public function mouseDown_exit (event:MouseEvent):void
    {
		control.backToWhirled(false);
	}

    /**
     * Sets the current wave.
     */
    public function set wave (number :int) :void
    {
        if (_wave == number) {
            return;
        }
        if ((_wave = number) != 1) {
            // the first wave's enemies are created by the room method
            createEnemies();
        }
    }

    /**
     * Checks whether we're clear to proceed to the next room.
     */
    public function get clear () :Boolean
    {
        return _clear;
    }

    /**
     * Returns a reference to the actor map.
     */
    public function get actors () :Object
    {
        return _actors;
    }

    /**
     * Checks whether the final boss is present in the room.
     */
    public function get bossPresent () :Boolean
    {
        return _bossPresent;
    }

    /**
     * Returns a reference to the configuration of the enemy at the specified index.
     */
    public function getEnemyConfig (index :int) :Object
    {
        return _econfigs[index];
    }

    /**
     * Notes the removal of an enemy.
     */
    public function enemyWasDestroyed (enemy :Enemy) :void
    {
        if (enemy.finalBoss) {
            _bossPresent = false;
            for each (var actor :Actor in _actors) {
                if (actor.amOwner && actor is Enemy && actor != enemy) {
                    actor.destroy();
                }
            }
			_clear = true;
			endGame();
        }
        if (--_enemies == 0 && _control.amInControl()) {
            // proceed to the next wave
            _throttle.set("wave", _wave + 1);
        }
    }

    /**
     * Creates a pickup with the supplied state and adds it to the scene.
     */
    public function createPickup (state :Object) :void
    {
        createActor(createActorName(), state);
    }

    /**
     * Called to notify the controller that we're standing on the door to the next room.
     */
    public function playerOnDoor () :void
    {
        // wait until we're clear to proceed
        if (!(_clear && _control.amInControl())) {
            return;
        }

        // shrink the door to prevent further notifications
        _view.door.height = 0;

        // advance to the next room
        _throttle.set("wave", 1);
        _throttle.set("room", _room + 1);
    }

    /**
     * Increments one of the shared statistics if this controller is in control.
     */
    public function incrementStat (stat :String, amount :Number = 1) :void
    {
        if (!_control.amInControl()) {
            return;
        }
        _throttle.send(function () :void {
            _control.setImmediate(stat, _control.get(stat) + amount);
        });
    }

    // documentation inherited from interface PropertyChangedListener
    public function propertyChanged (event :PropertyChangedEvent) :void
    {
        if (event.name == "room") {
            room = event.newValue as int;

        } else if (event.name == "wave") {
            wave = event.newValue as int;

        } else if (event.name == "scores" && _control.amInControl()) {
            // once we have scores from all players present, end the game
            var scores :Array = _control.get("scores") as Array;
            var players :Array = _control.seating.getPlayerIds();
            for (var ii :int = 0; ii < players.length; ii++) {
                if (players[ii] > 0 && scores[ii] == undefined) {
                    return;
                }
            }
            var pplayers :Array = new Array(), pscores :Array = new Array();
            for (ii = 0; ii < players.length; ii++) {
                if (players[ii] > 0) {
                    pplayers.push(players[ii]);
                    pscores.push(scores[ii]);
                }
            }
			_throttle.set("clockOffset", _clock);
            _control.endGameWithScores(pplayers, pscores, WhirledGameControl.TO_EACH_THEIR_OWN);

        } else if (StringUtil.startsWith(event.name, "actor")) {
            // it's the state of an actor
            var actor :Actor = _actors[event.name];
            var state :Object = event.newValue;
            if (state == null) {
                // remove the actor
                if (actor != null) {
                    destroyActor(actor);
                }
            } else if (state.sender != _control.getMyId()) {
                if (actor == null) {
                    // create the new actor
                    createActor(event.name, state);
                } else {
                    // update the actor state
                    actor.decode(state);
                }
            }
        }
    }

    /**
     * (Immediately) destroys an actor.
     */
    public function destroyActor (actor :Actor) :void
    {
        actor.wasDestroyed();
        delete _actors[actor.name];
    }

    // documentation inherited from interface MessageReceivedListener
    public function messageReceived (event :MessageReceivedEvent) :void
    {
        if (event.name == "clock") {
			_clock = _control.get("clockOffset") + (event.value as int);
            //_clock = event.value as int;
            _view.hud.updateClock();

        } else if (StringUtil.startsWith(event.name, "actor")) {
            // it's a message for an actor
            var actor :Actor = _actors[event.name];
            if (actor != null && event.value.sender != _control.getMyId()) {
                actor.receive(event.value);
            }
        }
    }

    // documentation inherited from interface OccupantChangedListener
    public function occupantEntered (event :OccupantChangedEvent) :void
    {
    }

    // documentation inherited from interface OccupantChangedListener
    public function occupantLeft (event :OccupantChangedEvent) :void
    {
        // get rid of their player; take over their other actors
        var playerId :int = event.occupantId;
        var players :Array = remainingPlayers;
        var midx :int = players.indexOf(_control.getMyId());
        var aidx :int = 0;
        for each (var actor :Actor in _actors) {
            if (actor.owner != playerId) {
                continue;
            }
            actor.owner = players[aidx++ % players.length];
            if (actor.amOwner && actor is Player) {
                actor.destroy();
            }
        }
    }

    // function inherited from interface StateChangedListener
    public function stateChanged (event :StateChangedEvent) :void
    {
        if (event.type == StateChangedEvent.CONTROL_CHANGED) {
            _view.hud.updateConnection();
        }
    }

    // Calculate grade and return it.
    public function calculateGrade (toggle:String = "grade", handicap:Boolean = false) :Number
    {
		var temp_grade:Number = 0;
		var num_players:Number = control.seating.getPlayerIds().length;
		var koCount :Number = 0;//control.get("koCount") as Number;
        var koPoints :Number = 0;//Math.max(0, 5000 - 5000*koCount);

		var local_dmgpar:Number = (_score+koPoints)/(_mobHpTotal/num_players);
		var local_timepar:Number = (_mobHpTotal/(300*num_players))/clock;
		var local_difficult:Number;
		if(handicap){
			if(_difficulty == 0){
				local_difficult = 0.5;
			}else if(_difficulty == 2){
				local_difficult = 1.5;
			}else if(_difficulty == 3){
				local_difficult = 2.0;
			}else{
				local_difficult = 1.0;
			}
		}else{
			local_difficult = 1.0;
		}
		temp_grade = Math.round((local_dmgpar*local_timepar*local_difficult)*100);
		if(toggle == "grade"){
			return temp_grade;
		}else if(toggle == "damage"){
			return local_dmgpar;
		}else if(toggle == "time"){
			return local_timepar;
		}else{
			return temp_grade;
		}
    }

    /**
     * Called when the SWF is done loading.
     */
    protected function init () :void
    {
        // report readiness and initialize the view
        if (amPlaying) {
            _control.playerReady();
        }
        _view.init();

        // wait for the game to start before finishing
        if (_control.isInPlay()) {
            finishInit();
        } else {
            _control.addEventListener(StateChangedEvent.GAME_STARTED,
                function (event :StateChangedEvent) :void {
                    finishInit();
                });
        }
    }

    /**
     * Called when the game is known to be started.
     */
    protected function finishInit () :void
    {	if(init_finished){
			if (_control.amInControl()) {
				_throttle.startTicker("clock", CLOCK_DELAY);
			}
		}else{
			init_finished = true;
			// find existing actors, start listening for updates
			var names :Array = _control.getPropertyNames("actor");
			for each (var name :String in names) {
				createActor(name, _control.get(name));
			}
			_control.registerListener(this);

			// fetch the difficulty level
			_difficulty = DIFFICULTY_LEVELS.indexOf(_control.getConfig()["difficulty"]);
			difficulty_setting = _control.getConfig()["difficulty"];

			// if we are in control, initialize
			if (_control.amInControl()) {
				_throttle.set("room", _room);
				_throttle.set("wave", _wave);
				_throttle.set("koCount", 0);
				_throttle.set("playerDamage", 0);
				_throttle.set("enemyDamage", 0);
				_throttle.set("scores", new Array(_control.seating.getPlayerIds().length));
				_throttle.set("clockOffset", 0);
				_throttle.startTicker("clock", CLOCK_DELAY);
			} else {
				var croom :Object = _control.get("room");
				var cwave :Object = _control.get("wave");
				_room = (croom == null) ? 1 : (croom as int);
				_wave = (cwave == null) ? 1 : (cwave as int);
			}

			// create and announce our own pawn
			if (amPlaying) {
				var start :Point = _view.playerStart;
				_self = createActor(createActorName(), Player.createState(start.x, start.y)) as Player;
			}

			// copy the configurations to an array (for some reason they disappear if we try to keep
			// them in the clip) and create our share of the enemies
			var configs :MovieClip = create("EnemyConfigs");
			for (var ii :int = 0; ii < configs.numChildren; ii++) {
				_econfigs.push(configs.getChildAt(ii));
			}
			createEnemies();

			_clickTimer.addEventListener( TimerEvent.TIMER, onClickTimer);
			_clickTimer.start();

			if (amPlaying) {
				// listen for mouse clicks on the ground
				_view.ground.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);

				// listen for keyboard events through the blocker
				_blocker = new KeyRepeatLimiter(_control);
				_blocker.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
				_blocker.addEventListener(KeyboardEvent.KEY_UP, handleKeyUp);
			}
		}
    }

    /**
     * Creates and maps a set of enemies for the current room and wave.
     */
    protected function createEnemies () :void
    {
        var name :String = "m" + _room + "_w" + _wave;
        var players :Array = remainingPlayers;
        var midx :int = players.indexOf(_control.getMyId());
        _enemies = 0;
        for (var ii :int = 0; ii < _econfigs.length; ii++) {
            var config :Object = _econfigs[ii];
            if (config.name != name) {
                continue;
            }
            if (_enemies++ % players.length == midx) {
                createActor(createActorName(),
                    Enemy.createState(ii, config, _difficulty, players.length));
            }
        }
        _clear = (_enemies == 0);
        _view.hud.updateClear();
    }

    /**
     * Creates, maps, and returns a new actor.
     */
    protected function createActor (name :String, state :Object) :Actor
    {
        var actor :Actor = Actor.createActor(name, state);
        actor.init(this, state);
        _actors[name] = actor;
        _bossPresent ||= (actor is Enemy) && (actor as Enemy).finalBoss;
        return actor;
    }

    /**
     * Creates and returns a new unique actor name.
     */
    protected function createActorName () :String
    {
        return "actor" + _control.getMyId() + "_" + (++_lastActorId);
    }

    /**
     * Called when the mouse is pressed on the ground.
     */
    protected function handleMouseDown (event :MouseEvent) :void
    {
        if (!(_view.cursorOn && _self.canMove)) {
            return;
        }
        var x :Number = _view.cursor.x, y :Number = _view.cursor.y;
        if (_self.locationEquals(x, y)) {
            return;
        }
		// Double-click test
		if(_lastClick <= 400){
			_sprinting = true;
		}else{
			_sprinting = false;
		}
		_lastClick = 0;
        _view.showGoal(x, y);
        _self.move(x, y, _sprinting ? Pawn.SPRINT : Pawn.WALK);
    }

    /**
     * Called when a key is pressed.
     */
    protected function handleKeyDown (event :KeyboardEvent) :void
    {
        var code :uint = event.keyCode;
        if (ArrayUtil.contains(PUNCH_CODES, code)) {
            _self.attack(false);
        } else if (ArrayUtil.contains(KICK_CODES, code)) {
            _self.attack(true);
        } else if (ArrayUtil.contains(BLOCK_CODES, code)) {
            _self.blocking = true;
        } else if (ArrayUtil.contains(SPRINT_CODES, code)) {
            //_sprinting = true;
        }
    }

    /**
     * Called when a key is released.
     */
    protected function handleKeyUp (event :KeyboardEvent) :void
    {
        var code :uint = event.keyCode;
        if (ArrayUtil.contains(BLOCK_CODES, code)) {
            _self.blocking = false;
        } else if (ArrayUtil.contains(SPRINT_CODES, code)) {
            //_sprinting = false;
        }
    }

    /**
     * Returns an array containing the ids of players still present.
     */
    protected function get remainingPlayers () :Array
    {
        return _control.seating.getPlayerIds().filter(
            function (element :*, index :int, array :Array) :Boolean {
                return element > 0;
            });
    }

	private function onClickTimer( e: Event):void{
		_lastClick += 100;
	}

	/** Do this only once */
    protected var init_finished :Boolean;

    /** The SWF loader. */
    protected var _loader :EmbeddedSwfLoader;

    /** The Whirled interface. */
    protected var _control :WhirledGameControl;

    /** The throttle through which messages are sent. */
    public var _throttle :MessageThrottle;

    /** The game view. */
    protected var _view :BrawlerView;

    /** An intermediate layer to block repeat keystrokes. */
    protected var _blocker :KeyRepeatLimiter;

    /** The configured difficulty level. */
    public var _difficulty :int;

    /** The set of actors, mapped by name ("actor[owner id]_[actor id]"). */
    protected var _actors :Object = new Object();

    /** The last actor id assigned. */
    protected var _lastActorId :int = 0;

    /** Our own actor. */
    protected var _self :Player;

    /** The game clock (updated every second). */
    protected var _clock :int = 0;

    /** The local score. */
    protected var _score :int = 0;

	/** The local grade. */
    public var _grade :int = 0;

    /** The currently occupied room. */
    protected var _room :int = 1;

    /** The current wave of enemies. */
    protected var _wave :int = 1;

    /** The number of enemies remaining in this wave. */
    protected var _enemies :int = 0;

    /** Whether or not the final boss is present in the room. */
    protected var _bossPresent :Boolean = false;

    /** If true, we are clear to proceed to the next room. */
    protected var _clear :Boolean;

    /** Whether or not we should sprint, if possible, when moving. */
    protected var _sprinting :Boolean = false;

	/** Time since last click. */
    protected var _lastClick :Number = 0;

	/** Time since last click. */
    protected var _clickTimer :Timer = new Timer(100);

    /** The enemy configurations. */
    protected var _econfigs :Array = new Array();

	/** Total amount of Mob Hit Points. */
	public var _mobHpTotal :Number = 0;

	/** If on, turns off enemies. */
	public var _disableEnemies :Boolean = false;

	/** If on, turns off controls.  */
	public var _disableControls :Boolean = false;

    /** The raw SWF data. */
    //[Embed(source="../../../../rsrc/raw.swf", mimeType="application/octet-stream")]
    //protected static const RAW_SWF :Class;
	[Embed(source="../../../../rsrc/hud_effects.swf", mimeType="application/octet-stream")]
    protected static const RAW_SWF :Class;
	[Embed(source="../../../../rsrc/bgs.swf", mimeType="application/octet-stream")]
    protected static const BGS_SWF :Class;
	[Embed(source="../../../../rsrc/pc.swf", mimeType="application/octet-stream")]
    protected static const PC_SWF :Class;
	[Embed(source="../../../../rsrc/mobs.swf", mimeType="application/octet-stream")]
    protected static const MOBS_SWF :Class;

    /** The SWFs to load on initialization. */
    protected static const INIT_SWFS :Array = [ RAW_SWF, BGS_SWF, PC_SWF, MOBS_SWF ];

    /** The available difficulty levels. */
    protected static const DIFFICULTY_LEVELS :Array = [ "Easy", "Normal", "Hard", "Inferno" ];

    /** The delay (ms) of the game clock. */
    protected static const CLOCK_DELAY :int = 1000;

    /** Key codes for the punch command. */
    protected static const PUNCH_CODES :Array = [ 51, 68 ]; // 3, D

    /** Key codes for the kick command. */
    protected static const KICK_CODES :Array = [ 50, 65 ]; // 2, A

    /** Key codes for the block command. */
    protected static const BLOCK_CODES :Array = [ 52, 83 ]; // 4, S

    /** Key codes for the sprint command. */
    protected static const SPRINT_CODES :Array = [ 49, 87 ]; // 1, W
	
	/** Variables for the trophies  */
	public var difficulty_setting :String 	= "Normal";
	public var timeSpentBlocking :Number 	= 0;
		public var timeSpentBlocking_goal :Number 	= 180;
		public var timeSpentBlocking_awarded :Boolean 	= false;
	public var lemmingCount :Number 		= 0;
		public var lemmingCount_goal :Number 		= 10;
		public var lemmingCount_awarded :Boolean 	= false;
	public var damageTaken :Number 			= 0;
		public var damageTaken_goal :Number 		= 30000;
		public var damageTaken_awarded :Boolean 	= false;
	public var coinsCollected :Number 		= 0;
		public var coinsCollected_goal :Number 		= 100;
		public var coinsCollected_awarded :Boolean 	= false;
	public var weaponsBroken :Number 		= 0;
		public var weaponsBroken_goal :Number 		= 25;
		public var weaponsBroken_awarded :Boolean 	= false;
	public var weaponsCollected :Number 	= 0;
		public var weaponsCollected_goal :Number 	= 50;
		public var weaponsCollected_awarded :Boolean 	= false;
}
}
