//
// $Id$

package ghostbusters.seek {

import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.media.Sound;
import flash.media.SoundChannel;

import flash.events.Event;
import flash.events.MouseEvent;

import flash.geom.Point;
import flash.geom.Rectangle;

import flash.utils.Dictionary;

import com.whirled.AVRGameControl;
import com.whirled.AVRGameControlEvent;

import com.threerings.util.CommandEvent;
import com.threerings.util.Random;

public class SeekPanel extends Sprite
{
    public function SeekPanel (model :SeekModel)
    {
        _model = model;

        buildUI();
    }

    public function shutdown () :void
    {
        if (_lanternia.visible) {
            removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
        }
    }

    override public function hitTestPoint (
        x :Number, y :Number, shapeFlag :Boolean = false) :Boolean
    {
        return _ghost && _ghost.hitTestPoint(x, y, shapeFlag);
    }

    protected function buildUI () :void
    {
        _lanternia = new Sprite();
        _lanternia.visible = false;
        addChild(_lanternia);

        _dimBack = new Sprite();
        _dimBack.blendMode = BlendMode.LAYER;
        _lanternia.addChild(_dimBack);

        _dimFront = new Sprite();

        var g :Graphics = _dimFront.graphics;
        g.beginFill(0x000000);
        g.drawRect(0, 0, 2000, 1000);
        g.endFill();

        _dimFront.alpha = 0.7;
        _dimBack.addChild(_dimFront);

        _lightLayer = new Sprite();
        _lanternia.addChild(_lightLayer);

        _maskLayer = new Sprite();
        _lanternia.addChild(_maskLayer);

        _ghost = new HidingGhost(_model.getRoomId());
        _ghost.addEventListener(MouseEvent.CLICK, ghostClick);
        _lanternia.addChild(_ghost);
        _ghost.mask = _maskLayer;
        _ghost.x = 300;
        _ghost.y = 0;
    }

    public function ghostPositionUpdate (pos :Point) :void
    {
        _ghost.newTarget(_lanternia.globalToLocal(pos));
    }

    public function lanternOff () :void
    {
        removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
        _lanternia.visible = false;
    }

    public function lanternOn () :void
    {
        resetLoop();
        _lanternia.visible = true;
        _lanternLoop = Sound(new LANTERN_LOOP_AUDIO()).play();
        addEventListener(Event.ENTER_FRAME, handleEnterFrame);
    }

    protected function resetLoop () :void
    {
        if (_lanternLoop != null) {
            _lanternLoop.stop();
            _lanternLoop = null;
        }
    }

    public function playerLanternOff (playerId :int) :void
    {
        var lantern :Lantern = _lanterns[playerId];
        if (lantern) {
            _dimFront.removeChild(lantern.hole);
            _lightLayer.removeChild(lantern.light);
            _maskLayer.removeChild(lantern.mask);
            delete _lanterns[playerId];
        }
    }

    public function playerLanternMoved (playerId :int, pos :Point) :void
    {
        updateLantern(playerId, pos);
    }

    public function setGhostSpeed (speed :Number) :void
    {
        _ghost.setSpeed(speed);
    }

    protected function ghostClick (evt :MouseEvent) :void
    {
        CommandEvent.dispatch(this, SeekController.CLICK_GHOST);
    }

    protected function updateLantern (playerId :int, pos :Point) :void
    {
        var lantern :Lantern = _lanterns[playerId];
        if (lantern == null) {
            // a new lantern just appears, no splines involved
            lantern = new Lantern(playerId, pos);
            _lanterns[playerId] = lantern;

            _maskLayer.addChild(lantern.mask);
            _lightLayer.addChild(lantern.light);
            _dimFront.addChild(lantern.hole);

        } else {
            // just set our aim for p
            lantern.newTarget(_lanternia.globalToLocal(pos), 0.5, false);
        }
    }

    protected function handleEnterFrame (evt :Event) :void
    {
        animateLanterns();

        if (_ghost != null) {
            _ghost.nextFrame();
        }

        var p :Point = new Point(Math.max(0, Math.min(_width, _lanternia.mouseX)),
                                 Math.max(0, Math.min(_height, _lanternia.mouseY)));
        p = _lanternia.localToGlobal(p);

        // bow to reality: nobody wants to watch roundtrip lag in action
        if (!DEBUG) {
            updateLantern(_model.getMyId(), p);
        }

        // see if it's time to send an update on our own position
        _ticker ++;
        if (_ticker < FRAMES_PER_UPDATE) {
            return;
        }
        _ticker = 0;

        _model.transmitLanternPosition(p);

        if (_ghost != null && _ghost.isIdle()) {
            _model.constructNewGhostPosition(_ghost.getGhostBounds());
        }
    }

    protected function animateLanterns () :void
    {
        for each (var lantern :Lantern in _lanterns) {
            lantern.nextFrame();
        }
    }

    protected var _model :SeekModel;

    // TODO: temporary hard-coded
    protected var _width :int = 700;
    protected var _height :int = 500;

    protected var _lanterns :Dictionary = new Dictionary();

    protected var _ghost :HidingGhost;

    protected var _ticker :int;

    protected var _lanternia :Sprite;
    protected var _dimBack :Sprite;
    protected var _dimFront :Sprite;

    protected var _lightLayer :Sprite;
    protected var _maskLayer :Sprite;

    protected var _lanternLoop :SoundChannel;

    protected static const FRAMES_PER_UPDATE :int = 6;

    [Embed(source="../../../rsrc/wind.mp3")]
    protected static const LANTERN_LOOP_AUDIO :Class;

    protected static const DEBUG :Boolean = false;
}
}
