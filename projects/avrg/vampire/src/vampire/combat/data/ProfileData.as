package vampire.combat.data
{
import flash.utils.Dictionary;

public class ProfileData
{
    private static const _profiles :Dictionary = new Dictionary();

    public static function get (type :int) :Object
    {
        return _profiles[type];
    }

    public static const BASIC_VAMPIRE1 :int = 1;
    _profiles[BASIC_VAMPIRE1] = {
                                    strength      : 20,
                                    speed         : 20,
                                    stamina       : 50,
                                    mind          : 20,
                                    maxHealth     : 30,
                                    weaponDefault :Weapon.HAND
                               }



    public static const BASIC_VAMPIRE2 :int = 2;
    _profiles[BASIC_VAMPIRE2] = {
                                    strength      : 20,
                                    speed         : 40,
                                    stamina       : 50,
                                    mind          : 40,
                                    maxHealth     : 30,
                                    weaponDefault :Weapon.CLAWS_AND_TEETH
                               }
}
}