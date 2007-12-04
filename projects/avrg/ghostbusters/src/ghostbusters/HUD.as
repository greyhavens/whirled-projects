//
// $Id$

package ghostbusters {

import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.MouseEvent;

import flash.filters.GlowFilter;

import flash.geom.Point;

import flash.utils.ByteArray;
import flash.utils.Dictionary;

import mx.controls.Button;
import mx.events.FlexEvent;

import com.whirled.AVRGameControl;
import com.whirled.AVRGameControlEvent;

import com.threerings.flash.DisplayUtil;
import com.threerings.flash.path.HermiteFunc;

import com.threerings.util.CommandEvent;
import com.threerings.util.EmbeddedSwfLoader;
import com.threerings.util.Log;
import com.threerings.util.StringUtil;

public class HUD extends Sprite
{
    public function HUD (control :AVRGameControl)
    {
        _control = control;

        _control.state.addEventListener(AVRGameControlEvent.PROPERTY_CHANGED, propertyChanged);
        _myId = _control.getPlayerId();

        var loader :EmbeddedSwfLoader = new EmbeddedSwfLoader();
        loader.addEventListener(Event.COMPLETE, handleHUDLoaded);
        loader.load(ByteArray(new HUD_VISUAL()));
    }

    public function shutdown () :void
    {
    }

    override public function hitTestPoint (
        x :Number, y :Number, shapeFlag :Boolean = false) :Boolean
    {
        return _hud && _hud.hitTestPoint(x, y, shapeFlag);
    }

    protected function handleHUDLoaded (evt :Event) :void
    {
        _mask = new Sprite();
        _mask.visible = false;
        _mask.blendMode = BlendMode.LAYER;
        this.addChild(_mask);

        _dim = new Sprite();
        with (_dim.graphics) {
            beginFill(0x000000);
            drawRect(0, 0, 2000, 1000);
            endFill();
        }
        _dim.alpha = 0.7;
        _mask.addChild(_dim);

        _hud = MovieClip(EmbeddedSwfLoader(evt.target).getContent());
        _hud.x = 10; // damn scrollbar
        _hud.y = 0;
        this.addChild(_hud);

        DisplayUtil.findInHierarchy(_hud, LANTERN).addEventListener(MouseEvent.CLICK, lanternClick);
        DisplayUtil.findInHierarchy(_hud, HELP).addEventListener(MouseEvent.CLICK, helpClick);
        DisplayUtil.findInHierarchy(_hud, LOOT).addEventListener(MouseEvent.CLICK, lootClick);
    }

    protected function lanternClick (evt :Event) :void
    {
        if (_mask.visible) {
            this.removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
            _mask.visible = false;

        } else {
            this.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
            _mask.visible = true;
        }
    }

    protected function propertyChanged (event: AVRGameControlEvent) :void
    {
        Log.getLog(HUD).debug("propchange event: " + event);
        if (event.name == "fl") {
            var bits :Array = event.value as Array;
            if (bits != null) {
                var playerId :int = int(bits[0]);
                if (_control.isPlayerHere(playerId)) {
                    // flash light update from a local player
                    if (bits.length == 1) {
                        // someone turned theirs off
                        updateFlashLight(playerId);
                    } else {
                        // someone turned theirs on or moved it
                        updateFlashLight(playerId, new Point(bits[1], bits[2]));
                    }
                }
            }
        }
    }

    protected function updateFlashLight (playerId :int, p :Point = null) :void
    {
        var light :FlashLight = _flashLights[playerId];
        if (p == null) {
            // removal
            if (light) {
                _dim.removeChild(light.sprite);
                delete _flashLights[playerId];
            }
            return;
        }

        // transform the point from room to overlay coordinates
        p = _control.roomToStage(p);
        p = _dim.globalToLocal(p);

        if (!light) {
            // a new flashlight just appears, no splines involved
            light = new FlashLight(getFlashLightSprite(), p);
            _flashLights[playerId] = light;
            _dim.addChild(light.sprite);
            return;
        }

        // else just set our aim for p
        light.newTarget(p);
    }

    protected function ghostVanished (id :String) :void
    {
        Log.getLog(HUD).debug("Ghost vanishing [id=" + id + "]");
    }

    protected function helpClick (evt :Event) :void
    {
        _control.spawnMob("ghost");

        Log.getLog(HUD).debug("Whee, button clicked: " + evt);
    }

    protected function lootClick (evt :Event) :void
    {
        Log.getLog(HUD).debug("Whee, button clicked: " + evt);
    }

    protected function handleEnterFrame (evt :Event) :void
    {
        animateFlashLights();

        // see if it's time to send an update on our own position
        _ticker ++;
        if (_ticker < FRAMES_PER_UPDATE) {
            return;
        }
        _ticker = 0;

        // if so transform the mouse position to room coordinates
        var p :Point = new Point(this.mouseX, this.mouseY);
        p = this.localToGlobal(p);
        p = _control.stageToRoom(p);

        // and off it goes!
        _control.state.setProperty("fl", [ _myId, p.x, p.y ], false);
    }

    protected function animateFlashLights () :void
    {
        for each (var light :FlashLight in _flashLights) {
            light.nextFrame();
        }
    }

    protected function getFlashLightSprite () :Sprite
    {
        var light :Sprite = new Sprite();

        var hole :Sprite = new Sprite();
        hole.blendMode = BlendMode.ERASE;
        with (hole.graphics) {
            beginFill(0xFFA040);
            drawCircle(0, 0, 40);
            endFill();
        }
        light.addChild(hole);

        var photons :Sprite = new Sprite();
        photons.alpha = 0.2;
        photons.filters = [ new GlowFilter(0xFF0000, 1, 32, 32, 2) ];
        with (photons.graphics) {
            beginFill(0xFF0000);
            drawCircle(0, 0, 40);
            endFill();
        }
        light.addChild(photons);

        return light;
    }

    protected var _control :AVRGameControl;
    protected var _myId :int;

    protected var _flashLights :Dictionary = new Dictionary();

    protected var _hud :MovieClip;

    protected var _ticker :int;

    protected var _mask :Sprite;
    protected var _dim :Sprite;
    protected var _hole :Sprite;
    protected var _light :Sprite;

    protected static const FRAMES_PER_UPDATE :int = 6;

    protected static const LANTERN :String = "lanternbutton";
    protected static const HELP :String = "helpbutton";
    protected static const LOOT :String = "lootbutton";

    [Embed(source="../../rsrc/HUD_visual.swf", mimeType="application/octet-stream")]
    protected static const HUD_VISUAL :Class;
}
}

