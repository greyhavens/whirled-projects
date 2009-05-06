package vampire.combat.data
{
import flash.utils.Dictionary;

public class ProfileData
{
    private static const _profiles :Dictionary = new Dictionary();

    public static function get (id :int) :Object
    {
        return _profiles[id];
    }

    public static const BASIC_VAMPIRE :int = 1;
    _profiles[BASIC_VAMPIRE] = {
                                    strength      : 0.5,
                                    speed         : 0.5,
                                    stamina       : 0.5,
                                    mind          : 0.5,
                                    maxHealth     : 0.5,
                                    weaponDefault :[Weapon.HAND, Weapon.HAND]
                               }
}
}