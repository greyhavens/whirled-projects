package klass {

import com.whirled.AvatarControl;

// Not ready for prime time
public class Medic
    implements Klass
{
    public function getBaseSprites () :Array
    {
        return [ 59, 263 ];
    }

    public function getTraits () :Array
    {
        return [ QuestConstants.TRAIT_PLUS_HEALING ];
    }

    public function getBonus (itemType :int) :int
    {
        return 0;
    }

    public function handleSpecial (ctrl :AvatarControl, sprite :PlayerSprite) :Boolean
    {
        sprite.effect({text: "TODO"});
        return false;
    }
}

}
