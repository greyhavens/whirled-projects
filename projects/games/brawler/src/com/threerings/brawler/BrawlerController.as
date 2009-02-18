package com.threerings.brawler {

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.events.*;
import flash.geom.Point;
import flash.utils.Timer;

import com.threerings.flash.KeyRepeatLimiter;
import com.threerings.util.ArrayUtil;
import com.threerings.util.Controller;
import com.threerings.util.StringUtil;
import com.whirled.game.CoinsAwardedEvent;
import com.whirled.game.GameControl;
import com.whirled.game.GameSubControl;
import com.whirled.game.OccupantChangedEvent;
import com.whirled.game.StateChangedEvent;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.PropertyChangedEvent;

import com.threerings.brawler.actor.Actor;
import com.threerings.brawler.actor.Enemy;
import com.threerings.brawler.actor.Pawn;
import com.threerings.brawler.actor.Player;
import com.threerings.brawler.util.MessageThrottle;

/**
 * Controls the state of the Brawler game.
 */
public class BrawlerController extends Controller
{
    /** Variables for the trophies  */
    public var difficulty_setting :String           = "Normal";
    public var timeSpentBlocking :Number            = 0;
    public var timeSpentBlocking_goal :Number       = 180;
    public var timeSpentBlocking_awarded :Boolean   = false;
    public var lemmingCount :Number                 = 0;
    public var lemmingCount_goal :Number            = 10;
    public var lemmingCount_awarded :Boolean        = false;
    public var damageTaken :Number                  = 0;
    public var damageTaken_goal :Number             = 30000;
    public var damageTaken_awarded :Boolean         = false;
    public var coinsCollected :Number               = 0;
    public var coinsCollected_goal :Number          = 100;
    public var coinsCollected_awarded :Boolean      = false;
    public var weaponsBroken :Number                = 0;
    public var weaponsBroken_goal :Number           = 25;
    public var weaponsBroken_awarded :Boolean       = false;
    public var weaponsCollected :Number             = 0;
    public var weaponsCollected_goal :Number        = 50;
    public var weaponsCollected_awarded :Boolean    = false;

    public function BrawlerController (control :GameControl, disp :DisplayObject,
                                       difficultyName :String)
    {
        _control = control;

        // fetch the difficulty level
        _difficulty = DIFFICULTY_LEVELS.indexOf(difficultyName);
        difficulty_setting = difficultyName;

        // create the throttle to limit message output (to about eight messages per second)
        _throttle = new MessageThrottle(disp, _control, 200);

        // create the view
        _view = new BrawlerView(disp, this);

        // Load the game's resources, and call the init() function when they've loaded
        Resources.load(init);
    }

    /**
     * Creates an instance of the asset with the supplied class name.
     */
    public function create (name :String) :*
    {
        return Resources.create(name);
    }

    /**
     * Returns a reference to the Whirled game control.
     */
    public function get control () :GameControl
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
        return _control.isConnected() && (_control.game.seating.getMyPosition() > -1);
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
            //    _throttle.setAt("scores", _control.game.seating.getMyPosition(), _grade);
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

        // hide exit key
        _view.results.exit_btn.visible = false;

        //Listen to coin award.
        control.player.addEventListener(CoinsAwardedEvent.COINS_AWARDED, coinsAwarded);

        if (amPlaying) {
            _throttle.setAt("scores", _control.game.seating.getMyPosition(), _grade);
        }
    }

    /**
     * The game is over and coins have been awarded.
     */
    public function coinsAwarded (event :CoinsAwardedEvent) :void
    {
        control.local.feedback("You recieved "+event.amount+" bits!");
        control.local.feedback("[DEBUG] Performance Rate: "+event.percentile+"%");
        control.player.removeEventListener(CoinsAwardedEvent.COINS_AWARDED, coinsAwarded);
        _control.game.playerReady();
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
        if (--_enemies == 0 && _control.game.amInControl()) {
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
        if (!(_clear && _control.game.amInControl())) {
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
        if (!_control.game.amInControl()) {
            return;
        }
        _throttle.send(function () :void {
            _control.net.set(stat, _control.net.get(stat) + amount, true);
        });
    }

    /**
     * (Immediately) destroys an actor.
     */
    public function destroyActor (actor :Actor) :void
    {
        actor.wasDestroyed();
        delete _actors[actor.name];
    }

    // Calculate grade and return it.
    public function calculateGrade (toggle:String = "grade", handicap:Boolean = false) :Number
    {
        var temp_grade:Number = 0;
        var num_players:Number = control.game.seating.getPlayerIds().length;
        var koCount :Number = 0;//control.net.get("koCount") as Number;
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
            _control.game.playerReady();
        }
        _view.init();

        // wait for the game to start before finishing
        if (_control.game.isInPlay()) {
            finishInit();
        } else {
            _control.game.addEventListener(StateChangedEvent.GAME_STARTED,
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
        if (init_finished) {
            if (_control.game.amInControl()) {
                _throttle.startTicker("clock", CLOCK_DELAY);
            }
            return;
        }
        init_finished = true;

        // find existing actors, start listening for updates
        var names :Array = _control.net.getPropertyNames("actor");
        for each (var name :String in names) {
            createActor(name, _control.net.get(name));
        }
        _control.net.addEventListener(ElementChangedEvent.ELEMENT_CHANGED, propertyChanged);
        _control.net.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, propertyChanged);
        _control.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
        _control.game.addEventListener(OccupantChangedEvent.OCCUPANT_LEFT, occupantLeft);
        _control.game.addEventListener(StateChangedEvent.CONTROL_CHANGED, controlChanged);

        // if we are in control, initialize
        if (_control.game.amInControl()) {
            _throttle.set("room", _room);
            _throttle.set("wave", _wave);
            _throttle.set("koCount", 0);
            _throttle.set("playerDamage", 0);
            _throttle.set("enemyDamage", 0);
            _throttle.set("scores", new Array(_control.game.seating.getPlayerIds().length));
            _throttle.set("clockOffset", 0);
            _throttle.startTicker("clock", CLOCK_DELAY);
        } else {
            var croom :Object = _control.net.get("room");
            var cwave :Object = _control.net.get("wave");
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
            _blocker = new KeyRepeatLimiter(_control.local);
            _blocker.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
            _blocker.addEventListener(KeyboardEvent.KEY_UP, handleKeyUp);
        }
    }

    /**
     * Called when a property changes in the game object.
     */
    protected function propertyChanged (event :PropertyChangedEvent) :void
    {
        if (event.name == "room") {
            room = event.newValue as int;

        } else if (event.name == "wave") {
            wave = event.newValue as int;

        } else if (event.name == "scores" && _control.game.amInControl()) {
            // once we have scores from all players present, end the game
            var scores :Array = _control.net.get("scores") as Array;
            var players :Array = _control.game.seating.getPlayerIds();
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
            _control.game.endGameWithScores(pplayers, pscores, GameSubControl.TO_EACH_THEIR_OWN);

        } else if (StringUtil.startsWith(event.name, "actor")) {
            // it's the state of an actor
            var actor :Actor = _actors[event.name];
            var state :Object = event.newValue;
            if (state == null) {
                // remove the actor
                if (actor != null) {
                    destroyActor(actor);
                }
            } else if (state.sender != _control.game.getMyId()) {
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
     * Called when a message is received on the game object.
     */
    protected function messageReceived (event :MessageReceivedEvent) :void
    {
        if (event.name == "clock") {
            _clock = _control.net.get("clockOffset") + (event.value as int);
            //_clock = event.value as int;
            _view.hud.updateClock();

        } else if (StringUtil.startsWith(event.name, "actor")) {
            // it's a message for an actor
            var actor :Actor = _actors[event.name];
            if (actor != null && event.value.sender != _control.game.getMyId()) {
                actor.receive(event.value);
            }
        }
    }

    /**
     * Called when an occupant leaves the game.
     */
    public function occupantLeft (event :OccupantChangedEvent) :void
    {
        // get rid of their player; take over their other actors
        var playerId :int = event.occupantId;
        var players :Array = remainingPlayers;
        var midx :int = players.indexOf(_control.game.getMyId());
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

    /**
     * Called when the game state changes.
     */
    public function controlChanged (event :StateChangedEvent) :void
    {
        _view.hud.updateConnection();
    }

    /**
     * Creates and maps a set of enemies for the current room and wave.
     */
    protected function createEnemies () :void
    {
        var name :String = "m" + _room + "_w" + _wave;
        var players :Array = remainingPlayers;
        var midx :int = players.indexOf(_control.game.getMyId());
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
        return "actor" + _control.game.getMyId() + "_" + (++_lastActorId);
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
        return _control.game.seating.getPlayerIds().filter(
            function (element :*, index :int, array :Array) :Boolean {
                return element > 0;
            });
    }

    private function onClickTimer( e: Event):void
    {
        _lastClick += 100;
    }

    /** Do this only once */
    protected var init_finished :Boolean;

    /** The Whirled interface. */
    protected var _control :GameControl;

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
