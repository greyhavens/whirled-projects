//
// $Id$

package ghostbusters {

import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
import flash.filters.GlowFilter;

import flash.events.Event;
import flash.events.MouseEvent;

import flash.utils.ByteArray;
import flash.utils.Dictionary;

import mx.controls.Button;
import mx.events.FlexEvent;

import com.whirled.AVRGameControl;
import com.whirled.AVRGameControlEvent;

import com.threerings.flash.DisplayUtil;

import com.threerings.util.CommandEvent;
import com.threerings.util.EmbeddedSwfLoader;
import com.threerings.util.Log;
import com.threerings.util.StringUtil;

public class HUD extends Sprite
{
    public function HUD (control :AVRGameControl)
    {
        _control = control;

        _control.addEventListener(AVRGameControlEvent.PROPERTY_CHANGED, propertyChanged);
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
    }

    protected function lanternClick (evt :Event) :void
    {
        if (_mask) {
            this.removeEventListener(Event.ENTER_FRAME, enterFrame);
            this.removeChild(_mask);
            _mask = null;

        } else {
            _mask = new Sprite();

            _mask.mouseEnabled = false;
            _mask.mouseChildren = false;
            _mask.blendMode = BlendMode.LAYER;
            this.addChild(_mask);

            _dim = new Sprite();
            _dim.mouseEnabled=false;
            with (_dim.graphics) {
                beginFill(0x000000);
                drawRect(0, 0, 2000, 1000);
                endFill();
            }
            _dim.alpha = 0.7;
            _mask.addChild(_dim);

            this.addEventListener(Event.ENTER_FRAME, enterFrame);
        }
    }

    protected function propertyChanged (event: AVRGameControlEvent) :void
    {
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
                        updateFlashLight(playerId, Number(bits[1]), Number(bits[2]));
                    }
                }
            }
        }
    }

    protected function updateFlashLight (playerId :int, x :Number = -1, y :Number = -1) :void
    {
        var light :Sprite = _flashLights[playerId];
        if (x < 0) {
            // removal
            if (light) {
                _dim.removeChild(light);
                delete _flashLights[playerId];
            }
            return;
        }
        if (!light) {
            light = new Sprite();
            _dim.addChild(light);
            _flashLights[playerId] = light;

            var hole :Sprite = new Sprite();
            hole.mouseEnabled=false;
            hole.blendMode = BlendMode.ERASE;
            with (hole.graphics) {
                beginFill(0xFFA040);
                drawCircle(0, 0, 40);
                endFill();
            }
            light.addChild(hole);

            var photons :Sprite = new Sprite();
            photons.mouseEnabled=false;
            photons.alpha = 0.2;
            photons.filters = [ new GlowFilter(0xFF0000, 1, 32, 32, 2) ];
            with (photons.graphics) {
                beginFill(0xFF0000);
                drawCircle(0, 0, 40);
                endFill();
            }
            light.addChild(photons);
        }
        // TODO: translate coordinates
        light.x = x;
        light.y = y;
    }

    protected function ghostVanished (id :String) :void
    {
        Log.getLog(this).debug("Ghost vanishing [id=" + id + "]");
    }

    protected function helpClick (evt :Event) :void
    {
        _control.spawnMob("ghost");

        Log.getLog(this).debug("Whee, button clicked: " + evt);
    }

    protected function lootClick (evt :Event) :void
    {
        Log.getLog(this).debug("Whee, button clicked: " + evt);
    }

    protected function enterFrame (evt :Event) :void
    {
        if (_mask) {
            // TODO: translate coordinates
            // TODO; don't send this every damn frame
            _control.state.setProperty("fl", [ _myId, this.mouseX, this.mouseY ], false);
//            _hole.x += (this.mouseX - _hole.x)/2;
//            _hole.y += (this.mouseY - _hole.y)/2;
//            _light.x = _hole.x;
//            _light.y = _hole.y;
        }
    }

    protected var _control :AVRGameControl;
    protected var _myId :int;

    protected var _flashLights :Dictionary = new Dictionary();

    protected var _hud :MovieClip;

    protected var _mask :Sprite;
    protected var _dim :Sprite;
    protected var _hole :Sprite;
    protected var _light :Sprite;

    protected static const LANTERN :String = "lanternbutton";
    protected static const HELP :String = "helpbutton";
    protected static const LOOT :String = "lootbutton";

    [Embed(source="../../rsrc/HUD_visual.swf", mimeType="application/octet-stream")]
    protected static const HUD_VISUAL :Class;
}
}
