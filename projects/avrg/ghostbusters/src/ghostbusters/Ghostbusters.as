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

        _splash.addEventListener(MouseEvent.CLICK, handleClick);

        _hud = new HUD();
        _hud.visible = false;
        this.addChild(_hud);

        _control = new AVRGameControl(this);
        _control.addEventListener(
            AVRGameControlEvent.PROPERTY_CHANGED, propertyChanged);
        _control.addEventListener(
            AVRGameControlEvent.PLAYER_PROPERTY_CHANGED, playerPropertyChanged);

        this.addEventListener(Event.ADDED_TO_STAGE, handleAdded);

    }

    protected function handleAdded (evt :Event) :void
    {
        showSplash();
    }

    protected function showHelp () :void
    {
        if (_box) {
            this.removeChild(_box);
        }
        var bits :TextBits = new TextBits("HELP HELP HELP HELP");
        bits.addButton("Whatever", true, function () :void {
            showSplash();
        });
        _box = new Box(bits);
        _box.x = 100;
        _box.y = 100;
        _box.scaleX = _box.scaleY = 0.5;
        this.addChild(_box);
        _box.show();
    }

    protected function showSplash () :void
    {
        if (_box) {
            this.removeChild(_box);
        }
        _box = new Box(_splash);
        _box.x = 100;
        _box.y = 100;
        _box.scaleX = _box.scaleY = 0.5;
        this.addChild(_box);
        _box.show();
    }

    protected function handleClick (evt :MouseEvent) :void
    {
        if (evt.target.name == "close") {
            _box.hide();
            // TODO: only do this when box finishes hiding
            _control.deactivateGame();

        } else if (evt.target.name == "help") {
            showHelp();

        } else if (evt.target.name == "playnow") {
            _box.hide();
            _hud.visible = true;

        } else {
            Log.getLog(this).debug("Clicked on: " + evt.target);
            Log.getLog(this).debug("Clicked on name: " + (evt.target as DisplayObject).name);
        }
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
    protected var _box :Box;

    protected var _splash :MovieClip = MovieClip(new SPLASH());

    [Embed(source="../../rsrc/splash01.swf")]
    protected static const SPLASH :Class;
}
}
