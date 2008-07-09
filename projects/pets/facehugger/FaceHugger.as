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
        /*_ctrl.addEventListener(TimerEvent.TIMER, tick);
        _ctrl.addEventListener(ControlEvent.APPEARANCE_CHANGED, appearanceChanged);
        _ctrl.setTickInterval(3000);*/

        _ctrl.registerPropertyProvider(propertyProvider);
        _ctrl.setHotSpot(74, 74);
        _ctrl.setMoveSpeed(2500);

        // Temp junk
        _ctrl.addEventListener(ControlEvent.ENTITY_MOVED, handleMovement);

        /*_ctrl.addEventListener(ControlEvent.ENTITY_ENTERED,
            function (event :ControlEvent) :void {
                _ctrl.sendChatMessage("ENTITY_ENTERED: " + event.name + ", " + event.value);
                _ctrl.sendChatMessage("Type: " + _ctrl.getEntityType(event.name));
        });
        _ctrl.addEventListener(ControlEvent.ENTITY_LEFT,
            function (event :ControlEvent) :void {
                _ctrl.sendChatMessage("ENTITY_LEFT: " + event.name + ", " + event.value);
                _ctrl.sendChatMessage("Type: " + _ctrl.getEntityType(event.name));
        });*/
    }

    protected function handleMovement (event :ControlEvent) :void
    {
        var entityId :String = event.name;

        if (_victimId == null) {
            _victimId = entityId
        }

        if (entityId == _victimId) {
            var target :Array = _ctrl.getEntityProperty(EntityControl.LOCATION_PIXEL, entityId) as Array;

            target[1] += (_ctrl.getEntityProperty(EntityControl.DIMENSIONS, entityId) as Array)[1] / 2;
            target[2] -= 1;

            var speech :Array = [
                "Squeeee!!", "Hssss!!", "Skreeeee!!", "OMG WTF?!", "*squelch squelch*"
            ];

            // Pick a random line and say it
            _ctrl.sendChatMessage(speech[Math.floor(Math.random()*(speech.length))]);
            _ctrl.setPixelLocation(target[0], target[1], target[2], target[0] < _ctrl.getPixelLocation()[0] ? 270 : 90);
        }
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
        //_ctrl.setLogicalLocation(nxpos, 0, Math.random(), (nxpos < oxpos) ? 270 : 90);
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

    protected var _victimId :String = null;

    [Embed(source="facehugger.png")]
    protected static const FACEHUGGER :Class;
}
}
