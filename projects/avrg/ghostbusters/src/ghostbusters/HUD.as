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
        if (_lanternia.visible) {
            removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
        }
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

        DisplayUtil.findInHierarchy(_hud, LANTERN).addEventListener(MouseEvent.CLICK, lanternClick);
        DisplayUtil.findInHierarchy(_hud, HELP).addEventListener(MouseEvent.CLICK, helpClick);
        DisplayUtil.findInHierarchy(_hud, LOOT).addEventListener(MouseEvent.CLICK, lootClick);

        _lanternia = new Sprite();
        _lanternia.mouseChildren = false;
        _lanternia.visible = false;
        addChild(_lanternia);

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

        // add the HUD last so it overrides all the other complicated nonsense
        addChild(_hud);
    }

    protected function lanternClick (evt :Event) :void
    {
        if (_lanternia.visible) {
            removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
            _lanternia.visible = false;

        } else {
            addEventListener(Event.ENTER_FRAME, handleEnterFrame);
            _lanternia.visible = true;
        }
    }

    protected function propertyChanged (event: AVRGameControlEvent) :void
    {
        if (event.name == "fl") {
            var bits :Array = event.value as Array;
            if (bits != null) {
                var playerId :int = int(bits[0]);
                if ((DEBUG || playerId != _myId) && _control.isPlayerHere(playerId)) {
                    // lantern update from a local player
                    if (bits.length == 1) {
                        // someone turned theirs off
                        updateLantern(playerId);
                    } else {
                        // someone turned theirs on or moved it
                        updateLantern(playerId, new Point(bits[1], bits[2]));
                    }
                }
            }
        }
    }

    protected function updateLantern (playerId :int, p :Point = null) :void
    {
        var lantern :Lantern = _lanterns[playerId];
        if (p == null) {
            // removal
            if (lantern) {
                _dimFront.removeChild(lantern.hole);
                _lightLayer.removeChild(lantern.light);
                _maskLayer.removeChild(lantern.mask);
                delete _lanterns[playerId];
            }
            return;
        }

        // transform the point from room to overlay coordinates
        p = _control.roomToStage(p);
        p = _lanternia.globalToLocal(p);

        if (!lantern) {
            // a new lantern just appears, no splines involved
            lantern = new Lantern(p);
            _lanterns[playerId] = lantern;

            _maskLayer.addChild(lantern.mask);
            _lightLayer.addChild(lantern.light);
            _dimFront.addChild(lantern.hole);
            return;
        }

        // else just set our aim for p
        lantern.newTarget(p);
    }

    protected function ghostVanished (id :String) :void
    {
        Log.getLog(HUD).debug("Ghost vanishing [id=" + id + "]");
    }

    protected function helpClick (evt :Event) :void
    {
        Log.getLog(HUD).debug("Whee, button clicked: " + evt);
    }

    protected function lootClick (evt :Event) :void
    {
        Log.getLog(HUD).debug("Whee, button clicked: " + evt);
    }

    protected function handleEnterFrame (evt :Event) :void
    {
        animateLanterns();

        animateGhost();

        // if so transform the mouse position to room coordinates
        var p :Point = new Point(Math.max(0, Math.min(_width, _lanternia.mouseX)),
                                 Math.max(0, Math.min(_height, _lanternia.mouseY)));
        p = _lanternia.localToGlobal(p);
        p = _control.stageToRoom(p);

        // bow to reality: nobody wants to watch roundtrip lag in action
        if (!DEBUG) {
            updateLantern(_myId, p);
        }

        // see if it's time to send an update on our own position
        _ticker ++;
        if (_ticker < FRAMES_PER_UPDATE) {
            return;
        }
        _ticker = 0;

        // off it goes!
        _control.state.setProperty("fl", [ _myId, p.x, p.y ], false);
    }

    protected function animateLanterns () :void
    {
        for each (var lantern :Lantern in _lanterns) {
            lantern.nextFrame();
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

    protected var _lanterns :Dictionary = new Dictionary();

    protected var _hud :MovieClip;

    protected var _ticker :int;

    protected var _lanternia :Sprite;
    protected var _dimBack :Sprite;
    protected var _dimFront :Sprite;

    protected var _lightLayer :Sprite;
    protected var _maskLayer :Sprite;

    protected static const FRAMES_PER_UPDATE :int = 6;

    protected static const LANTERN :String = "lanternbutton";
    protected static const HELP :String = "helpbutton";
    protected static const LOOT :String = "lootbutton";

    [Embed(source="../../rsrc/HUD_visual.swf", mimeType="application/octet-stream")]
    protected static const HUD_VISUAL :Class;

    protected static const DEBUG :Boolean = false;
}
}

