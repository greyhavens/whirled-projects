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

import com.threerings.flash.KeyRepeatBlocker;

import com.threerings.util.ArrayUtil;
import com.threerings.util.Controller;
import com.threerings.util.EmbeddedSwfLoader;
import com.threerings.util.StringUtil;

import com.whirled.WhirledGameControl;

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
        _throttle = new MessageThrottle(disp, _control, 125);

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
        _view.exitRoom(function () :void {
            // clear out the old actors, replace with the new
            for each (var actor :Actor in _actors) {
                if (actor.amOwner && actor != _self) {
                    actor.destroy();
                }
            }
            createEnemies();
            if (_clear) {
                // post our score to the dobj and show the game results
                if (amPlaying) {
                    _control.set("scores", _score, _control.seating.getMyPosition());
                }
                _view.showResults();
            } else {
                _view.enterRoom();
            }
        });
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
        }
        if (--_enemies == 0 && _control.amInControl()) {
            // proceed to the next wave
            var nwave :int = _wave + 1;
            _throttle.send(function () :void {
                _control.set("wave", nwave);
            });
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
        var nroom :int = _room + 1;
        _throttle.send(function () :void {
            _control.set("wave", 1);
            _control.set("room", nroom);
        });
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
            _control.endGameWithScores(pplayers, pscores, WhirledGameControl.TO_EACH_THEIR_OWN);

        } else if (StringUtil.startsWith(event.name, "actor")) {
            // it's the state of an actor
            var actor :Actor = _actors[event.name];
            if (event.newValue == null) {
                // remove the actor
                if (actor != null) {
                    destroyActor(actor);
                }
            } else if (actor == null) {
                // create the actor (unless it's an old state that we generated)
                if (!StringUtil.startsWith(event.name, _actorNamePrefix)) {
                    createActor(event.name, event.newValue);
                }
            } else if (!actor.amOwner) {
                // update the actor state
                actor.decode(event.newValue);
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
            _clock = event.value as int;
            _view.hud.updateClock();

        } else if (StringUtil.startsWith(event.name, "actor")) {
            // it's a message for an actor
            var actor :Actor = _actors[event.name];
            if (actor != null && !actor.amOwner) {
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
    {
        // create our actor name prefix
        _actorNamePrefix = "actor" + _control.getMyId() + "_";

        // find existing actors, start listening for updates
        var names :Array = _control.getPropertyNames("actor");
        for each (var name :String in names) {
            createActor(name, _control.get(name));
        }
        _control.registerListener(this);

        // fetch the difficulty level
        _difficulty = DIFFICULTY_LEVELS.indexOf(_control.getConfig()["difficulty"]);

        // if we are in control, initialize
        if (_control.amInControl()) {
            _control.set("room", _room);
            _control.set("wave", _wave);
            _control.set("koCount", 0);
            _control.set("playerDamage", 0);
            _control.set("enemyDamage", 0);
            _control.set("scores", new Array(_control.seating.getPlayerIds().length));
            _control.startTicker("clock", CLOCK_DELAY);
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
            _blocker = new KeyRepeatBlocker(_control);
            _blocker.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
            _blocker.addEventListener(KeyboardEvent.KEY_UP, handleKeyUp);
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
        return _actorNamePrefix + (++_lastActorId);
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

    /** The SWF loader. */
    protected var _loader :EmbeddedSwfLoader;

    /** The Whirled interface. */
    protected var _control :WhirledGameControl;

    /** The throttle through which messages are sent. */
    protected var _throttle :MessageThrottle;

    /** The game view. */
    protected var _view :BrawlerView;

    /** An intermediate layer to block repeat keystrokes. */
    protected var _blocker :KeyRepeatBlocker;

    /** The configured difficulty level. */
    protected var _difficulty :int;

    /** The set of actors, mapped by name ("actor[owner id]_[actor id]"). */
    protected var _actors :Object = new Object();

    /** The last actor id assigned. */
    protected var _lastActorId :int = 0;

    /** The prefix we use for the names of all actors we create. */
    protected var _actorNamePrefix :String;

    /** Our own actor. */
    protected var _self :Player;

    /** The game clock (updated every second). */
    protected var _clock :int = 0;

    /** The local score. */
    protected var _score :int = 0;

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
}
}
