package klass {

import com.whirled.AvatarControl;

public class Mage
    implements Klass
{
    public function getBaseSprites () :Array
    {
        return [ 58 ];
    }

    public function getHairSprites () :Array
    {
        return [ 275 ];
    }

    public function getTraits () :Array
    {
        return [ QuestConstants.TRAIT_PLUS_COUNTER ];
    }

    public function getMultiplier (itemType :int) :Number
    {
        switch (itemType) {
            case Items.ARCANE: return 1.5;
            case Items.MAGIC: case Items.DAGGER: return 1.5;
            case Items.SWORD: case Items.SPEAR: return 1.2;
            case Items.HEAVY: return 0.8;
        }
        return 1;
    }

    public function handleSpecial (ctrl :AvatarControl, sprite :PlayerSprite) :Boolean
    {
        var mana :Number = sprite.getMana();
        if (mana >= 0.4) {
            ctrl.setMemory("mana", mana-0.4);
            sprite.effect({text: "TODO"});
            return true;
        } else {
            return false;
        }
    }
}

}
