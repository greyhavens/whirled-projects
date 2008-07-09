package {

import flash.display.Bitmap;
import flash.display.Sprite;

import flash.events.TimerEvent;

import com.whirled.ControlEvent;
import com.whirled.PetControl;
import com.whirled.EntityControl;

/**
 * An extremely simple pet that moves randomly around the room.
 */
[SWF(width="150", height="209")]
public class FaceHugger extends Sprite
{
    public function FaceHugger ()
    {
        addChild(_image = Bitmap(new FACEHUGGER()));

        _ctrl = new PetControl(this);
        _ctrl.addEventListener(TimerEvent.TIMER, tick);
        _ctrl.addEventListener(ControlEvent.APPEARANCE_CHANGED, appearanceChanged);
        _ctrl.setTickInterval(3000);

        _ctrl.registerPropertyProvider(propertyProvider);

        // Temp junk
        _ctrl.addEventListener(ControlEvent.ENTITY_MOVED,
            function (event :ControlEvent) :void {
                _ctrl.sendChatMessage("ENTITY_MOVED: " + event.name + ", " + event.value);
                _ctrl.sendChatMessage("Type: " + _ctrl.getEntityType(event.name));
                _ctrl.sendChatMessage("Logical xyz: " +_ctrl.getEntityProperty("std:location_logical", event.name));
                _ctrl.sendChatMessage("Pixel xyz: " +_ctrl.getEntityProperty("std:location_pixel", event.name));
                _ctrl.sendChatMessage("Dimensions: " +_ctrl.getEntityProperty("std:dimensions", event.name));
                _ctrl.sendChatMessage("Hotspot: " + _ctrl.getEntityProperty("std:hotspot", event.name));
        });
        _ctrl.addEventListener(ControlEvent.ENTITY_ENTERED,
            function (event :ControlEvent) :void {
                _ctrl.sendChatMessage("ENTITY_ENTERED: " + event.name + ", " + event.value);
                _ctrl.sendChatMessage("Type: " + _ctrl.getEntityType(event.name));
        });
        _ctrl.addEventListener(ControlEvent.ENTITY_LEFT,
            function (event :ControlEvent) :void {
                _ctrl.sendChatMessage("ENTITY_LEFT: " + event.name + ", " + event.value);
                _ctrl.sendChatMessage("Type: " + _ctrl.getEntityType(event.name));
        });
    }

    protected function propertyProvider (key :String) :Object
    {
        _ctrl.sendChatMessage("Got request for " + key);
        return 666;
    }

    protected function tick (event :TimerEvent) :void
    {
        // Debug
        _ctrl.sendChatMessage("Property: " +String(_ctrl.getEntityProperty("test")));
        _ctrl.sendChatMessage("All: " + _ctrl.getEntityIds(null).join());
        _ctrl.sendChatMessage("Avatars: " +_ctrl.getEntityIds(EntityControl.AVATAR).join());
        _ctrl.sendChatMessage("Pets: " +_ctrl.getEntityIds(EntityControl.PET).join());
        _ctrl.sendChatMessage("Furni: " +_ctrl.getEntityIds(EntityControl.FURNI).join());

        var oxpos :Number = _ctrl.getLogicalLocation()[0];
        var nxpos :Number = Math.random();
        _ctrl.setLogicalLocation(nxpos, 0, Math.random(), (nxpos < oxpos) ? 270 : 90);
    }

    protected function appearanceChanged (event :ControlEvent) :void
    {
        var orient :Number = _ctrl.getOrientation();
        if (orient < 180) {
            _image.x = _image.width;
            _image.scaleX = -1;

        } else {
            _image.x = 0;
            _image.scaleX = 1;
        }
    }

    protected var _ctrl :PetControl;
    protected var _image :Bitmap;

    [Embed(source="facehugger.png")]
    protected static const FACEHUGGER :Class;
}
}
