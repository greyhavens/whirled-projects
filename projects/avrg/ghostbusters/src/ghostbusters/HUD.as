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

public class HUD extends Sprite
{
    public function HUD ()
    {
        var loader :EmbeddedSwfLoader = new EmbeddedSwfLoader();
        loader.addEventListener(Event.COMPLETE, handleHUDLoaded);
        loader.load(ByteArray(new HUD_VISUAL()));

//        _mask = new Sprite();
//        with(_mask.graphics) {
//            beginFill(0x202020);
//            drawCircle(0, 0, 20);
//            endFill();
//        }
//        this.addChild(_mask);

//        this.addEventListener(Event.ENTER_FRAME, enterFrame);
    }

    public function shutdown () :void
    {
    }

    protected function handleHUDLoaded (evt :Event) :void
    {
        var hud :MovieClip = MovieClip(EmbeddedSwfLoader(evt.target).getContent());
        hud.x = 10; // damn scrollbar
        hud.y = 0;
        this.addChild(hud);

        for (var ii :int = 0; ii < hud.numChildren; ii ++) {
            var child :DisplayObject = hud.getChildAt(ii);
//            Log.getLog(this).debug("HUD Child #" + ii + ": " + child + " (" + child.name + ")");
            if (child.name == LANTERN || child.name == HELP || child.name == LOOT) {
                Log.getLog(this).debug("HUD Child #" + ii + ": " + child + " (" + child.name + ")");
                child.addEventListener(MouseEvent.CLICK, handleButton);
            }
        }
    }

    protected function handleButton (evt :Event) :void
    {
        Log.getLog(this).debug("Whee, button clicked: " + evt);
    }

    protected function enterFrame (event :Event) :void
    {
        _mask.x = this.mouseX;
        _mask.y = this.mouseY;
    }

    protected var _mask :Sprite;

    protected static const LANTERN :String = "lanternbutton";
    protected static const HELP :String = "helpbutton";
    protected static const LOOT :String = "lootbutton";

    [Embed(source="../../rsrc/HUD_visual.swf", mimeType="application/octet-stream")]
    protected static const HUD_VISUAL :Class;
}
}
