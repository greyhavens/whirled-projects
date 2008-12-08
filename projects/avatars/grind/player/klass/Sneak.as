package klass {

import com.whirled.AvatarControl;

public class Sneak
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

    public function getMultiplier (itemType :int) :Number
    {
        switch (itemType) {
            case Items.LIGHT: return 1.5;
            case Items.BOW: case Items.DAGGER: case Items.CLUB: return 1.5;
            case Items.SWORD: case Items.ARCANE: return 1.2;
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
