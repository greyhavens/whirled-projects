package com.threerings.defense {

import flash.geom.Point;
    
import com.threerings.flash.MathUtil;

import com.threerings.defense.units.Critter;
import com.threerings.defense.units.Missile;
import com.threerings.defense.units.Spawner;
import com.threerings.defense.units.Tower;

/**
 * Contains all the game logic for directing critters on the map.
 */
public class Simulator
{
    public function Simulator (board :Board, game :Game)
    {
        _board = board;
        _game = game;
    }

    public function processSpawners (spawners :Array, gameTime :Number) :void
    {
        for each (var spawner :Spawner in spawners) {
                spawner.spawnIfPossible(gameTime);
            }
    }

    public function processTowers (towers :Array, gameTime :Number) :void
    {
        for each (var tower :Tower in towers) {
                tower.fireIfPossible(_game, gameTime);
            }
    }
    
    public function processCritters (critters :Array, dt :Number) :void
    {
        for each (var critter :Critter in critters) {
                updateCritterPosition(critter, dt);
                if (critter.delta.length < _targetUpdateEpsilon) {
                    updateTarget(critter);
                }
            }
    }

    public function processMissiles (missiles :Array, dt :Number) :void
    {
        for each (var missile :Missile in missiles) {
                updateMissilePosition(missile, dt);
                if (missile.delta.length < _targetUpdateEpsilon) {
                    _game.missileReachedTarget(missile);
                }
            }
    }
    
    protected function updateCritterPosition (c :Critter, dt :Number) :void
    {
        c.delta.x = c.target.x - c.pos.x;
        c.delta.y = c.target.y - c.pos.y;
        c.vel.x = MathUtil.clamp(c.delta.x / dt, - c.maxvel, c.maxvel);
        c.vel.y = MathUtil.clamp(c.delta.y / dt, - c.maxvel, c.maxvel);
        c.pos.offset(c.vel.x * dt, c.vel.y * dt);
    }
        
    protected function updateMissilePosition (m :Missile, dt :Number) :void
    {
        m.delta.x = m.target.x + m.target.missileHotspot.x - m.pos.x;
        m.delta.y = m.target.y + m.target.missileHotspot.y - m.pos.y;
        m.vel.x = MathUtil.clamp(m.delta.x / dt, - m.maxvel, m.maxvel);
        m.vel.y = MathUtil.clamp(m.delta.y / dt, - m.maxvel, m.maxvel);
        m.pos.offset(m.vel.x * dt, m.vel.y * dt);
    }

    protected function updateTarget (c :Critter) :void
    {
        var p :Point = _board.getPathMap(c.player).getNextNode(c.target.x, c.target.y);
        if (p != null) {
            c.target.x = p.x;
            c.target.y = p.y;
        } else {
            // trace("UNABLE TO ADVANCE CRITTER " + c + " - NO PATH FOUND!");
        }
        /*
        var delta :Point = _board.getPlayerTarget(c.player);
        delta.offset(-c.target.x, -c.target.y);

        if (Math.abs(delta.x) > Math.abs(delta.y)) {
            c.target.x += MathUtil.clamp(delta.x, -1, 1);
        } else {
            c.target.y += MathUtil.clamp(delta.y, -1, 1);
            }
        */
    }

    protected var _targetUpdateEpsilon :Number = 0.1;
    
    protected var _board :Board;
    protected var _game :Game;
}
}
