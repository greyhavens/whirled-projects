package units {
    
import flash.geom.Point;

import game.Board;
import def.EnemyDefinition;

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
    public var def :EnemyDefinition;
    
    public function Critter (board :Board, x :int, y :int, type :int, player :int, level :uint)
    {
        super(board, player, x, y, 1, 1);
        updateFromType(type);
    }

    public function get maxspeed () :Number { return def.speed; }
    public function get maxhealth () :Number { return def.health; }
    public function get pointValue () :Number { return def.points; }
    public function get powerup () :Number { return def.powerup; }
    public function get isFlying () :Boolean { return def.isFlying; }
                                     
    public function updateFromType (typeName :String) :void
    {
        this.def = board.def.pack.findEnemy(typeName);

        this.vel = new Point(0, 0);
        this.target = new Point(x, y);
        this.delta = new Point(0, 0);
        this.missileHotspot = new Point(size.x / 2, - size.y / 2); 
        
        UnitDefinitions.initializeCritter(type, this, level);
    }

            // position of the sprite centroid in screen coordinates
    override public function get centroidx () :Number
    {
        return _board.tileWidth * (pos.x + size.x / 2);
    }

    override public function get centroidy () :Number
    {
        return _board.tileHeight * (pos.y + size.y / 2);
    }
}
}
