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
import com.whirled.MobControl;

import com.threerings.util.EmbeddedSwfLoader;
import com.threerings.util.Log;

[SWF(width="700", height="500")]
public class Ghostbusters extends Sprite
{
    public function Ghostbusters ()
    {
        addEventListener(Event.REMOVED_FROM_STAGE, handleUnload);

        _splash.addEventListener(MouseEvent.CLICK, handleClick);

        // TODO: this is just while debugging
        _control.despawnMob("ghost");

        _control = new AVRGameControl(this);
        _control.addEventListener(
            AVRGameControlEvent.PROPERTY_CHANGED, propertyChanged);
        _control.addEventListener(
            AVRGameControlEvent.PLAYER_PROPERTY_CHANGED, playerPropertyChanged);

        _control.setMobSpriteExporter(exportMobSprite);

        _control.setHitPointTester(hitTestPoint);

        _hud = new HUD(_control);
        _hud.visible = false;
        this.addChild(_hud);

        this.addEventListener(Event.ADDED_TO_STAGE, handleAdded);
    }

    override public function hitTestPoint (
        x :Number, y :Number, shapeFlag :Boolean = false) :Boolean
    {
        if (_hud.visible) {
            var hit :Boolean = _hud.hitTestPoint(x, y, shapeFlag);
            return hit;
        }
        return _box && _box.hitTestPoint(x, y, shapeFlag);
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
            log.debug("Clicked on: " + evt.target + "/" + (evt.target as DisplayObject).name);
        }
    }

    protected function handleUnload (event :Event) :void
    {
        _hud.shutdown();
    }

    protected function propertyChanged (event: AVRGameControlEvent) :void
    {
        log.debug("property changed: " + event.name + "=" + event.value);
        if (_ghost && event.name == "gh") {
            var bits :Array = event.value as Array;
            if (bits != null) {
                var roomId :int = int(bits[0]);
                // TODO: high time to introduce a proper Model
                if (roomId == _control.getRoomId()) {
                    _ghost.updateHealth(Number(bits[1]));
                }
            }
        }
    }

    protected function playerPropertyChanged (event: AVRGameControlEvent) :void
    {
        log.debug("property changed: " + event.name + "=" + event.value);
    }

    protected function exportMobSprite (id :String, ctrl :MobControl) :DisplayObject
    {
        _ghost = new SpawnedGhost(ctrl);
        return _ghost;
    }

    protected var _control :AVRGameControl;

    protected var _hud :HUD;
    protected var _box :Box;

    protected var _ghost :SpawnedGhost;

    protected var _splash :MovieClip = MovieClip(new SPLASH());

    protected static var log :Log = Log.getLog(Ghostbusters);

    [Embed(source="../../rsrc/splash01.swf")]
    protected static const SPLASH :Class;
}
}
