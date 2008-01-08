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

import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.geom.Rectangle;

import flash.utils.Dictionary;
import flash.utils.setTimeout;

import com.whirled.AVRGameControl;
import com.whirled.AVRGameControlEvent;

import com.threerings.util.CommandEvent;
import com.threerings.util.Random;

import ghostbusters.Content;
import ghostbusters.Dimness;
import ghostbusters.GameController;
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
            _dimness.removeChild(lantern.hole);
            _lightLayer.removeChild(lantern.light);
            _maskLayer.removeChild(lantern.mask);
            delete _lanterns[playerId];
        }
    }

    public function playerLanternMoved (playerId :int, pos :Point) :void
    {
        updateLantern(playerId, pos);
    }

    public function ghostZestUpdated () :void
    {
        _ghost.setSpeed(_model.getGhostZest());

        var lantern :Lantern = _lanterns[_model.getMyId()];
        if (lantern != null) {
            lantern.setGhostZest(_model.getGhostZestFraction());
        }
    }

    public function ghostZapped () :void
    {
        zapStart();
    }

    public function appearGhost () :void
    {
        _alphaFrames = _ghost.appear(spawnGhost);
        // TODO: this should instead match the true spawn point of the MOB
        _ghost.newTarget(new Point(_roomSize.width/2, 200));
        _ghost.mask = null;
    }

    protected function spawnGhost () :void
    {
        CommandEvent.dispatch(this, GameController.SPAWN_GHOST);
    }

    protected function handleRemoved (evt :Event) :void
    {
        removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
        _lanternLoop.stop();
    }

    protected function handleAdded (evt :Event) :void
    {
        _lanternLoop = Sound(new Content.LANTERN_LOOP_AUDIO()).play();
        addEventListener(Event.ENTER_FRAME, handleEnterFrame);
    }

    protected function updateLantern (playerId :int, pos :Point) :void
    {
        var lantern :Lantern = _lanterns[playerId];
        if (lantern == null) {
            // a new lantern just appears, no splines involved
            lantern = new Lantern(playerId, pos, playerId == _model.getMyId());
            _lanterns[playerId] = lantern;

            _maskLayer.addChild(lantern.mask);
            _lightLayer.addChild(lantern.light);
            _dimness.addChild(lantern.hole);

        } else {
            // just set our aim for p
            lantern.newTarget(this.globalToLocal(pos), 0.5, false);
        }
    }

    protected function handleEnterFrame (evt :Event) :void
    {
        animateLanterns();

        var p :Point = new Point(Math.max(0, Math.min(_roomSize.width, this.mouseX)),
                                 Math.max(0, Math.min(_roomSize.height, this.mouseY)));
        p = this.localToGlobal(p);

        // bow to reality: nobody wants to watch roundtrip lag in action
        if (!Game.DEBUG) {
            updateLantern(_model.getMyId(), p);
        }

        if (_alphaFrames > 1) {
            // transition dimness factor slowly
            var alpha :Number = _dimness.getAlpha();
            _dimness.setAlpha(alpha + (0.6 - alpha)/_alphaFrames);
            _alphaFrames -= 1;
        }

        if (_ghost != null) {
            _ghost.nextFrame();

            if (_zapping > 0) {
                _zapping -= 1;
                if (_zapping == 0) {
                    Game.gameController.panel.hud.showArcs(false);
                    zapStop();
                } else {
                    Game.gameController.panel.hud.showArcs(true);
                }
            }

            if (_zapping == 0 && _ghost.hitTestPoint(p.x, p.y, true)) {
                // the player is hovering right over the ghost!
                CommandEvent.dispatch(this, SeekController.ZAP_GHOST);
            }
        }

        // see if it's time to send an update on our own position
        _ticker ++;
        if (_ticker < FRAMES_PER_UPDATE) {
            return;
        }
        _ticker = 0;

        _model.transmitLanternPosition(p);

        if (_ghost != null && _alphaFrames == 0 && _ghost.isIdle()) {
            _model.constructNewGhostPosition(_ghost.getGhostBounds());
        }
    }

    protected function zapStart () :void
    {
        _zapping = 60;
        Sound(new Content.LANTERN_GHOST_SCREECH()).play();

        // as a temporary visual effect, brighten the ghost by 50%
        _ghost.transform.colorTransform = new ColorTransform(1.5, 1.5, 1.5);
    }

    protected function zapStop () :void
    {
        _ghost.transform.colorTransform = new ColorTransform();
    }

    protected function animateLanterns () :void
    {
        for each (var lantern :Lantern in _lanterns) {
            lantern.nextFrame();
        }
    }

    protected function buildUI () :void
    {
        _dimness = new Dimness(0.9, true);
        this.addChild(_dimness);

        _lightLayer = new Sprite();
        this.addChild(_lightLayer);

        _maskLayer = new Sprite();
        this.addChild(_maskLayer);

        _ghost = new HidingGhost(_model.calculateGhostSpeed());
        this.addChild(_ghost);
        _ghost.mask = _maskLayer;
    }

    protected var _model :SeekModel;

    protected var _roomSize :Rectangle;

    protected var _lanterns :Dictionary = new Dictionary();

    protected var _ghost :HidingGhost;

    protected var _zapping :int;

    protected var _ticker :int;
    protected var _alphaFrames :int = 0;

    protected var _dimness :Dimness;

    protected var _lightLayer :Sprite;
    protected var _maskLayer :Sprite;

    protected var _lanternLoop :SoundChannel;

    protected static const FRAMES_PER_UPDATE :int = 6;
}
}
