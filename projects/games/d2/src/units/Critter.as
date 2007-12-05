package units {
    
import flash.geom.Point;

import game.Board;
import def.EnemyDefinition;

import com.threerings.util.Assert;

/**
 * Definition of a single enemy, including state info and animations.
 */
public class Critter extends Unit
{
    /** Target position on board. */
    public var target :Point;

    /** Distance to target position, in board units. */
    public var delta :Point;

    /** Current velocity vector, in board units per second. */
    public var vel :Point;

    /** Locations where missiles will try to hit (relative to current board position,
     *  potentially fractional) */
    public var missileHotspot :Point;

    /** Critter health. Once it drops below zero, it's gone! */
    public var health :Number;

    /** Original enemy definition. */
    public var cdef :EnemyDefinition;
    
    public function Critter (
        main :Main, board :Board, x :int, y :int, typeName :String, player :int, level :uint)
    {
        super(main, board, player, x, y, 1, 1);
        updateFromType(typeName);
    }

    public function get maxspeed () :Number { return cdef.speed; }
    public function get maxhealth () :Number { return cdef.health; }
    public function get pointValue () :Number { return cdef.points; }
    public function get powerup () :Number { return cdef.powerup; }
    public function get isFlying () :Boolean { return cdef.isFlying; }
    public function get typeName () :String { return cdef.typeName; }
                                     
    public function updateFromType (typeName :String) :void
    {
        this.cdef = board.main.defs.findEnemy(typeName);
        if (cdef == null) {
            throw new Error("Unexpected enemy type: " + typeName);
        }
        
        this.vel = new Point(0, 0);
        this.target = new Point(x, y);
        this.delta = new Point(0, 0);
        this.missileHotspot = new Point(size.x / 2, - size.y / 2);
        this.health = this.maxhealth;
    }

    // position of the sprite centroid in screen coordinates
    override public function get centroidx () :Number
    {
        return board.tileWidth * (pos.x + size.x / 2);
    }

    override public function get centroidy () :Number
    {
        return board.tileHeight * (pos.y + size.y / 2);
    }

    override public function toString () :String
    {
        return typeName + " " + super.toString();
    }
}
}
