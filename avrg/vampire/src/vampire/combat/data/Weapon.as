package vampire.combat.data
{
    import flash.utils.Dictionary;

    import vampire.combat.client.LocationHandler;

public class Weapon
{
    public static const HAND :int = 1;
    public static const SWORD :int = 2;
    public static const CLAWS_AND_TEETH :int = 3;
    public static const GUN :int = 4;

    private static const _damage :Array = [];
    _damage[HAND] = 10;
    _damage[SWORD] = 30;
    _damage[CLAWS_AND_TEETH] = 20;
    _damage[GUN] = 40;

    private static const _range :Dictionary = new Dictionary();
    _range[GUN] = LocationHandler.RANGED;


    public static function damage (weapon :int) :Number
    {
        return _damage[weapon];
    }

    public static function range (weapon :int) :int
    {
        return _range[weapon];
    }

}
}
