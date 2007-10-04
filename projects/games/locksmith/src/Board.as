// $Id$

package {

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.BlendMode;

import flash.events.Event;

import flash.geom.Matrix;

public class Board extends Sprite
{
    public function Board () 
    {
        var colorBackground :Sprite = new Sprite();
        colorBackground.graphics.beginFill(BACKGROUND_COLOR);
        colorBackground.graphics.drawRect(-Locksmith.DISPLAY_WIDTH / 2 , 
            -Locksmith.DISPLAY_HEIGHT / 2, Locksmith.DISPLAY_WIDTH, Locksmith.DISPLAY_HEIGHT);
        addChild(colorBackground);
        addGoals();
        addChild(_marbleLayer = new Sprite());

        _loadedLauncher = -1;

        Locksmith.registerEventListener(this, Event.ENTER_FRAME, enterFrame);
    }

    public function addRing (ring :Ring) :void
    {
        addChildAt(_ring = ring, numChildren - 1);
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

    protected function addGoals () :void
    {
        // red goal
        var goals :Sprite = new Sprite();
        goals.blendMode = BlendMode.LAYER;
        var goal :Sprite = new Sprite();
        var color :Sprite = new Sprite();
        color.graphics.beginFill(LAUNCH_RED);
        color.graphics.drawCircle(0, 0, Ring.SIZE_PER_RING);
        color.graphics.endFill();
        goal.addChild(color);
        var mask :Sprite = new Sprite();
        mask.graphics.beginFill(0);
        mask.graphics.drawRect(-Ring.SIZE_PER_RING, -Ring.SIZE_PER_RING, Ring.SIZE_PER_RING, 
            Ring.SIZE_PER_RING * 2);
        mask.graphics.endFill();
        mask.blendMode = BlendMode.ERASE;
        goal.addChild(mask);
        goals.addChild(goal);

        // blue goal
        goal = new Sprite();
        goal.blendMode = BlendMode.LAYER;
        color = new Sprite();
        color.graphics.beginFill(LAUNCH_BLUE);
        color.graphics.drawCircle(0, 0, Ring.SIZE_PER_RING);
        color.graphics.endFill();
        goal.addChild(color);
        mask = new Sprite();
        mask.graphics.beginFill(0);
        mask.graphics.drawRect(0, -Ring.SIZE_PER_RING, Ring.SIZE_PER_RING, 
            Ring.SIZE_PER_RING * 2);
        mask.graphics.endFill();
        mask.blendMode = BlendMode.ERASE;
        goal.addChild(mask);
        goals.addChild(goal);

        // neutral zone
        var zone :Sprite = new Sprite();
        zone.blendMode = BlendMode.LAYER;
        color = new Sprite();
        color.graphics.beginFill(0);
        color.graphics.drawCircle(0, 0, Ring.SIZE_PER_RING);
        color.graphics.endFill();
        zone.addChild(color);
        mask = new Sprite();
        mask.graphics.beginFill(0);
        mask.graphics.drawRect(Ring.SIZE_PER_RING / 2, -Ring.SIZE_PER_RING, Ring.SIZE_PER_RING / 2,
            Ring.SIZE_PER_RING * 2);
        mask.graphics.endFill();
        mask.blendMode = BlendMode.ERASE;
        zone.addChild(mask);
        mask = new Sprite();
        mask.graphics.beginFill(0);
        mask.graphics.drawRect(-Ring.SIZE_PER_RING, -Ring.SIZE_PER_RING, Ring.SIZE_PER_RING / 2, 
            Ring.SIZE_PER_RING * 2);
        mask.blendMode = BlendMode.ERASE;
        zone.addChild(mask);
        goals.addChild(zone);

        addChild(goals);
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

    protected static const LAUNCH_BLUE :int = 0x6D7BFC;
    protected static const LAUNCH_RED :int = 0xFE8585;

    protected static const BACKGROUND_COLOR :int = 0x5C4A38;

    protected var _loadedLauncher :int;
    protected var _ring :Ring;
    protected var _scoreBoard :ScoreBoard;
    /** This is where all the marbles get deposited.  Then on each frame, they are reordered 
     * according to position so that their drop shadows don't look wonky. */
    protected var _marbleLayer :Sprite;
    protected var _marbles :Array = [];
}
}
