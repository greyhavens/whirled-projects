package klass {

import com.whirled.AvatarControl;

public class Thug
    implements Klass
{
    public function getBaseSprites () :Array
    {
        return [ 83, 259 ];
    }

    public function getTraits () :Array
    {
        return [ QuestConstants.TRAIT_PLUS_COUNTER ];
    }

    public function getBonus (itemType :int) :int
    {
        return 0;
    }

    public function handleSpecial (ctrl :AvatarControl, sprite :PlayerSprite) :void
    {
        var mana :Number = sprite.getMana();
        if (mana >= 0.4) {
            ctrl.setMemory("mana", mana-0.4);
            sprite.effect({text: "TODO"});
        }
    }
}

}
