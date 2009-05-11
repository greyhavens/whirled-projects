package com.whirled.contrib
{
import com.whirled.contrib.simplegame.Updatable;

import flash.utils.Dictionary;


/**
 * Detects in-memory cheats.  Disclaimer: this is not fool-proof!  Encrypt/Obfuscate your game
 * variables as well!
 *
 * Three identical copies of values are stored.
 * If the three copies are not identical on the update loop, then in-memory
 * hacking is almost certain occuring, and the callback is invoked.
 */
public class CheatDetector
{
    public function CheatDetector(cheatDetectedCallback :Function)
    {
        _cheatCallBack = cheatDetectedCallback;
    }

    public function get (key :String) :int
    {
        var mi :MultiInt = _values[key] as MultiInt;

        if (mi != null) {
            return mi.value1;
        }
        return 0;
    }

    public function set (key :String, value :int) :void
    {
        var mi :MultiInt = _values[key] as MultiInt;

        if (mi == null) {
            _values[key] = new MultiInt(value);

        }
        else {
            mi.set(value);
        }
    }

    public function toString () :String
    {
        var s :String = "\n";
        for (var key :String in _values) {
            s += "\n  key=" + key;
            s += "\n  value=" + _values[key];

        }
        return s;
    }


    public function update (dt :Number) :void
    {
        for (var key :String in _values) {
            var mi :MultiInt = _values[key] as MultiInt;
            if (mi != null) {
                if (mi.value1 != mi.value2 || mi.value1 != mi.value3) {
                    _cheatCallBack(key);
                    mi.repair();
                }
            }
        }
    }

    public function repair (key :String) :void
    {
        var mi :MultiInt = _values[key] as MultiInt;
        if (mi != null) {
            mi.repair();
        }
    }


    protected var _cheatCallBack :Function;
    protected var _values :Dictionary = new Dictionary();

    public static const PLAYER_CHEATED :String = "Player Cheated";
}
}

class MultiInt
{
    public function MultiInt (value :int)
    {
        value1 = int(value);
        value2 = int(value);
        value3 = int(value);
    }

    public function repair () :void
    {
        if (value1 == value2) {
            value3 = int(value1);
        }
        else if (value2 == value3) {
            value1 = int(value2);
        }
        else if (value1 == value3) {
            value2 = int(value1);
        }
        else {
            trace("More than one variable changed at once!");
            value1 = 0;
            value2 = 0;
            value3 = 0;
        }
    }

    public function set (value :int) :void
    {
        value1 = int(value);
        value2 = int(value);
        value3 = int(value);
    }


    public function toString () :String
    {
        return value1 + " " + value2 + " " + value3;
    }
    public var value1 :int;
    public var value2 :int;
    public var value3 :int;

    protected static const value2XOR :int = 98765;
    protected static const value3XOR :int = 987650;
}