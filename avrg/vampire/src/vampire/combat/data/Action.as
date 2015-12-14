package vampire.combat.data
{
import com.threerings.util.Util;

import flash.utils.Dictionary;

public class Action
{


    public static const ATTACK_BASIC :int = 1;
    public static const REST :int = 2;
    public static const BLOCK :int = 3;
    public static const DODGE :int = 4;
//    public static const ATTACK_2 :int = 5;
    public static const MOVE_CLOSE :int = 6;
    public static const MOVE_FAR :int = 7;

    //Those actions with a warmup step(s)
    protected static const _warmUp :Dictionary = new Dictionary();
//    _warmUp[ATTACK_2] = 2;

    protected static const _actions :Dictionary = new Dictionary();
    _actions[ATTACK_BASIC] = "Attack";
    _actions[REST] = "Rest";
    _actions[BLOCK] = "Block";
    _actions[DODGE] = "Dodge";
//    _actions[ATTACK_2] = "Attack2";
    _actions[MOVE_CLOSE] = "Move Close";
    _actions[MOVE_FAR] = "Move Away";

    protected static const _energyCost :Dictionary = new Dictionary();
    _energyCost[ATTACK_BASIC] = 20;
    _energyCost[REST] = -20;
    _energyCost[BLOCK] = 5;
    _energyCost[DODGE] = 5;
//    _energyCost[ATTACK_2] = _warmUp[ATTACK_2] * -_energyCost[REST] + 30;

    public static function name (actionKey :int) :String
    {
        return _actions[actionKey] as String;
    }
    public static function warmUp (actionKey :int) :int
    {
        return _warmUp[actionKey] as int;
    }
    public static function energyCost (actionKey :int) :int
    {
        return _energyCost[actionKey] as int;
    }

    public static function get ALL_ACTIONS () :Array
    {
        return Util.keys(_actions);
    }

    public static const ATTACK_AND__DEFENCE :Array = [
                                                        ATTACK_BASIC,
                                                        BLOCK,
                                                        DODGE,
//                                                        ATTACK_2,
                                                        ATTACK_BASIC,
                                                        ATTACK_BASIC,
                                                     ]

}
}
