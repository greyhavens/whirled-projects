package com.threerings.brawler {

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;
import flash.utils.getTimer;

import com.threerings.util.ArrayUtil;

import com.threerings.flash.MathUtil;

import com.threerings.brawler.actor.Actor;
import com.threerings.brawler.actor.Pawn;
import com.threerings.brawler.actor.Player;
import com.threerings.brawler.util.BrawlerUtil;

import com.whirled.game.CoinsAwardedEvent;
import com.whirled.game.StateChangedEvent;

/**
 * Depicts the state of the Brawler game.
 */
public class BrawlerView extends Sprite
{
    public function BrawlerView (disp :DisplayObject, ctrl :BrawlerController)
    {
        _ctrl = ctrl;
    }

    /**
     * Called by the controller when the SWF is done loading.
     */
    public function init () :void
    {
        // create the game display, fetching references to its various bits and bobs
        _game = _ctrl.create("Game");
        _camera = _game["camera"];
		_camera._zoom.addChild(_camera._zoom.bg = MovieClip(_ctrl.create("bg_export")));
        _background = _camera._zoom.bg;
        _ground = _background.ground;

        // compute the locations of the horizon and lip, which determine the perspective
        _horizon = _ground.y - 3*_ground.height;
        _lip = _ground.y + _ground.height;

        // remove the existing hud, wrap it in the hud view
        var hud :MovieClip = _game["hud"] as MovieClip;
        var idx :int = _game.getChildIndex(hud);
        _game.removeChildAt(idx);
        _game.addChildAt(_hud = new HudView(_ctrl, this, hud), idx);

        // create and attach the cursor and goal
        _background.cursor_zone.addChild(_cursor = _ctrl.create("Cursor"));
        _background.cursor_zone.addChild(_goal = _ctrl.create("Destination"));
        _goal.gotoAndPlay("off");

        // if the game is in play, jump right into the main view; otherwise, show the preloader
        // display and wait for the game to start
        if (_ctrl.control.isConnected() && _ctrl.control.game.isInPlay()) {
            finishInit();

        } else {
            addChild(_preloader = _ctrl.create("Preloader"));
            _ctrl.control.game.addEventListener(StateChangedEvent.GAME_STARTED,
                function (event :StateChangedEvent) :void {
                    //_preloader["fade"].play();
                    finishInit();
                });
        }
    }

    /**
     * Returns a reference to the HUD view.
     */
    public function get hud () :HudView
    {
        return _hud;
    }

    /**
     * Returns a reference to the door to the next room.
     */
    public function get door () :DisplayObject
    {
        return _background.door_next;
    }

    /**
     * Returns a reference to the ground.
     */
    public function get ground () :MovieClip
    {
        return _ground;
    }

    /**
     * Returns the y coordinate of the center of the ground.
     */
    public function get groundCenterY () :Number
    {
        return _ground.y - _ground.height/2;
    }

    /**
     * Returns a reference to the cursor.
     */
    public function get cursor () :MovieClip
    {
        return _cursor;
    }

    /**
     * Checks whether the cursor is on (whether it's over a valid location).
     */
    public function get cursorOn () :Boolean
    {
        return _cursorOn;
    }

    /**
     * Returns the coordinates at which players start.
     */
    public function get playerStart () :Point
    {
        return new Point(100, _ground.y - _ground.height/2);
    }

    /**
     * Shows the goal marker at the specified position.
     */
    public function showGoal (x :Number, y :Number) :void
    {
        _goal.gotoAndPlay("on");
        setPosition(_goal, x, y);
    }

    /**
     * Hides the goal marker.
     */
    public function hideGoal () :void
    {
        _goal.gotoAndPlay("off");
    }

    /**
     * Sets the camera effect to play at the start of the next frame.  If there is already
     * an effect, it will only be replaced if the specified effect is more intense.
     */
    public function playCameraEffect (effect :String) :void
    {
        var oidx :int = ArrayUtil.indexOf(CAMERA_EFFECTS, _cameraEffect);
        var nidx :int = ArrayUtil.indexOf(CAMERA_EFFECTS, effect);
        if (nidx >= oidx) {
            _cameraEffect = effect;
        }
    }

    /**
     * Adds an actor to the scene.
     */
    public function addActor (actor :Actor) :void
    {
        _background.actors.addChild(actor);
        _actors.push(actor);
    }

    /**
     * Removes an actor from the scene.
     */
    public function removeActor (actor :Actor) :void
    {
        _background.actors.removeChild(actor);
        ArrayUtil.removeFirst(_actors, actor);
    }

    /**
     * Adds a transient sprite that will remove itself after its animation completes.
     *
     * @param background if true, add this sprite to the background rather than the actor layer.
     */
    public function addTransient (
        sprite :Sprite, x :Number, y :Number, background :Boolean = false) :void
    {
        (background ? _background : _background.actors).addChild(sprite);
        setPosition(sprite, x, y);
    }

    /**
     * Sets the position of the specified sprite and updates its scale accordingly.
     */
    public function setPosition (sprite :Sprite, x :Number, y :Number) :void
    {
        sprite.x = x;
        sprite.y = y;

        var scale :Number = getScale(y);
        sprite.scaleX = scale;
        sprite.scaleY = scale;

        // remove and reinsert the actor according to its sorted order
        if (!_background.actors.contains(sprite)) {
            return;
        }
        _background.actors.removeChild(sprite);
        for (var ii :int = 0; ii < _background.actors.numChildren; ii++) {
            if (scale <= _background.actors.getChildAt(ii).scaleX) {
                _background.actors.addChildAt(sprite, ii);
                return;
            }
        }
        _background.actors.addChild(sprite);
    }

    /**
     * Given a y coordinate in the local coordinate system, returns the corresponding scale.
     */
    public function getScale (y :Number) :Number
    {
        return (y <= _horizon) ? 0 : (y - _horizon) / (_lip - _horizon);
    }

    /**
     * Clamps a set of coordinates to the bounds of the ground region.
     */
    public function clampToGround (x :Number, y :Number) :Point
    {
        return new Point(
            MathUtil.clamp(x, 0, _ground.width),
            MathUtil.clamp(y, _ground.y - _ground.height, _ground.y));
    }

    /**
     * Exits the current room.
     */
    public function exitRoom () :void
    {
        // depict all the players moving out of the scene
        var tx :Number = _ground.width + 500;
        var ty :Number = groundCenterY;
        for each (var actor :Actor in _actors) {
            if (actor is Player) {
                (actor as Player).move(tx, ty, Pawn.WALK, false);
            }
        }
        // start the fade-out (the hud will report to the controller when finished)
        _hud.fade("out");

		// status report
		_hud.zoneClear();

		// end game, sorta, and award flow.
		_ctrl._grade = _ctrl.calculateGrade();
		var self :Player = _ctrl.self;
		if(self.special && _ctrl._grade > 125){
			_ctrl._grade = 125;
		}
		_ctrl.control.player.addEventListener(CoinsAwardedEvent.COINS_AWARDED, _ctrl.coinsAwarded);
		_ctrl.throttle.setAt("scores", _ctrl.control.game.seating.getMyPosition(), _ctrl._grade);
    }

    /**
     * Enters the current room.
     */
    public function enterRoom () :void
    {
        // set up the room
        updateRoom();

        // have all the players walk in
        var ty :Number = groundCenterY;
        for each (var actor :Actor in _actors) {
            if (actor is Player) {
                var player :Player = actor as Player;
                player.x = -150;
                player.y = ty;
                player.move(250, ty, Pawn.WALK, false);
            }
        }

        // fade in
        _hud.fade("in");

		// status report remove
		_hud.zoneClear(true);
    }

    /**
     * Shows the results screen.
     */
    public function showResults () :void
    {
        results = _ctrl.create("Endscreen");
        //removeChild(_game);
		_hud.alpha = 0;
        addChild(results);
		results.gotoAndPlay(1);

        // display the KO count/points
        //var koCount :Number = _ctrl.control.get("koCount") as Number;
        //var koPoints :Number = Math.max(0, 5000 - 5000*koCount);
        //results.stats.pko.playerkos.text = koCount + " (+" + koPoints + ")";

        // display the damage points
        results.score.points.text = Math.round(_ctrl.score);

		if(_ctrl.difficulty_setting == "Easy"){
			results.difficulty.text = "EASY";
		}else if(_ctrl.difficulty_setting == "Normal"){
			results.difficulty.text = "NORMAL";
		}else if(_ctrl.difficulty_setting == "Hard"){
			results.difficulty.text = "HARD";
		}else if(_ctrl.difficulty_setting == "Inferno"){
			results.difficulty.text = "INFERNO";
		}

        // display the final clock value, bonus score
        results.time.points.text = _hud.clock;

        // compute and display the rank
        var pct :Number = Math.round(_ctrl.calculateGrade("grade",false));
        var grade :Number = BrawlerUtil.indexIfLessEqual(GRADE_LEVELS, pct);
        results.grade.gotoAndStop(GRADES[grade]);
		results.percent.points.text = pct;

		//Award trophy/prize for room
		if (_ctrl.difficulty_setting != "Easy" || _ctrl.difficulty_setting != "Normal"){
			if ((GRADES[grade]) == "S"){
				//Got a rank S!
				var zone:int = 9;
				if (_ctrl.control.player.awardTrophy(String("room"+zone))) {
					_ctrl.control.player.awardPrize(String("prize_z"+zone));
				}
			}
		}

		//Award trophy/prize for completion
		if (_ctrl.control.player.awardTrophy(String("trophy_"+_ctrl.difficulty_setting))) {
			_ctrl.control.player.awardPrize(String("prize_"+_ctrl.difficulty_setting));
		}

		//Award Immortal Trophy if they didn't die.
		if (_ctrl.difficulty_setting != "Easy"){
			if(_ctrl.lemmingCount <= 0){
				_ctrl.control.player.awardTrophy("immortal");
			}
		}


    }

    /**
     * Called when the game starts (or is determined to be already in play).
     */
    protected function finishInit () :void
    {
		if(init_finished){
		}else{
			init_finished = true;
			// add the game display
			addChild(_game);

			// turn the camera effect off
			_camera.stop();

			// set up the first room
			updateRoom();

			// initialize the hud
			_hud.init();

			// start updating at every frame
			root.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
		}
    }

    /**
     * Called on every frame.
     */
    protected function handleEnterFrame (event :Event) :void
    {
        // compute the time elapsed since the last frame
        var ntimer :int = getTimer();
        var elapsed :Number = (ntimer - _timer) / 1000;
        _timer = ntimer;

        // increment the frame count
        _frameCount++;

        // if we've become disconencted, stop doing anything
        if (!_ctrl.control.isConnected()) {
            return;
        }

        // perhaps do a per-second update
        var delta :Number = (_timer - _lastPerSecond) / 1000;
        if (delta >= 1.0) {
            updatePerSecond(delta);
            _lastPerSecond = _timer;
        }

        // play the camera effect, if any (we postpone this until the start of the next
        // frame because of a bug where the hit boxes would be frozen at their active
        // frame)
        if (_cameraEffect != null) {
            _camera.gotoAndPlay(_cameraEffect);
            _cameraEffect = null;
        }

        // notify the actors
        for each (var actor :Actor in _actors) {
            if (actor.parent != null) {
                actor.enterFrame(elapsed);
            }
        }

        // update the camera position
        updateCamera(elapsed);

        // update the locations of the background layers
        updateBackgroundLayers();

        // update the state of the cursor and hud
        updateCursor();

        // update the state of the hud
        _hud.enterFrame(elapsed);
    }

    /**
     * Called approximately once per second.
     *
     * @param elapsed the actual number of seconds elapsed since the last call.
     */
    protected function updatePerSecond (elapsed :Number) :void
    {
        // update the message per second measure
        _hud.updateMPS(Math.round(_ctrl.throttle.counter / elapsed));

        // update the throttle queue length display
        _hud.updateTBS();

        // update the frame rate measure
        _hud.updateFPS(Math.round(_frameCount / elapsed));
        _frameCount = 0;
    }

    /**
     * Updates the position of the camera.
     */
    protected function updateCamera (elapsed :Number) :void
    {
        // find out where we are
        var offset :Number = -_camera.x;

        // and where we'd like to be (clamped to the background limits)
        var goal :Number = _ctrl.cameraTarget.x - Brawler.WIDTH/2;
        goal = MathUtil.clamp(goal, 0, _background.bg_1.width - Brawler.WIDTH);
        if (Math.abs(offset - goal) <= 1) {
            return; // close enough!
        }

        // approach at an exponential rate
        var f :Number = Math.exp(CAMERA_RATE * elapsed);
        var noffset :Number = BrawlerUtil.interpolate(offset, goal, f);

        // set the new offset
        _camera.x = -noffset;
    }

    /**
     * Updates the positions of the background layers.
     */
    protected function updateBackgroundLayers () :void
    {
        // determine the proportional offset of the camera (as determined by the base layer)
        var offset :Number = (-_camera.x) / (_background.bg_1.width - Brawler.WIDTH);

        // adjust the positions of the other layers according to their sizes
        for (var ii :int = 2; ii <= BACKGROUND_LAYERS; ii++) {
            var layer :MovieClip = _background["bg_" + ii];
            var loff :Number = offset * (layer.width - Brawler.WIDTH);
            layer.x = (-loff - _camera.x);
        }
    }

    /**
     * Updates the visibility and location of the cursor.
     */
    protected function updateCursor () :void
    {
        var global :Point = localToGlobal(new Point(mouseX, mouseY + 5));
        if (_ground.hitTestPoint(global.x, global.y)) {
            if (!_cursorOn) {
                _cursorOn = true;
                _cursor.gotoAndPlay("on");
            }
            var local :Point = _background.globalToLocal(global);
            setPosition(_cursor, local.x, local.y);

        } else if (_cursorOn) {
            _cursorOn = false;
            _cursor.gotoAndPlay("off");
        }
    }

    /**
     * Updates the ground and background layers to depict the current room.
     */
    protected function updateRoom () :void
    {
        var room :int = _ctrl.room;
        for (var ii :int = 1; ii <= BACKGROUND_LAYERS; ii++) {
            _background["bg_" + ii].gotoAndStop(room);
        }
        _ground.gotoAndStop(room);

        // update the hud
        _hud.updateRoom();

        // set up the door
        door.x = _ground.width
        door.height = _ground.height;
    }

	/** Do this only once */
    protected var init_finished :Boolean;

    /** The Brawler controller. */
    protected var _ctrl :BrawlerController;

    /** Keeps the HUD up-to-date. */
    protected var _hud :HudView;

	/** The Score Card display. */
    public var results :MovieClip;

    /** The preloader display. */
    protected var _preloader :Sprite;

    /** The main game display. */
    protected var _game :MovieClip;

    /** The game camera. */
    protected var _camera :MovieClip;

    /** The background. */
    protected var _background :MovieClip;

    /** The ground. */
    protected var _ground :MovieClip;

    /** The y coordinate of the horizon (at which sprites become points). */
    protected var _horizon :Number;

    /** The y coordinate of the lip (at which sprites becomes full-sized). */
    protected var _lip :Number;

    /** The cursor sprite. */
    protected var _cursor :MovieClip;

    /** Whether or not the cursor is currently "on" (or transitioning thereto). */
    protected var _cursorOn :Boolean = true;

    /** The player goal sprite. */
    protected var _goal :MovieClip;

    /** The actors in the view. */
    protected var _actors :Array = new Array();

    /** The time of the last frame. */
    protected var _timer :int = getTimer();

    /** The last time we did a per-second update. */
    protected var _lastPerSecond :int = _timer;

    /** The number of frames rendered in the last second. */
    protected var _frameCount :int = 0;

    /** An effect to play on the camera. */
    protected var _cameraEffect :String;

    /** The number of background layers. */
    protected static const BACKGROUND_LAYERS :int = 5;

    /** The exponential rate at which the camera approaches its target position
     * (1/4 there after 1/30 of a second). */
    protected static const CAMERA_RATE :Number = 30 * Math.log(3/4);

    /** The camera effects, in order of intensity. */
    protected static const CAMERA_EFFECTS :Array = [ "x_light", "light", "medium" ];

    /** The array of possible grades. */
    protected static const GRADES :Array = [ "S", "A", "B", "C", "D", "F" ];

    /** The required percent score for each grade. */
    protected static const GRADE_LEVELS :Array = [ 100, 90, 80, 70, 60, 0 ];
}
}
