package popcraft.battle {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.SimObjectRef;
import com.whirled.contrib.simplegame.objects.SimpleTimer;
import com.whirled.contrib.simplegame.util.Rand;

import popcraft.*;

public class SpellDropTimer extends SimObject
{
    override protected function addedToDB () :void
    {
        this.scheduleNextSpellDrop();
    }

    protected function scheduleNextSpellDrop () :void
    {
        if (GameContext.isSinglePlayer && GameContext.spLevel.availableSpells.length == 0) {
            this.destroySelf();
        }

        if (GameContext.diurnalCycle.isNight) {
            var time :Number = GameContext.gameData.spellDropTime.next();
            if (time >= 0) {
                _timerRef = GameContext.netObjects.addObject(new SimpleTimer(time, createNextSpellDrop));
            }
        }
    }

    protected function createNextSpellDrop () :void
    {
        var spellLoc :Vector2;

        if (GameContext.numPlayers == 2) {
            // in a two-player game, pick a location somewhere along the line
            // that runs perpendicular to the line that connects the two bases
            var base1 :PlayerBaseUnit = PlayerData(GameContext.playerData[0]).base;
            var base2 :PlayerBaseUnit = PlayerData(GameContext.playerData[1]).base;
            if (null != base1 && null != base2) {
                var baseLoc1 :Vector2 = base1.unitLoc;
                var baseLoc2 :Vector2 = base2.unitLoc;
                var baseCenter :Vector2 = new Vector2(
                    (baseLoc1.x + baseLoc2.x) * 0.5, (baseLoc1.y + baseLoc2.y) * 0.5);

                var direction :Number = baseLoc1.subtract(baseLoc2).angle;
                direction += (Rand.nextBoolean(Rand.STREAM_GAME) ? Math.PI * 0.5 : -Math.PI * 0.5);
                var centerDistance :Number = GameContext.gameData.spellDropCenterOffset.next();
                spellLoc = Vector2.fromAngle(direction, centerDistance).addLocal(baseCenter);
            }

        } else {
            // otherwise, in a larger game, find a location near the center of the board
            // (average all player base locations together)
            var numBases :int;
            var centerLoc :Vector2 = new Vector2();
            for each (var playerData :PlayerData in GameContext.playerData) {
                var playerBase :PlayerBaseUnit = playerData.base;
                if (null != playerBase) {
                    centerLoc.addLocal(playerBase.unitLoc);
                    ++numBases;
                }
            }

            if (numBases > 0) {
                centerLoc.x /= numBases;
                centerLoc.y /= numBases;
                spellLoc = centerLoc;
            }
        }

        if (null != spellLoc) {
            // randomize the location a bit more
            direction = Rand.nextNumberRange(0, Math.PI * 2, Rand.STREAM_GAME);
            var length :Number = GameContext.gameData.spellDropScatter.next();
            spellLoc.addLocal(Vector2.fromAngle(direction, length));

            // clamp location
            spellLoc.x = Math.max(spellLoc.x, 75);
            spellLoc.x = Math.min(spellLoc.x, Constants.SCREEN_DIMS.x - 75);
            spellLoc.y = Math.max(spellLoc.y, 75);
            spellLoc.y = Math.min(spellLoc.y, Constants.SCREEN_DIMS.y - 75);

            // pick a spell at random
            var spellType :uint;
            if (GameContext.isSinglePlayer) {
                var availableSpells :Array = GameContext.spLevel.availableSpells;
                spellType = availableSpells[Rand.nextIntRange(0, availableSpells.length, Rand.STREAM_GAME)];
            } else {
                spellType = Rand.nextIntRange(0, Constants.SPELL_NAMES.length, Rand.STREAM_GAME);
            }

            SpellDropFactory.createSpellDrop(spellType, spellLoc, true);

            // schedule the next drop
            this.scheduleNextSpellDrop();
        }
    }

    override protected function update (dt :Number) :void
    {
        // spells don't get generated during the day
        if (GameContext.diurnalCycle.isDay && !_timerRef.isNull) {
            GameContext.netObjects.destroyObject(_timerRef);
        } else if (GameContext.diurnalCycle.isNight && _timerRef.isNull) {
            this.scheduleNextSpellDrop();
        }
    }

    protected var _timerRef :SimObjectRef = new SimObjectRef();

}

}
