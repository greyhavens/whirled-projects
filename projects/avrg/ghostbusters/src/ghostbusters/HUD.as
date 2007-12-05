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
        _hud = MovieClip(EmbeddedSwfLoader(evt.target).getContent());
        _hud.x = 10; // damn scrollbar
        _hud.y = 0;
        this.addChild(_hud);

        DisplayUtil.findInHierarchy(_hud, LANTERN).addEventListener(MouseEvent.CLICK, lanternClick);
        DisplayUtil.findInHierarchy(_hud, HELP).addEventListener(MouseEvent.CLICK, helpClick);
        DisplayUtil.findInHierarchy(_hud, LOOT).addEventListener(MouseEvent.CLICK, lootClick);

        _lanternia = new Sprite();
        _lanternia.visible = false;
        this.addChild(_lanternia);

        _dimBack = new Sprite();
        _dimBack.blendMode = BlendMode.LAYER;
        _lanternia.addChild(_dimBack);

        _dimFront = new Sprite();
        with (_dimFront.graphics) {
            beginFill(0x000000);
            drawRect(0, 0, 2000, 1000);
            endFill();
        }
        _dimFront.alpha = 0.7;
        _dimBack.addChild(_dimFront);

        _lightLayer = new Sprite();
        _lanternia.addChild(_lightLayer);

        _maskLayer = new Sprite();
        _lanternia.addChild(_maskLayer);

        var ghost :Ghost = new Ghost();
        _lanternia.addChild(ghost);
        ghost.mask = _maskLayer;
        ghost.x = 300;
        ghost.y = 0;
    }

    protected function lanternClick (evt :Event) :void
    {
        if (_lanternia.visible) {
            this.removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
            _lanternia.visible = false;

        } else {
            this.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
            _lanternia.visible = true;
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
                _dimFront.removeChild(light.hole);
                _lightLayer.removeChild(light.light);
                _maskLayer.removeChild(light.mask);
                delete _flashLights[playerId];
            }
            return;
        }

        // transform the point from room to overlay coordinates
        p = _control.roomToStage(p);
        p = _lanternia.globalToLocal(p);

        if (!light) {
            // a new flashlight just appears, no splines involved
            light = new FlashLight(p);
            _flashLights[playerId] = light;

            _maskLayer.addChild(light.mask);
            _lightLayer.addChild(light.light);
            _dimFront.addChild(light.hole);
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

        animateGhost();

        // see if it's time to send an update on our own position
        _ticker ++;
        if (_ticker < FRAMES_PER_UPDATE) {
            return;
        }
        _ticker = 0;

        // if so transform the mouse position to room coordinates
        var p :Point = new Point(Math.max(0, Math.min(_width, this.mouseX)),
                                 Math.max(0, Math.min(_height, this.mouseY)));
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

    protected function animateGhost () :void
    {
    }

    protected var _control :AVRGameControl;
    protected var _myId :int;

    // TODO: temporary hard-coded
    protected var _width :int = 700;
    protected var _height :int = 500;

    protected var _flashLights :Dictionary = new Dictionary();

    protected var _hud :MovieClip;

    protected var _ticker :int;

    protected var _lanternia :Sprite;
    protected var _dimBack :Sprite;
    protected var _dimFront :Sprite;

    protected var _lightLayer :Sprite;
    protected var _maskLayer :Sprite;

    protected static const FRAMES_PER_UPDATE :int = 4;

    protected static const LANTERN :String = "lanternbutton";
    protected static const HELP :String = "helpbutton";
    protected static const LOOT :String = "lootbutton";

    [Embed(source="../../rsrc/HUD_visual.swf", mimeType="application/octet-stream")]
    protected static const HUD_VISUAL :Class;
}
}

