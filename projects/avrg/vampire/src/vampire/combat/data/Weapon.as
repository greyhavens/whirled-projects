package vampire.combat.data
{
public class Weapon
{
    public static const HAND :int = 1;
    public static const SWORD :int = 2;
    public static const CLAWS_AND_TEETH :int = 3;

    private static const _damage :Array = [];
    _damage[HAND] = 1;
    _damage[SWORD] = 2;
    _damage[CLAWS_AND_TEETH] = 3;


    public static function damage (weapon :int) :Number
    {
        return _damage[weapon];
    }
}
}