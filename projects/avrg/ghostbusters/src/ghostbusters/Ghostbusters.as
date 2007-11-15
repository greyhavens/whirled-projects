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

[SWF(width="700", height="500")]
public class Ghostbusters extends Sprite
{
    public function Ghostbusters ()
    {
        root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

        _hud = new HUD();
        this.addChild(_hud);

        _control = new AVRGameControl(this);
        _control.addEventListener(
            AVRGameControlEvent.PROPERTY_CHANGED, propertyChanged);
        _control.addEventListener(
            AVRGameControlEvent.PLAYER_PROPERTY_CHANGED, playerPropertyChanged);

        var box :TextBox = new TextBox();
        this.addChild(box);
        box.showBox("La la la, it's snowing.", false);
        box.addButton("Whatever", true, function () :void {
            box.hideBox();
        });
    }

    protected function handleUnload (event :Event) :void
    {
        _hud.shutdown();
    }

    protected function propertyChanged (event: AVRGameControlEvent) :void
    {
        Log.getLog(this).debug("property changed: " + event.name + "=" + event.value);
    }

    protected function playerPropertyChanged (event: AVRGameControlEvent) :void
    {
        Log.getLog(this).debug("property changed: " + event.name + "=" + event.value);
    }

    protected var _control :AVRGameControl;

    protected var _hud :HUD;
}
}
