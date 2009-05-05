package vampire.avatar {

import com.whirled.AvatarControl;

import flash.display.MovieClip;

public class VampireBodyBase extends MovieClipBody
{
    public function VampireBodyBase (ctrl :AvatarControl, media :MovieClip, width: int,
                                     height :int = -1)
    {
        super(ctrl, media, width, height);

        // Notify the game when we arrive at a movement destination
        _movementNotifier = new AvatarEndMovementNotifier(_ctrl);

        // Register custom properties
        if(_ctrl.hasControl()) {
            _ctrl.registerPropertyProvider(propertyProvider);
        }
    }

    protected function propertyProvider (key :String) :Object
    {
        switch(key) {
        // You must wear a legal avatar to play the game
        case AvatarConstants.ENTITY_PROPERTY_IS_LEGAL_AVATAR:
            return true;

        case AvatarConstants.ENTITY_PROPERTY_SET_PLAYER_LEVEL:
            return setPlayerLevel as Object;

        // The rest of the properties are provided by the movement notifier.
        default:
            return _movementNotifier.propertyProvider(key);
        }
    }

    protected function setPlayerLevel (newLevel :int) :void
    {
        // Subclasses that care about player level for configuration purposes should
        // probably store this in an avatar memory so that the player doesn't need
        // to be in the game to access level-locked configuration parameters
        _playerLevel = newLevel;
    }

    protected var _playerLevel :int;
    protected var _movementNotifier :AvatarEndMovementNotifier;
}

}
