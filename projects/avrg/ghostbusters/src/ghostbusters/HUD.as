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

import mx.controls.Button;
import mx.events.FlexEvent;

import com.whirled.AVRGameControl;
import com.whirled.AVRGameControlEvent;

import com.threerings.flash.DisplayUtil;
import com.threerings.util.CommandEvent;
import com.threerings.util.EmbeddedSwfLoader;
import com.threerings.util.Log;

public class HUD extends Sprite
{
    public function HUD (control :AVRGameControl)
    {
        _control = control;

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

            _hole = new Sprite();
            _hole.mouseEnabled=false;
            _hole.blendMode = BlendMode.ERASE;
            with (_hole.graphics) {
                beginFill(0xFFA040);
                drawCircle(0, 0, 40);
                endFill();
            }
            _dim.addChild(_hole);

            _light = new Sprite();
            _light.mouseEnabled=false;
            _light.alpha = 0.4;
            _light.filters = [ new GlowFilter(0xFF0000, 1, 32, 32, 2) ];
            with (_light.graphics) {
                beginFill(0xFF0000);
                drawCircle(0, 0, 40);
                endFill();
            }
            _mask.addChild(_light);

            this.addEventListener(Event.ENTER_FRAME, enterFrame);
        }
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
            _hole.x += (this.mouseX - _hole.x)/2;
            _hole.y += (this.mouseY - _hole.y)/2;
            _light.x = _hole.x;
            _light.y = _hole.y;
        }
    }

    protected var _control :AVRGameControl;

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
