// $Id$

package {

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.BlendMode;

import flash.events.Event;

import flash.geom.Matrix;

import mx.core.MovieClipAsset;

import com.threerings.util.Log;

import com.whirled.WhirledGameControl;

import com.whirled.contrib.EventHandlers;

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
        addChild(_marbleLayer = new Sprite());
        addChild(_clock = new Clock(turnTimeout));

        _loadedLauncher = -1;

        EventHandlers.registerEventListener(this, Event.ENTER_FRAME, enterFrame);
    }

    public function get clock () :Clock
    {
        return _clock;
    }

    public function set control (wgc :WhirledGameControl) :void
    {
        _wgc = wgc;
    }

    public function reinit () :void
    {
        // indicate that the next time addRing is called, we should first remove all the old ones.
        _clearRings = true;

        var index :int = getChildIndex(_marbleLayer);
        removeChild(_marbleLayer);
        addChildAt(_marbleLayer = new Sprite(), index);
        _marbles = [];
        _roamingMarbles = [];
        _loadedLauncher = -1;
    }

    public function addRing (ring :Ring) :void
    {
        if (_clearRings) {
            _ring = _ring.smallest;
            while (_ring != null) {
                removeChild(_ring);
                _ring = _ring.outer;
            }
            _clearRings = false;
        }
        var insertIndex :int = numChildren - RING_LAYER;
        if (_turnIndicator == null) {
            insertIndex++;
        }
        addChildAt(_ring = ring, insertIndex);
    }

    public function setActiveRing (ringNum :int) :void
    {
        _clock.setRingIndicator(ringNum);
    }

    public function marbleIsRoaming (marble :Marble, roaming :Boolean) :void
    {
        var ii :int = _roamingMarbles.indexOf(marble);
        if (roaming) {
            if (ii != -1) {
                _roamingMarbles.splice(ii, 1);
            }
        } else {
            if (ii == -1) {
                _roamingMarbles.push(marble);
            }
        }
    }

    public function getMarbleGoingToHole (ring :int, hole :int) :Marble
    {
        for each (var marble :Marble in _roamingMarbles) {
            var destination :int = marble.getDestination();
            if (destination == -1) {
                continue;
            }

            var destHole :int = destination % Marble.RING_MULTIPLIER;
            var destRing :int = (destination - destHole) / Marble.RING_MULTIPLIER;
            if (ring == destRing && hole == destHole) {
                return marble;
            }
        }
        return null;
    }

    public function updateTurnIndicator (player :int) :void
    {
        var firstTurn :Boolean = true;
        if (_turnIndicator != null) {
            removeChild(_turnIndicator);
            firstTurn = false;
        }
        _turnIndicator = 
            new (player == ScoreBoard.MOON_PLAYER ? TURN_TO_MOON : TURN_TO_SUN)() as MovieClipAsset;
        _turnIndicator.cacheAsBitmap = true;
        if (firstTurn) {
            _turnIndicator.gotoAndStop(_turnIndicator.totalFrames);
        }
        addChild(_turnIndicator);
    }

    public function loadNextLauncher () :void
    {
        _loadedLauncher = (_loadedLauncher + 1) % 3;
        var trans :Matrix = new Matrix();
        trans.translate(Ring.SIZE_PER_RING * 5.5, 0);
        trans.rotate(-LAUNCHER_ANGLES[_loadedLauncher].sun * Math.PI / 180);
        var sunLaunchMarble :Marble = new Marble(this, _ring.largest, 
            LAUNCHER_HOLES[_loadedLauncher].sun, Marble.SUN, trans);
        addChild(sunLaunchMarble);
        trans = new Matrix();
        trans.translate(Ring.SIZE_PER_RING * 5.5, 0);
        trans.rotate(-LAUNCHER_ANGLES[_loadedLauncher].moon * Math.PI / 180);
        var moonLaunchMarble :Marble = new Marble(this, _ring.largest, 
            LAUNCHER_HOLES[_loadedLauncher].moon, Marble.MOON, trans);
        addChild(moonLaunchMarble);
        prepareLaunch(sunLaunchMarble, moonLaunchMarble);
    }

    override public function addChild (child :DisplayObject) :DisplayObject
    {
        if (child is Marble) {
            _marbles.push(child);
            return _marbleLayer.addChild(child);
        } else {
            return super.addChild(child);
        }
    }

    override public function removeChild (child :DisplayObject) :DisplayObject
    {
        if (child is Marble) {
            var index :int = _marbles.indexOf(child);
            if (index == -1) {
                return child.parent.removeChild(child);
            } else {
                _marbles.splice(index, 1);
                return _marbleLayer.removeChild(child);
            }
        } else {
            return super.removeChild(child);
        }
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
        var ring :Ring = _ring.smallest;
        while (ring != null) {
            ring.stopRotation();
            ring = ring.outer;
        }
    }

    public function marbleToGoal (marble :Marble, goalType :int) :void
    {
        removeChild(marble);
        var goalBoard :Sprite = new Sprite();
        addChild(goalBoard);
        goalBoard.addChild(marble);
        var marbleMask :Sprite = new Sprite();
        marbleMask.graphics.beginFill(0);
        marbleMask.graphics.drawRect(
            goalType == Marble.SUN ? -Ring.SIZE_PER_RING * 2.5 : Ring.SIZE_PER_RING * 0.5, 
            -Ring.SIZE_PER_RING * 2, Ring.SIZE_PER_RING * 2, Ring.SIZE_PER_RING * 4);
        goalBoard.addChild(marbleMask);
        goalBoard.mask = marbleMask;

        // marbles remove themselves when they're done with the goal animation.
        marble.addEventListener(Event.REMOVED, function (evt :Event) :void {
            goalBoard.parent.removeChild(goalBoard);
        });
    }

    protected function prepareLaunch (sun :Marble, moon :Marble) :void
    {
        DoLater.instance.registerAt(DoLater.ROTATION_END, function (currentStage :int) :void {
            sun.launch();
            moon.launch();
        });
    }

    protected function turnTimeout () :void
    {
        if (_wgc != null && _wgc.isMyTurn()) {
            _wgc.startNextTurn();
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

    [Embed(source="../rsrc/locksmith_art.swf#background")]
    protected static const BACKGROUND :Class;
    [Embed(source="../rsrc/locksmith_art.swf#dome")]
    protected static const GOAL_DOME :Class;

    [Embed(source="../rsrc/locksmith_art.swf#turn_to_moon")]
    protected static const TURN_TO_MOON :Class;
    [Embed(source="../rsrc/locksmith_art.swf#turn_to_sun")]
    protected static const TURN_TO_SUN :Class;

    // rings sit under the turn indicator, scoring dome, clock hands and marble layer.
    protected static const RING_LAYER :int = 4;

    protected static const LAUNCHER_ANGLES :Array = [ { sun: 45, moon: 135 }, { sun: 0, moon: 180 },
                                                      { sun: 315, moon: 225 } ];
    protected static const LAUNCHER_HOLES :Array = [ { sun: 2, moon: 6 }, { sun: 0, moon: 8 },
                                                     { sun: 14, moon: 10 } ];

    protected var _wgc :WhirledGameControl;
    protected var _loadedLauncher :int;
    protected var _ring :Ring;
    protected var _scoreBoard :ScoreBoard;
    /** This is where all the marbles get deposited.  Then on each frame, they are reordered 
     * according to position so that their drop shadows don't look wonky. */
    protected var _marbleLayer :Sprite;
    protected var _marbles :Array = [];
    protected var _turnIndicator :MovieClipAsset;
    protected var _clock :Clock;
    protected var _roamingMarbles :Array = [];
    protected var _clearRings :Boolean = false;
}
}