import flash.display.Sprite;

import flash.geom.Point;

import com.threerings.flash.path.HermiteFunc;

class FlashLight
{
    public static const FRAMES_PER_SPLINE :int = 15;

    public var sprite :Sprite;
    public var frame :int;

    public function FlashLight (sprite :Sprite, p :Point)
    {
        this.sprite = sprite;
        sprite.x = p.x;
        sprite.y = p.y;
    }

    public function get t () :Number
    {
        return frame / FRAMES_PER_SPLINE;
    }

    public function get x () :Number
    {
        return _xFun != null ? _xFun.getValue(t) : 0;
    }

    public function get dX () :Number
    {
        return _xFun != null ? _xFun.getSlope(t) : 0;
    }

    public function get y () :Number
    {
        return _yFun != null ? _yFun.getValue(t) : 0;
    }

    public function get dY () :Number
    {
        return _yFun != null ? _yFun.getSlope(t) : 0;
    }

    public function newTarget (p :Point) :void
    {
        if (p != null) {
            _xFun = new HermiteFunc(sprite.x, p.x, dX, 0);
            _yFun = new HermiteFunc(sprite.y, p.y, dY, 0);
            frame = 0;

        } else {
            _xFun = _yFun = null;
        }
    }

    public function nextFrame () :void
    {
        if (_xFun != null) {
            frame ++;

            sprite.x = x;
            sprite.y = y;

            if (frame == FRAMES_PER_SPLINE) {
                // stop animating if we're done
                _xFun = _yFun = null;
            }
        }
    }

    protected var _xFun :HermiteFunc;
    protected var _yFun :HermiteFunc;
}
