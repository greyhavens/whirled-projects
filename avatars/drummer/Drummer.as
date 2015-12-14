package {

import flash.display.DisplayObject;
import flash.display.Sprite;

import flash.geom.Point;

import com.everydayflash.util.Rotator;
import caurina.transitions.Tweener;

import com.whirled.EntityControl;
import com.whirled.AvatarControl;
import com.whirled.ControlEvent;

[SWF(width="600", height="450")]
public class Drummer extends Sprite
{
    public static const SPRITE_WIDTH :int = 600;
    public static const SPRITE_HEIGHT :int = 450;

    public static const DRUMMER_WIDTH :int = 174;
    public static const DRUMMER_HEIGHT :int = 155;

    public function Drummer ()
    {
        _image = new IMAGE() as DisplayObject;
        addChild(_image);
        _image.x = SPRITE_WIDTH/2 - DRUMMER_WIDTH/2;
        _image.y = SPRITE_HEIGHT - DRUMMER_HEIGHT;

        _rotator = new Rotator(_image, new Point(_image.x+DRUMMER_WIDTH/2, _image.y));

        _ctrl = new AvatarControl(this);

        _ctrl.addEventListener(ControlEvent.ACTION_TRIGGERED, handleAction);
        _ctrl.registerActions("Energize");
        _ctrl.setHotSpot(SPRITE_WIDTH/2, SPRITE_HEIGHT - DRUMMER_HEIGHT, 0);

        _ctrl.setMoveSpeed(200);
    }

    protected function handleAction (... etc)
    {
        _ctrl.addEventListener(ControlEvent.ENTITY_MOVED, handleCalibration);
        _ctrl.setLogicalLocation(1, 1, 0, 0);
    }

    protected function handleCalibration (event :ControlEvent) :void
    {
        if (event.name == _ctrl.getMyEntityId()) {
            var size :Array = _ctrl.getEntityProperty(EntityControl.PROP_LOCATION_PIXEL) as Array;

            _ctrl.removeEventListener(ControlEvent.ENTITY_MOVED, handleCalibration);
            _ctrl.addEventListener(ControlEvent.ENTITY_MOVED, handleMovement);

            var shim :Number = Math.min(DRUMMER_WIDTH, DRUMMER_HEIGHT);
            _corners = [
                new Point(shim, shim),
                new Point(size[0]-shim, shim),
                new Point(size[0]-shim, size[1] - shim),
                new Point(shim, size[1] - shim)
            ];

            moveToCorner(0);
        }
    }
    protected function moveToCorner (c :int) :void
    {
        _current = c;
        _ctrl.setPixelLocation(_corners[c].x, _corners[c].y, 0, 0);
    }

    protected function handleMovement (event :ControlEvent)
    {
        if (event.name == _ctrl.getMyEntityId()) {
            Tweener.addTween(_rotator, { rotation:-90*_current, time:0.5, transition:"linear"});
            moveToCorner((_current+1)%_corners.length);
        }
    }

    protected var _corners :Array;
    protected var _current :int;

    protected var _ctrl :AvatarControl;

    protected var _image :DisplayObject;
    protected var _rotator :Rotator;

    [Embed(source="drummer.png")]
    protected static const IMAGE :Class;
}
}
