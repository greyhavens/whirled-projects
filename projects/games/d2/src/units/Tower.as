package units {

import flash.geom.Point;
import mx.utils.ObjectUtil;

import game.Board;
import game.Game;

import def.TowerDefinition;
    
/**
 * Definition of a single tower, including all state information, and a pointer to display object.
 * Towers occupy rectangular subsets of the board.
 */
public class Tower extends Unit
{
    /** Position on the tower (in board units, potentially fractional, from the upper left)
     *  from which missiles should be fired. */
    public var missileHotspot :Point;

    /** Original tower definition. */
    public var tdef :TowerDefinition;

    /** Game time when the tower will be able to fire again. */
    public var nextFiringTime :Number = 0;

    public function Tower (
        main :Main, board :Board, x :Number, y :Number, type :String, player :int, guid :int)
    {
        super(main, board, player, x, y, 1, 1);
        updateFromType(type);
    }

    public function get pauseBetweenMissiles () :Number { return tdef.pauseBetweenMissiles; }
    public function get cost () :Number { return tdef.cost; }
    public function get rangeMaxSq () :Number { return tdef.rangeMax * tdef.rangeMax; }
    public function get typeName () :String { return tdef.typeName; }
    
    public function updateFromType (typeName :String) :void
    {
        // remember type
        this.tdef = board.main.defs.findTower(typeName);
        if (tdef == null) {
            throw new Error("Unexpected tower type: " + typeName);
        }

        // update size, since it'll be different
        this.size = new Point(tdef.width, tdef.height);
        
        // now update missile hotspot from size
        this.missileHotspot = new Point(size.x / 2, 0);
    }

    /** Checks if the tower can fire at anything right now, and if so, returns a target critter;
     *  otherwise returns null. */
    public function canFire (gameobj :Game, gameTime :Number) :Critter
    {
        if (gameTime <= nextFiringTime) {
            return null; // be patient
        }
        
        return findTargetCritter(gameobj);
    }
    
    /** Creates a missile and fires it at the critter. */
    public function fireAt (critter :Critter, gameobj :Game, gameTime :Number) :void
    {
        // got one, let's fire!
        var missile :Missile = new Missile(main, board, this, critter, player);
        gameobj.handleAddMissile(missile);

        // now cool down
        nextFiringTime = gameTime + pauseBetweenMissiles;
    }
    
    /** Returns a target critter within range, or null if none could be found. */
    protected function findTargetCritter (gameobj :Game) :Critter
    {
        var critters :Array = gameobj.getCritters();
        for each (var critter :Critter in critters) {
                var dx :Number = (centroidx - critter.centroidx) / board.tileWidth;
                var dy :Number = (centroidy - critter.centroidy) / board.tileHeight;
                var dsquared :Number = dx * dx + dy * dy;
                // check if distance is within range
                if (dsquared <= rangeMaxSq) {
                    // check ownership - for single player games, any critter will do,
                    // otherwise we have to make sure we're not shooting at our guys
                    if (main.isSinglePlayer ||
                        critter.player != this.player)
                    {
                        return critter;
                    }
                }
            }
        
        return null;
    }

    public function serialize () :Object
    {
        return { x: this.pos.x, y: this.pos.y, typeName: this.typeName,
                player: this.player, guid: this.guid };
    }

    public static function deserialize (main :Main, board :Board, obj :Object) :Tower
    {
        return new Tower(main, board, obj.x, obj.y, obj.typeName, obj.player, obj.guid);
    }

    override public function toString () :String
    {
        return typeName + " " + super.toString();
    }
}
}
    
