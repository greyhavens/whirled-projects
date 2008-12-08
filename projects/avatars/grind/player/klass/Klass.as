package klass {

import com.whirled.AvatarControl;

public interface Klass
{
    /** A list of sprites to use as the base layers of the paper doll. */
    function getBaseSprites () :Array;

    function getTraits () :Array;

    function getMultiplier (itemType :int) :Number;

    function handleSpecial (ctrl :AvatarControl, sprite :PlayerSprite) :Boolean;
}

}
