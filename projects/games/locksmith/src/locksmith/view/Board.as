//
// $Id$

package locksmith.view {

import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Matrix;

import com.threerings.util.Log;

import com.whirled.game.GameControl

import com.whirled.contrib.EventHandlers;

import locksmith.model.Marble;
import locksmith.model.Player;
import locksmith.model.Ring;

public class Board extends Sprite
{
    public function Board () 
    {
        var background :DisplayObject = new BACKGROUND() as DisplayObject;
        background.cacheAsBitmap = true;
        addChild(background);
        var goalDome :DisplayObject = new GOAL_DOME() as DisplayObject;
        goalDome.cacheAsBitmap = true;
        addChild(goalDome);
        addChild(_ringLayer = new Sprite());
        addChild(_marbleLayer = new Sprite());
        addChild(_clock = new Clock(turnTimeout));
        var launcherLayer :Sprite = new Sprite();
        addChild(launcherLayer);
        initLaunchers(launcherLayer);

        EventHandlers.registerListener(this, Event.ENTER_FRAME, enterFrame);
    }

    public function get clock () :Clock
    {
        return _clock;
    }

    public function addRing (ring :Ring) :void
    {
//        if (_clearRings) {
//            _ring = _ring.smallest;
//            while (_ring != null) {
//                removeChild(_ring);
//                _ring = _ring.outer;
//            }
//            _clearRings = false;
//        }
//        var insertIndex :int = numChildren - RING_LAYER;
//        if (_turnIndicator == null) {
//            insertIndex++;
//        }
//        addChildAt(_ring = ring, insertIndex);
    }

    public function setActiveRing (ringNum :int) :void
    {
        _clock.setRingIndicator(ringNum);
    }

    public function marbleIsRoaming (marble :MarbleSprite, roaming :Boolean) :void
    {
        var ii :int = _roamingMarbles.indexOf(marble);
        if (roaming && ii == -1) {
            _roamingMarbles.push(marble);
        } else if (!roaming && ii != -1) {
            _roamingMarbles.splice(ii, 1);
        }
    }

    public function getMarbleGoingToHole (ring :int, hole :int) :Marble
    {
//        for each (var marble :Marble in _roamingMarbles) {
//            var destination :int = marble.getDestination();
//            if (destination == -1) {
//                continue;
//            }
//
//            var destHole :int = destination % Marble.RING_MULTIPLIER;
//            var destRing :int = (destination - destHole) / Marble.RING_MULTIPLIER;
//            if (ring == destRing && hole == destHole) {
//                return marble;
//            }
//        }
        return null;
    }

    public function updateTurnIndicator (player :int) :void
    {
//        var firstTurn :Boolean = true;
//        if (_turnIndicator != null) {
//            removeChild(_turnIndicator);
//            firstTurn = false;
//        }
//        _turnIndicator = 
//            new (player == ScoreBoard.MOON_PLAYER ? TURN_TO_MOON : TURN_TO_SUN)() as MovieClip;
//        _turnIndicator.cacheAsBitmap = true;
//        if (firstTurn) {
//            _turnIndicator.gotoAndStop(_turnIndicator.totalFrames);
//        }
//        addChild(_turnIndicator);
    }

    public function loadNextLauncher () :void
    {
//        _loadedLauncher = (_loadedLauncher + 1) % 3;
//        var trans :Matrix = new Matrix();
//        trans.translate(Ring.SIZE_PER_RING * 5.5, 0);
//        trans.rotate(-LAUNCHER_ANGLES[_loadedLauncher].sun * Math.PI / 180);
//        var sunLaunchMarble :Marble = new Marble(this, _ring.largest, 
//            LAUNCHER_HOLES[_loadedLauncher].sun, Marble.SUN, trans);
//        var sunLauncher :LaunchAnimation = 
//            _launchers[ScoreBoard.SUN_PLAYER][_loadedLauncher] as LaunchAnimation;
//        sunLauncher.load(sunLaunchMarble);
//
//        trans = new Matrix();
//        trans.translate(Ring.SIZE_PER_RING * 5.5, 0);
//        trans.rotate(-LAUNCHER_ANGLES[_loadedLauncher].moon * Math.PI / 180);
//        var moonLaunchMarble :Marble = new Marble(this, _ring.largest, 
//            LAUNCHER_HOLES[_loadedLauncher].moon, Marble.MOON, trans);
//        var moonLauncher :LaunchAnimation = 
//            _launchers[ScoreBoard.MOON_PLAYER][_loadedLauncher] as LaunchAnimation;
//        moonLauncher.load(moonLaunchMarble);
//        prepareLaunch(sunLauncher, moonLauncher);
    }

    override public function addChild (child :DisplayObject) :DisplayObject
    {
//        if (child is Marble) {
//            _marbles.push(child);
//            return _marbleLayer.addChild(child);
//        } else {
            return super.addChild(child);
//        }
    }

    override public function removeChild (child :DisplayObject) :DisplayObject
    {
//        if (child is Marble) {
//            var index :int = _marbles.indexOf(child);
//            if (index == -1) {
//                return child.parent.removeChild(child);
//            } else {
//                _marbles.splice(index, 1);
//                return _marbleLayer.removeChild(child);
//            }
//        } else {
            return super.removeChild(child);
//        }
    }

    public function set scoreBoard (scoreBoard :ScoreBoard) :void 
    {
        _scoreBoard = scoreBoard;
    }

    public function scorePoint (type :int) :void
    {
        // TODO: This will have to register a method for the end of the stage, and do all of the 
        // scoring at once - with the current system, the end game score may not be correct if more
        // than one point is scored in that stage.
        if (_scoreBoard != null) {
            _scoreBoard.scorePoint(type);
        }
    }

    public function stopRotation () :void
    {
//        var ring :Ring = _ring.smallest;
//        while (ring != null) {
//            ring.stopRotation();
//            ring = ring.outer;
//        }
    }

    public function marbleToGoal (marble :MarbleSprite, goalType :int) :void
    {
//        removeChild(marble);
//        var goalBoard :Sprite = new Sprite();
//        addChild(goalBoard);
//        goalBoard.addChild(marble);
//        var marbleMask :Sprite = new Sprite();
//        marbleMask.graphics.beginFill(0);
//        marbleMask.graphics.drawRect(
//            goalType == Marble.SUN ? -Ring.SIZE_PER_RING * 2.5 : Ring.SIZE_PER_RING * 0.5, 
//            -Ring.SIZE_PER_RING * 2, Ring.SIZE_PER_RING * 2, Ring.SIZE_PER_RING * 4);
//        goalBoard.addChild(marbleMask);
//        goalBoard.mask = marbleMask;
//
//        // marbles remove themselves when they're done with the goal animation.
//        marble.addEventListener(Event.REMOVED, function (evt :Event) :void {
//            goalBoard.parent.removeChild(goalBoard);
//        });
    }

//    protected function prepareLaunch (sun :LaunchAnimation, moon :LaunchAnimation) :void
//    {
//        DoLater.instance.registerAt(DoLater.ROTATION_END, function (currentStage :int) :void {
//            sun.launch();
//            moon.launch();
//        });
//    }

    protected function turnTimeout () :void
    {
//        if (_wgc != null && _wgc.game.isMyTurn()) {
//            _wgc.game.startNextTurn();
//        }
    }

    protected function initLaunchers (launcherLayer :Sprite) :void
    {
        for each (var launcher :Launcher in Launcher.values()) {
            var trans :Matrix = new Matrix();
            trans.translate(RingSprite.SIZE_PER_RING * 5.5, 0);
            trans.rotate(-launcher.getAngle(Player.MOON) * Math.PI / 180);
            var moonLauncher :MovieClip = new Board["GATE_MOON_" + launcher.name()]() as MovieClip;
            moonLauncher.transform.matrix = trans;
            moonLauncher.scaleX = moonLauncher.scaleY = -1;
            launcherLayer.addChild(moonLauncher);
            // TODO:
            //_launchers[ScoreBoard.MOON_PLAYER][ii] = new LaunchAnimation(this, moonLauncher);

            trans = new Matrix();
            trans.translate(RingSprite.SIZE_PER_RING * 5.5, 0);
            trans.rotate(-launcher.getAngle(Player.SUN) * Math.PI / 180);
            var sunLauncher :MovieClip = new Board["GATE_SUN_" + launcher.name()]() as MovieClip;
            sunLauncher.transform.matrix = trans;
            sunLauncher.scaleX = -1;
            launcherLayer.addChild(sunLauncher);
            // TODO:
            //_launchers[ScoreBoard.SUN_PLAYER][ii] = new LaunchAnimation(this, sunLauncher);
        }
    }

    protected function enterFrame (evt :Event) :void
    {
        _marbles.sort(function (obj1 :DisplayObject, obj2 :DisplayObject) :int {
            if (obj1.y == obj2.y) {
                var x1 :Number = Math.abs(obj1.x);
                var x2 :Number = Math.abs(obj2.x);
                return x1 < x2 ? -1 : (x2 < x1 ? 1 : 0);
            }
            return obj1.y < obj2.y ? -1 : 1;
        });
        for (var ii :int = 0; ii < _marbles.length; ii++) {
            _marbleLayer.setChildIndex(_marbles[ii], ii);
        }

        if (_turnIndicator != null && _turnIndicator.currentFrame == _turnIndicator.totalFrames) {
            _turnIndicator.stop();
        }
    }

    private static const log :Log = Log.getLog(Board);

    [Embed(source="../../../rsrc/locksmith_art.swf#background")]
    protected static const BACKGROUND :Class;
    [Embed(source="../../../rsrc/locksmith_art.swf#dome")]
    protected static const GOAL_DOME :Class;

    [Embed(source="../../../rsrc/locksmith_art.swf#turn_to_moon")]
    protected static const TURN_TO_MOON :Class;
    [Embed(source="../../../rsrc/locksmith_art.swf#turn_to_sun")]
    protected static const TURN_TO_SUN :Class;

    [Embed(source="../../../rsrc/locksmith_art.swf#gate_moon_upper")]
    protected static const GATE_MOON_UP :Class;
    [Embed(source="../../../rsrc/locksmith_art.swf#gate_moon")]
    protected static const GATE_MOON_MID :Class;
    [Embed(source="../../../rsrc/locksmith_art.swf#gate_moon_lower")]
    protected static const GATE_MOON_LOW :Class;
    [Embed(source="../../../rsrc/locksmith_art.swf#gate_sun_upper")]
    protected static const GATE_SUN_UP :Class;
    [Embed(source="../../../rsrc/locksmith_art.swf#gate_sun")]
    protected static const GATE_SUN_MID :Class;
    [Embed(source="../../../rsrc/locksmith_art.swf#gate_sun_lower")]
    protected static const GATE_SUN_LOW :Class;

    protected var _loadedLauncher :int;
    protected var _ring :Ring;
    protected var _scoreBoard :ScoreBoard;
    protected var _ringLayer :Sprite;
    protected var _marbleLayer :Sprite;
    protected var _marbles :Array = [];
    protected var _turnIndicator :MovieClip;
    protected var _clock :Clock;
    protected var _roamingMarbles :Array = [];
    protected var _clearRings :Boolean = false;
    protected var _launchers :Array = [[],[]];
}
}
//
//import flash.display.MovieClip;
//import flash.display.Sprite;
//import flash.events.Event;
//
//import com.threerings.util.Log;
//
//import com.whirled.contrib.EventHandlers;
//
//import locksmith.Marble;
//
//class LaunchAnimation
//{
//    public function LaunchAnimation (board :Sprite, launcherMovie :MovieClip)
//    {
//        _board = board;
//        _movie = launcherMovie;
//        _movie.gotoAndStop(_movie.totalFrames);
//    }
//
//    public function load (marble :Marble) :void
//    {
//        _marble = marble;
//        EventHandlers.registerListener(_movie, Event.ENTER_FRAME, 
//            function (event :Event) :void {
//                _movie.gotoAndStop(_movie.currentFrame - 1);
//                if (_movie.currentFrame == MARBLE_FRAME) {
//                    _board.addChild(marble);
//                } else if (_movie.currentFrame == 1) {
//                    EventHandlers.unregisterListener(
//                        _movie, Event.ENTER_FRAME, arguments.callee);
//                }
//            });
//    }
//
//    public function launch () :void
//    {
//        if (_marble == null) {
//            log.warning("asked to launch null marble");
//            return;
//        }
//
//        EventHandlers.registerListener(_movie, Event.ENTER_FRAME,
//            function (event :Event) :void {
//                _movie.gotoAndStop(_movie.currentFrame + 1);
//                if (_movie.currentFrame == MARBLE_FRAME) {
//                    _marble.launch();
//                    _marble == null;
//                } else if (_movie.currentFrame == _movie.totalFrames) {
//                    EventHandlers.unregisterListener(
//                        _movie, Event.ENTER_FRAME, arguments.callee);
//                }
//            });
//    }
//
//    private static const log :Log = Log.getLog(LaunchAnimation);
//
//    protected static const MARBLE_FRAME :int = 6;
//
//    protected var _movie :MovieClip;
//    protected var _marble :Marble;
//    protected var _board :Sprite;
//}
