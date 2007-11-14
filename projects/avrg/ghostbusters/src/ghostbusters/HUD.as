//
// $Id$

package ghostbusters {

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.MouseEvent;

import flash.utils.ByteArray;

import mx.controls.Button;
import mx.events.FlexEvent;

import com.whirled.AVRGameControl;
import com.whirled.AVRGameControlEvent;

import com.threerings.util.EmbeddedSwfLoader;
import com.threerings.util.Log;

[SWF(width="450", height="100")]
public class HUD extends Sprite
{
    public function HUD ()
    {
        root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

        var loader :EmbeddedSwfLoader = new EmbeddedSwfLoader();
        loader.addEventListener(Event.COMPLETE, handleHUDLoaded);
        loader.load(ByteArray(new HUD_VISUAL()));

        _control = new AVRGameControl(this);
        _control.addEventListener(
            AVRGameControlEvent.PROPERTY_CHANGED, propertyChanged);
        _control.addEventListener(
            AVRGameControlEvent.PLAYER_PROPERTY_CHANGED, playerPropertyChanged);

//        _mask = new Sprite();
//        with(_mask.graphics) {
//            beginFill(0x202020);
//            drawCircle(0, 0, 20);
//            endFill();
//        }
//        this.addChild(_mask);

//        this.addEventListener(Event.ENTER_FRAME, enterFrame);
    }

    protected static const LANTERN :String = "instance61";
    protected static const HELP :String = "instance64";
    protected static const LOOT :String = "instance65";

    protected function handleHUDLoaded (evt :Event) :void
    {
        var hud :MovieClip = MovieClip(EmbeddedSwfLoader(evt.target).getContent());
        hud.x = 10; // damn scrollbar
        hud.y = 0;
        this.addChild(hud);

        for (var ii :int = 0; ii < hud.numChildren; ii ++) {
            var child :DisplayObject = hud.getChildAt(ii);
            Log.getLog(this).debug("Child #" + ii + ": " + child + " (" + child.name + ")");
            if (child.name == LANTERN || child.name == HELP || child.name == LOOT) {
                child.addEventListener(MouseEvent.CLICK, handleButton);
            }
        }
    }

    protected function handleButton (evt :Event) :void
    {
        Log.getLog(this).debug("Whee, button clicked: " + evt);
    }

    protected function handleUnload (event :Event) :void
    {
        this.removeEventListener(Event.ENTER_FRAME, enterFrame);
    }

    protected function enterFrame (event :Event) :void
    {
        _mask.x = this.mouseX;
        _mask.y = this.mouseY;
    }

    protected function propertyChanged (event: AVRGameControlEvent) :void
    {
        trace("property changed: " + event.name + "=" + event.value);
    }

    protected function playerPropertyChanged (event: AVRGameControlEvent) :void
    {
        trace("property changed: " + event.name + "=" + event.value);
    }

    protected var _control :AVRGameControl;

    protected var _mask :Sprite;

    [Embed(source="../../rsrc/HUD_visual.swf", mimeType="application/octet-stream")]
    protected static const HUD_VISUAL :Class;
}
}
