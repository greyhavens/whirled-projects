package popcraft.battle {

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.objects.*;
import com.whirled.contrib.core.resource.*;
import com.whirled.contrib.core.tasks.*;
import com.whirled.contrib.core.util.*;

import popcraft.*;
import popcraft.battle.ai.*;
import popcraft.util.*;

public class CreatureUnit extends Unit
{
    public static const GROUP_NAME :String = "CreatureUnit";

    public function CreatureUnit (unitType :uint, owningPlayerId :uint)
    {
        super(unitType, owningPlayerId);

        // start at our owning player's base's spawn loc
        var spawnLoc :Vector2 = GameMode.instance.getPlayerBase(_owningPlayerId).unitSpawnLoc;
        
        // @TODO - move this out of here
        this.x = spawnLoc.x;
        this.y = spawnLoc.y;
    }
    
    public function setMovementDestination (dest :Vector2) :void
    {
        _destination = dest.clone();
    }
    
    public function stopMoving () :void
    {
        _destination = null;
    }
    
    public function get isMoving () :Boolean
    {
        return (_destination != null);
    }
    
    public function get movementDirection () :Vector2
    {
        return _movementDirection;
    }
    
    protected function handleMove (dt :Number) :void
    {
        _movedThisFrame = false;
        
        if (this.isMoving) {
            // are we there yet?
            var curLoc :Vector2 = this.unitLoc;
            
            if (curLoc.similar(_destination, MOVEMENT_EPSILON)) {
                this.stopMoving();
            } else {
            
                _movementDirection = _destination.getSubtract(curLoc);
                
                var remainingDistance :Number = _movementDirection.normalizeAndGetLength();
                
                // don't overshoot the destination
                var distance :Number = Math.min(this.unitData.baseMoveSpeed * dt, remainingDistance);
                
                // calculate our next location
                var nextLoc :Vector2 = _movementDirection.getScale(distance);
                nextLoc.add(curLoc);
                
                // @TODO - collision checking goes here
                
                this.x = nextLoc.x;
                this.y = nextLoc.y;
                
                _movedThisFrame = true;
            }
        }
    }

    // from AppObject
    override public function get objectGroups () :Array
    {
        // every CreatureUnit is in the CreatureUnit.GROUP_NAME group
        if (null == g_groups) {
            // @TODO: make inherited groups easier to work with
            g_groups = new Array();
            g_groups.push(Unit.GROUP_NAME);
            g_groups.push(GROUP_NAME);
        }

        return g_groups;
    }

    // returns an enemy base.
    // @TODO: make this work with multiple bases and destroyed bases
    public function findEnemyBaseToAttack () :uint
    {
        var game :GameMode = GameMode.instance;
        
        var enemyBaseId :uint = 0;
        
        if (game.numPlayers > 1) {
            var enemyPlayerId :uint = game.getRandomEnemyPlayerId(_owningPlayerId);
            enemyBaseId = game.getPlayerBase(enemyPlayerId).id;
        }

        return enemyBaseId;
    }

    protected function get aiRoot () :AITask
    {
        return null;
    }

    override protected function update (dt :Number) :void
    {
        this.stopMoving();
        
        var aiRoot :AITask = this.aiRoot;
        if (null != aiRoot) {
            aiRoot.update(dt, this);
        }
        
        this.handleMove(dt);
        
        super.update(dt);
    }
    
    protected var _destination :Vector2;
    
    protected var _movedThisFrame :Boolean;
    protected var _movementDirection :Vector2;
    
    protected static const MOVEMENT_EPSILON :Number = 0.01;

    protected static var g_groups :Array;
}

}
