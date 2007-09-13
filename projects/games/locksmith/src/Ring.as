// $Id$

package {

import flash.display.Sprite;
import flash.display.BlendMode;

import flash.events.Event;

import flash.geom.Matrix;
import flash.geom.Point;

import flash.utils.getTimer;

import com.threerings.util.ArrayUtil;
import com.threerings.util.HashMap;

public class Ring extends Sprite 
{
    public static const RINGS_SIZE :int = 500;
    public static const SIZE_PER_RING :int = 34;

    public static const STATIONARY :int = 0;
    public static const CLOCKWISE :int = -1;
    public static const COUNTER_CLOCKWISE :int = 1;

    public function Ring (ringNumber :int, holes :Array) 
    {
        _ringNumber = ringNumber;
        _holes = holes;
        _marbles = new HashMap();

        // enables the use of BlendMode.ERASE on children
        blendMode = BlendMode.LAYER;

        _ring = new Sprite();
        addChild(_ring);
        setActive(false);

        var inner :Sprite = new Sprite();
        inner.graphics.beginFill(0);
        inner.graphics.drawCircle(0, 0, ringNumber * SIZE_PER_RING);
        inner.graphics.endFill();
        inner.blendMode = BlendMode.ERASE;
        addChild(inner);

        // give the marbles a little breating room
        var size :int = Marble.SIZE + 4;
        _holeSprites = new Sprite();
        for (var hole :int = 0; hole < holes.length; hole++) {
            var angle :Number = (2 * Math.PI / Math.pow(2, Locksmith.NUM_RINGS)) * holes[hole];
            var rect :Sprite = new Sprite();
            rect.graphics.beginFill(0);
            rect.graphics.drawRect(-size, -size / 2, size * 2, size);
            rect.graphics.endFill();
            var trans :Matrix = new Matrix();
            trans.translate((ringNumber + 0.5) * SIZE_PER_RING, 0);
            trans.rotate(-angle);
            rect.transform.matrix = trans;
            _holeSprites.addChild(rect);
        }
        _holeSprites.blendMode = BlendMode.ERASE;
        addChild(_holeSprites);

        Locksmith.registerEventListener(this, Event.ENTER_FRAME, enterFrame);
    }

    public function setActive (active :Boolean) :void
    {
        _ring.graphics.clear();
        _ring.graphics.beginFill(active ? _colorsActive[_ringNumber - 1] :
           _colorsInactive[_ringNumber - 1]);
        _ring.graphics.drawCircle(0, 0, (_ringNumber + 1) * SIZE_PER_RING);
        _ring.graphics.endFill();
    }

    public function rotate (direction :int) :void
    {
        _rotationStart = getTimer();
        _rotationDirection = direction;
        var stages :Array = [ { percent: 0.25, stage: DoLater.ROTATION_25 },
            { percent: 0.5, stage: DoLater.ROTATION_50 }, 
            { percent: 0.75, stage: DoLater.ROTATION_75 },
            { percent: 1, stage: DoLater.ROTATION_END } ];
        for (var curStage :int = 0; curStage < stages.length; curStage++) {
            var boundAngle :Number = (_baseRotation + stages[curStage].percent * Math.PI / 2 * 
                direction + Math.PI * 2) % Math.PI * 2;
            // call an anonymous function to create our DoLater function in order to bind boundAngle
            // properly.
            DoLater.instance.registerAt(stages[curStage].stage, function(angle :int) :Function {
                return function (currentStage :int) :void {
                    // check if any marbles in this ring need to move on
                    for each (var hole :int in _marbles.keys()) {
                        var marble :Marble = _marbles.get(hole);
                        marble.pos = (marble.pos + _rotationDirection + 16) % 16;
                        if (marble.launch()) {
                            _marbles.remove(hole);
                        }
                    }
                    // check if any marbles in the ring above need to move in
                    if (_outer != null) {
                        for each (hole in _holes) {
                            var offset :int = (_baseRotation / (Math.PI * 2)) * 16 +
                                DoLater.getPercent(currentStage) * 4 * _rotationDirection;
                            var pos :int = (hole + offset + 16) % 16;
                            _outer.launchFrom(pos);
                        }
                    }
                }
            }(boundAngle));
        }
        DoLater.instance.trigger(DoLater.ROTATION_BEGIN);
    }

    /** 
     * Called when the win condition has been met and the animation should stop
     */
    public function stopRotation () :void
    {
        _rotationDirection = STATIONARY;
        setActive(false);
    }

    public function getHoleAt (pos :int) :int 
    {
        var offset :int = (_baseRotation / (Math.PI * 2)) * 16 + DoLater.getPercent() *
            4 * _rotationDirection;
        var hole :int = (pos - offset + 16) % 16;

        return ArrayUtil.contains(_holes, hole) ? hole : -1;
    }

    public function holeIsEmpty (hole :int) :Boolean
    {
        return ArrayUtil.contains(_holes, hole) && _marbles.get(hole) == null;
    }

    public function putMarbleInHole (marble :Marble, hole :int) :void
    {
        if (holeIsEmpty(hole)) {
            _marbles.put(hole, marble);
        } else {
            throw new ArgumentError("attempted to put marble into non-empty hole: " + hole);
        }
    }

    public function getHoleLocation (hole :int) :Point
    {
        var angle :Number = (hole / 16) * Math.PI * 2 + _baseRotation + _rotationAngle;
        var trans :Matrix = new Matrix();
        trans.translate((_ringNumber + 0.5) * SIZE_PER_RING, 0);
        trans.rotate(-angle);
        return trans.transformPoint(new Point(0, 0));
    }

    public function get num () :int
    {
        return _ringNumber;
    }

    /** 
     * Rings implement a doubly-linked list, so that anybody who has a reference to one can get
     * at them all.
     */
    public function get inner () :Ring
    {
        return _inner;
    }

    public function set inner (ring :Ring) :void
    {
        _inner = ring;
    }

    public function get outer () :Ring
    {
        return _outer;
    }
     
    public function set outer (ring :Ring) :void
    {
        _outer = ring;
    }

    public function get largest () :Ring
    {
        return _outer != null ? _outer.largest : this;
    }

    public function get smallest () :Ring
    {
        return _inner != null ? _inner.smallest : this;
    }

    // For debugging
    public override function toString () :String
    {
        return "[Ring num=" + _ringNumber + ", baseRotation=" + _baseRotation + ", rotationAngle=" +
            _rotationAngle + "]";
    }

    protected function launchFrom (pos :int) :void
    {
        var hole :int = getHoleAt(pos);
        var marble :Marble = _marbles.get(hole) as Marble;
        if (marble != null) {
            if (marble.launch(true)) {
                _marbles.remove(hole);
                if (_outer != null && ArrayUtil.contains(_holes, hole)) {
                    _outer.launchFrom(pos);
                }
            }
        } 
    }

    protected function enterFrame (evt :Event) :void
    {
        if (_rotationDirection != STATIONARY) {
            var rotationPercent :Number = (getTimer() - _rotationStart) / ROTATION_TIME;
            DoLater.instance.atPercent(rotationPercent);
            var angle :Number;
            if (rotationPercent >= 1) {
                DoLater.instance.trigger(DoLater.ROTATION_END);
                angle = _baseRotation = (_baseRotation + (Math.PI / 2) * 
                    _rotationDirection + 2 * Math.PI) % (2 * Math.PI);
                _rotationDirection = STATIONARY;
                _rotationAngle = 0;
                DoLater.instance.trigger(DoLater.ROTATION_AFTER_END);
            } else {
                _rotationAngle = rotationPercent * (Math.PI / 2) * _rotationDirection;
                angle = _baseRotation + _rotationAngle;
            }
            var trans :Matrix = new Matrix();
            trans.rotate(-angle);
            _holeSprites.transform.matrix = trans;
            for each (var hole :int in _marbles.keys()) {
                var pos :Point = getHoleLocation(hole);
                var marble :Marble = _marbles.get(hole);
                marble.x = pos.x;
                marble.y = pos.y;
            }
        }
    }

    protected static const _colorsInactive :Array = [ 0x3E4E57, 0x51636E, 0x70828C, 0x899FAB ];
    protected static const _colorsActive :Array = [ 0x5B3C1C, 0x774E23, 0xA5662E, 0xCA7D38 ];

    protected static const ROTATION_TIME :int = 3000; // in ms

    protected var _ringNumber :int;
    protected var _ring :Sprite;
    protected var _position :int = 0;
    protected var _marbles :HashMap;
    protected var _holes :Array;
    protected var _holeSprites :Sprite;
    protected var _baseRotation :Number = 0;
    protected var _rotationAngle :Number = 0;
    protected var _rotationDirection :Number = STATIONARY;
    protected var _rotationStart :int = 0;
    protected var _inner :Ring;
    protected var _outer :Ring;
}
}
