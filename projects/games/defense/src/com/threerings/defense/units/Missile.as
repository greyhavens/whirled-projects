package com.threerings.defense.units {
    
import flash.geom.Point;

import com.threerings.defense.Board;
import com.threerings.defense.tuning.UnitDefinitions;
    
public class Missile extends Unit
{
    public static const TYPE_PAPER_PLANE :int = 1;

    /** Missile type, one of the TYPE_* constants. */
    public var type :int;

    /** Source that fired the missile. */
    public var source :Tower;

    /** Target where the missile is headed. */
    public var target :Critter;

    /** Distance to target, in board units. */
    public var delta :Point;
    
    /** Current velocity vector, in board units per second. */
    public var vel :Point;

    /** Max velocity, in board units per second. */
    public var maxvel :Number; 

    /** How much damage this missile inflicts on the critter. */
    public var damage :Number;
    
    public function Missile (source :Tower, target :Critter, type :int, player :int)
    {
        var startx :Number = source.pos.x + source.missileHotspot.x;
        var starty :Number = source.pos.y + source.missileHotspot.y;
        super(player, startx, starty, 0.5, 0.5);

        this.type = type;
        this.source = source;
        this.target = target;
        this.delta = new Point(Infinity, Infinity); // this will be recalculated anyway
        this.vel = new Point(0, 0);

        UnitDefinitions.initializeMissile(type, this);
        
        this.maxvel = 5;
        this.damage = 1;
    }

    // from Unit
    override public function get centroidx () :Number
    {
        return Board.SQUARE_WIDTH * pos.x;
    }

    // from Unit
    override public function get centroidy () :Number
    {
        return Board.SQUARE_HEIGHT * pos.y;
    }

}
}
