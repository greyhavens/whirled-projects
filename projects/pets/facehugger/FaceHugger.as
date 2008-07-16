package {

import flash.display.Bitmap;
import flash.display.Sprite;

import flash.events.TimerEvent;

import com.whirled.ControlEvent;
import com.whirled.PetControl;
import com.whirled.EntityControl;

import com.whirled.RemoteEntity;

import com.threerings.util.RandomUtil;

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
                if (event.name == _victimId) {
                    _victimId = null;
                }
        });
    }

    protected function handleMovement (event :ControlEvent) :void
    {
        var entityId :String = event.name;
        var type :String = _ctrl.getEntityType(entityId);

        // Don't facehug any furniture!
        if (type != EntityControl.AVATAR && type != EntityControl.PET) {
            return;
        }

        if (_victimId == null) {
            _victimId = entityId
        }

        if (entityId == _victimId) {
            var remote :RemoteEntity = new RemoteEntity(_ctrl, _victimId);
            var target :Array = remote.getPixelLocation();

            target[1] += remote.getDimensions()[1] / 2;
            target[2] -= 1;

            var speech :Array = [
                "Squeeee!!", "Hssss!!", "Skreeeee!!", "OMG WTF?!",
                "*squelch squelch*", "I luvs you, " + remote.getName() + "!"
            ];
            _ctrl.sendChatMessage(RandomUtil.pickRandom(speech) as String);

            _ctrl.setPixelLocation(target[0], target[1], target[2],
                    target[0] < _ctrl.getPixelLocation()[0] ? 270 : 90);
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

    // TODO: Put this in state/memory or something
    protected var _victimId :String = null;

    [Embed(source="facehugger.png")]
    protected static const FACEHUGGER :Class;
}
}
