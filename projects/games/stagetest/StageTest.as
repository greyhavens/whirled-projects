//
// $Id$

package {

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.events.KeyboardEvent;
import flash.text.TextField;

import com.threerings.util.ClassUtil;
import com.threerings.util.StringUtil;
import com.threerings.util.Util;

import com.threerings.display.DisplayUtil;

import com.threerings.flex.CommandButton;

import com.whirled.game.*;

public class StageTest extends Sprite
{
    public function StageTest ()
    {
        _ctrl = new GameControl(this);

        if (this.stage != null) {
            addedToStage();

        } else {
            addEventListener(Event.ADDED_TO_STAGE, addedToStage);
        }

        this.graphics.beginFill(0x3366FF);
        this.graphics.drawRect(0, 0, 700, 500);
        this.graphics.endFill();
    }

    protected function addedToStage (... ignored) :void
    {
        removeEventListener(Event.ADDED_TO_STAGE, addedToStage);

        this.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKey);
        trace("================= I added a listener to the stage!");
    }

    protected function handleKey (event :KeyboardEvent) :void
    {
        trace("handleKey: " + event);

        if (event.charCode == 113) {
            pokeAndBreak();

        } else {
            fakeKeypress(event);
        }
    }

    // it appears that this *doesn't* work. We can't fake a keypress into a text field.
    protected function fakeKeypress (event :KeyboardEvent) :void
    {
        if (_nowFaking) {
            return; // prevent stack overflow
        }
        _nowFaking = true;
        IEventDispatcher(event.target).dispatchEvent(
            new KeyboardEvent(event.type, false, false,
                event.charCode, event.keyCode, event.keyLocation,
                event.altKey, event.shiftKey));
        _nowFaking = false;
    }
    protected var _nowFaking :Boolean;

    protected function pokeAndBreak () :void
    {
        try {
            var d :DisplayObject = this;
            while (d.parent != null) {
                d = d.parent;

                trace(": " + StringUtil.simpleToString(d));
            }
            trace("== top");
        } catch (e :Error) {
            trace("Got error climbing: " + e);
        }


        trace(DisplayUtil.dumpHierarchy(this.stage));

        trace("Now trying to push buttons!");
        DisplayUtil.applyToHierarchy(this.stage, pushButtons);

        trace("Now trying to fill fields");
        DisplayUtil.applyToHierarchy(this.stage, alterText);
    }

    protected function pushButtons (disp :DisplayObject) :void
    {
        trace(StringUtil.simpleToString(disp));
        if (ClassUtil.getClassName(disp) == "com.threerings.flex.CommandButton") {
            trace("Found cmdBtn: " + disp);
            Object(disp)["activate"]();
        }
    }

    protected function alterText (disp :DisplayObject) :void
    {
        if (disp is TextField) {
            TextField(disp).text = "I hax there4 I iz";
        }
    }

    protected var _ctrl :GameControl;
}
}
