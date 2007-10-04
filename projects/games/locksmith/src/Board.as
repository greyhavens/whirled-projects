// $Id$

package {

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.BlendMode;

import flash.events.Event;

import flash.geom.Matrix;

import mx.core.MovieClipAsset;

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
        addChild(new Clock());

        _loadedLauncher = -1;

        updateTurnIndicator(ScoreBoard.MOON_PLAYER);

        Locksmith.registerEventListener(this, Event.ENTER_FRAME, enterFrame);
    }

    public function addRing (ring :Ring) :void
    {
        // rings go under the marble layer, the turn indicator, the goal dome, and the clock hands.
        addChildAt(_ring = ring, numChildren - 4);
    }

    public function updateTurnIndicator (player :int) :void
    {
        var firstTurn :Boolean = true;
        if (_turnIndicator != null) {
            removeChild(_turnIndicator);
            Locksmith.unregisterEventListener(_turnIndicator, Event.ENTER_FRAME, 
                                              indicatorEnterFrame);
            firstTurn = false;

            // temp
            if (_turnIndicator is TURN_TO_MOON) {
                player = ScoreBoard.SUN_PLAYER;
            } else {
                player = ScoreBoard.MOON_PLAYER;
            }
        }
        _turnIndicator = 
            new (player == ScoreBoard.MOON_PLAYER ? TURN_TO_MOON : TURN_TO_SUN)() as MovieClipAsset;
        _turnIndicator.cacheAsBitmap = true;
        if (firstTurn) {
            _turnIndicator.gotoAndStop(_turnIndicator.totalFrames);
        }
        Locksmith.registerEventListener(_turnIndicator, Event.ENTER_FRAME, indicatorEnterFrame);
        addChild(_turnIndicator);
    }

    public function loadNextLauncher () :void
    {
        var launcherAngles :Array = [ { sun: 45, moon: 135 }, { sun: 0, moon: 180 },
            { sun: 315, moon: 225 } ];
        var launcherHoles :Array = [ { sun: 2, moon: 6 }, { sun: 0, moon: 8 },
            { sun: 14, moon: 10 } ];
        _loadedLauncher = (_loadedLauncher + 1) % 3;
        var trans :Matrix = new Matrix();
        trans.translate(Ring.SIZE_PER_RING * 5.5, 0);
        trans.rotate(-launcherAngles[_loadedLauncher].sun * Math.PI / 180);
        var sunLaunchMarble :Marble = new Marble(this, _ring.largest, 
            launcherHoles[_loadedLauncher].sun, Marble.SUN, trans);
        addChild(sunLaunchMarble);
        trans = new Matrix();
        trans.translate(Ring.SIZE_PER_RING * 5.5, 0);
        trans.rotate(-launcherAngles[_loadedLauncher].moon * Math.PI / 180);
        var moonLaunchMarble :Marble = new Marble(this, _ring.largest, 
            launcherHoles[_loadedLauncher].moon, Marble.MOON, trans);
        addChild(moonLaunchMarble);
        DoLater.instance.registerAt(DoLater.ROTATION_END, function (currentStage :int) :void {
            sunLaunchMarble.launch();
            moonLaunchMarble.launch();
        });
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
            _marbles.splice(_marbles.indexOf(child), 1);
            return _marbleLayer.removeChild(child);
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
        if (_scoreBoard != null) {
            if (type == Marble.MOON) {
                _scoreBoard.moonScore++;
            } else {
                _scoreBoard.sunScore++;
            }   
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

    protected function indicatorEnterFrame (evt :Event) :void
    {
        if (_turnIndicator.currentFrame == _turnIndicator.totalFrames) {
            _turnIndicator.stop();
        }
    }

    protected function enterFrame (evt :Event) :void
    {
        _marbles.sort(function (obj1 :DisplayObject, obj2 :DisplayObject) :int {
            return obj1.y < obj2.y ? -1 : (obj2.y < obj1.y ? 1 : 0);
        });
        for (var ii :int = 0; ii < _marbles.length; ii++) {
            _marbleLayer.setChildIndex(_marbles[ii], ii);
        }
    }

    [Embed(source="../rsrc/locksmith_art.swf#background")]
    protected static const BACKGROUND :Class;
    [Embed(source="../rsrc/locksmith_art.swf#dome")]
    protected static const GOAL_DOME :Class;

    [Embed(source="../rsrc/locksmith_art.swf#turn_to_moon")]
    protected static const TURN_TO_MOON :Class;
    [Embed(source="../rsrc/locksmith_art.swf#turn_to_sun")]
    protected static const TURN_TO_SUN :Class;

    protected var _loadedLauncher :int;
    protected var _ring :Ring;
    protected var _scoreBoard :ScoreBoard;
    /** This is where all the marbles get deposited.  Then on each frame, they are reordered 
     * according to position so that their drop shadows don't look wonky. */
    protected var _marbleLayer :Sprite;
    protected var _marbles :Array = [];
    protected var _turnIndicator :MovieClipAsset;
}
}
