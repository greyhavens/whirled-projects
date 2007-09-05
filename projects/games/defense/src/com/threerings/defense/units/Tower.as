package com.threerings.defense.units {

import flash.geom.Point;
    
/**
 * Definition of a single tower, including all state information, and a pointer to display object.
 * Towers occupy rectangular subsets of the board.
 */
public class Tower extends Unit
{
    public static const TYPE_SIMPLE :int = 1;

    protected var _type :int;

    public function Tower (x :int, y :int, type :int, player :int, guid :int)
    {
        super(player, x, y, 1, 1);
        updateType(type);
    }

    public function get type () :int { return _type; }

    
    public function updateType (value :int) :void
    {
        _type = value;
        switch(_type) {
        case Tower.TYPE_SIMPLE:
            size.x = size.y = 2;
            break;
        default:
            size.x = size.y = 1;
        }
    }

    public function serialize () :Object
    {
        return { x: this.pos.x, y: this.pos.y, type: this.type,
                 player: this.player, guid: this.guid };
    }

    public static function deserialize (obj :Object) :Tower
    {
        return new Tower(obj.x, obj.y, obj.type, obj.player, obj.guid);
    }

    override public function toString () :String
    {
        return "Tower " + _type + super.toString();
    }
}
}
