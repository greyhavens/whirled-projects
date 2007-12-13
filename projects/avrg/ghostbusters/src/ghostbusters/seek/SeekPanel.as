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

import ghostbusters.Game;

public class SeekPanel extends Sprite
{
    public function SeekPanel (model :SeekModel)
    {
        _model = model;

        buildUI();

        _roomSize = model.getRoomSize();
        if (_roomSize == null) {
            Game.log.warning("Can't get room size! Aii!");
            _roomSize = new Rectangle(0, 0, 700, 500);
        }
        Game.log.debug("Room size: " + _roomSize);

        this.addEventListener(Event.ADDED_TO_STAGE, handleAdded);
        this.addEventListener(Event.REMOVED_FROM_STAGE, handleRemoved);
    }

    override public function hitTestPoint (
        x :Number, y :Number, shapeFlag :Boolean = false) :Boolean
    {
        return _ghost && _ghost.hitTestPoint(x, y, shapeFlag);
    }

    public function ghostPositionUpdate (pos :Point) :void
    {
        _ghost.newTarget(this.globalToLocal(pos));
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

    public function ghostSpeedUpdated () :void
    {
        _ghost.setSpeed(_model.getGhostSpeed());
    }

    protected function handleRemoved (evt :Event) :void
    {
        removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
        _lanternLoop.stop();
    }

    protected function handleAdded (evt :Event) :void
    {
        _lanternLoop = Sound(new LANTERN_LOOP_AUDIO()).play();
        addEventListener(Event.ENTER_FRAME, handleEnterFrame);
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
            lantern.newTarget(this.globalToLocal(pos), 0.5, false);
        }
    }

    protected function handleEnterFrame (evt :Event) :void
    {
        animateLanterns();

        if (_ghost != null) {
            _ghost.nextFrame();
        }

        var p :Point = new Point(Math.max(0, Math.min(_roomSize.width, this.mouseX)),
                                 Math.max(0, Math.min(_roomSize.height, this.mouseY)));
        p = this.localToGlobal(p);

        // bow to reality: nobody wants to watch roundtrip lag in action
        if (!Game.DEBUG) {
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

    protected function buildUI () :void
    {
        _dimBack = new Sprite();
        _dimBack.blendMode = BlendMode.LAYER;
        this.addChild(_dimBack);

        _dimFront = new Sprite();

        var g :Graphics = _dimFront.graphics;
        g.beginFill(0x000000);
        g.drawRect(0, 0, 2000, 1000);
        g.endFill();

        _dimFront.alpha = 0.7;
        _dimBack.addChild(_dimFront);

        _lightLayer = new Sprite();
        this.addChild(_lightLayer);

        _maskLayer = new Sprite();
        this.addChild(_maskLayer);

        _ghost = new HidingGhost(_model.getGhostSpeed());
        _ghost.addEventListener(MouseEvent.CLICK, ghostClick);
        this.addChild(_ghost);
        _ghost.mask = _maskLayer;
    }

    protected var _model :SeekModel;

    protected var _roomSize :Rectangle;

    protected var _lanterns :Dictionary = new Dictionary();

    protected var _ghost :HidingGhost;

    protected var _ticker :int;

    protected var _dimBack :Sprite;
    protected var _dimFront :Sprite;

    protected var _lightLayer :Sprite;
    protected var _maskLayer :Sprite;

    protected var _lanternLoop :SoundChannel;

    protected static const FRAMES_PER_UPDATE :int = 6;

    [Embed(source="../../../rsrc/wind.mp3")]
    protected static const LANTERN_LOOP_AUDIO :Class;
}
}
