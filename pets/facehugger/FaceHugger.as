package {

import flash.display.Bitmap;
import flash.display.Sprite;

import flash.events.TimerEvent;

import com.whirled.ControlEvent;
import com.whirled.PetControl;
import com.whirled.EntityControl;

import com.threerings.util.RandomUtil;
import com.whirled.contrib.RemoteEntity;

/**
 * A face full of alien wing-wong.
 */
[SWF(width="150", height="209")]
public class FaceHugger extends Sprite
{
    public function FaceHugger ()
    {
        addChild(_image = Bitmap(new FACEHUGGER()));

        _ctrl = new PetControl(this);

        _ctrl.setHotSpot(74, 74);
        _ctrl.setMoveSpeed(2500);

        _ctrl.addEventListener(ControlEvent.ENTITY_MOVED, handleMovement);
        _ctrl.addEventListener(ControlEvent.ENTITY_ENTERED, handleMovement);
        _ctrl.addEventListener(ControlEvent.APPEARANCE_CHANGED, appearanceChanged);

        _ctrl.addEventListener(ControlEvent.ENTITY_LEFT,
            function (event :ControlEvent) :void {
                // If the victim leaves, start looking for a new target
                if (_victimId == event.name) {
                    _victimId = null;
                }
        });
    }

    protected function handleMovement (event :ControlEvent) :void
    {
        var entityId :String = event.name;
        var remote :RemoteEntity = new RemoteEntity(_ctrl, entityId);

        // Don't facehug ourselves!
        if (entityId == _ctrl.getMyEntityId()) {
            return;
        }

        if (_victimId == null) {
            _victimId = entityId;
        }

        if (entityId == _victimId) {

            var logical :Array = event.value as Array;
            if (logical == null) {
                return; // Face huggers only care when its victim STARTS moving
            }

            var pixel :Array = _ctrl.getRoomBounds();
            for (var i :int = 0; i < logical.length; ++i) {
                pixel[i] *= logical[i];
            }

            pixel[1] += remote.getDimensions()[1] / 2;
            pixel[2] -= 10;

            // Match their speed and heading
            _ctrl.setMoveSpeed(remote.getMoveSpeed());
            _ctrl.setPixelLocation(pixel[0], pixel[1], pixel[2],
                    pixel[0] < _ctrl.getPixelLocation()[0] ? 270 : 90);

            // Say something
            var speech :Array = [
                "Squeeee!!", "Hssss!!", "Skreeeee!!", "OMG WTF?!",
                "*squelch squelch*", "I luvs you, " + remote.getName() + "!"
            ];
            _ctrl.sendChat(RandomUtil.pickRandom(speech) as String);

        }
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

    /** The entityId of the victim. */
    protected var _victimId :String = null;

    [Embed(source="facehugger.png")]
    protected static const FACEHUGGER :Class;
}
}
