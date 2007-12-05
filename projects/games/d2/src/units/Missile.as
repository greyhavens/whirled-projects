package units {
    
import flash.geom.Point;
import flash.utils.getTimer; // function import

import game.Board;
    
public class Missile extends Unit
{
    public static const DEFAULT_MISSILE_DELAY :int = 1000;
    
    /** Source that fired the missile. */
    public var source :Tower;

    /** Target where the missile is headed. */
    public var target :Critter;

    /** Distance to target, in board units. */
    public var delta :Point;
    
    /** Current velocity vector, in board units per second. */
    public var vel :Point;

    /** Activation time, in milliseconds since the beginning of epoch. */
    public var activationTime :int;
    
    /** Creation time, in milliseconds since the beginning of epoch. */
    public var creationTime :int;
    
    public function Missile (
        main :Main, board :Board, source :Tower, target :Critter, player :int)
    {
        var startx :Number = source.pos.x + source.missileHotspot.x;
        var starty :Number = source.pos.y + source.missileHotspot.y;
        super(main, board, player, startx, starty, 0.5, 0.5);

        this.source = source;
        this.target = target;
        this.delta = new Point(Infinity, Infinity); // this will be recalculated anyway
        this.vel = new Point(0, 0);
        this.creationTime = getTimer();
        this.activationTime = creationTime +
            ((source.tdef.missileDelay > 0) ? source.tdef.missileDelay : DEFAULT_MISSILE_DELAY);
    }

    public function get maxvel () :Number { return source.tdef.missileSpeed; }
    public function get damage () :Number { return source.tdef.missileDamage; }
    public function get sourceTypeName () :String { return source.tdef.typeName; }

    // from Unit
    override public function get centroidx () :Number
    {
        return board.tileWidth * pos.x;
    }

    // from Unit
    override public function get centroidy () :Number
    {
        return board.tileHeight * pos.y;
    }

    public function getAgeMs () :int
    {
        return getTimer() - activationTime;
    }

    public function isActive () :Boolean
    {
        return getAgeMs() > 0;
    }
}
}
    
