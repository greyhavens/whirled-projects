package vampire.avatar {

import com.whirled.AvatarControl;
import flash.display.MovieClip;

public class VampireBodyBase extends MovieClipBody
{
    public function VampireBodyBase (ctrl :AvatarControl, media :MovieClip, width: int,
                                     height :int = -1)
    {
        super(ctrl, media, width, height);

        //Notify the game when we arrive at a movement destination
        _movementNotifier = new AvatarEndMovementNotifier(_ctrl);

        //Register custom properties
        if(_ctrl.hasControl()) {
            _ctrl.registerPropertyProvider(propertyProvider);
        }
    }

    protected function propertyProvider (key :String) :Object
    {
        switch(key) {
        case ENTITY_PROPERTY_IS_LEGAL_AVATAR:
            return true;

        //The rest of the properties are provided by the movement notifier.
        default:
            return _movementNotifier.propertyProvider(key);
        }
    }

    /**Notify the game when we arrive at a movement destination*/
    protected var _movementNotifier :AvatarEndMovementNotifier;

    /** You must wear a level avatar to play the game */
    public static const ENTITY_PROPERTY_IS_LEGAL_AVATAR :String = "IsLegalVampireAvatar";
}

}
