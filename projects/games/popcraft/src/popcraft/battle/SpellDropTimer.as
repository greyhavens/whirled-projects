package popcraft.battle {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.SimObjectRef;
import com.whirled.contrib.simplegame.objects.SimpleTimer;
import com.whirled.contrib.simplegame.util.Rand;

import popcraft.*;
import popcraft.game.*;

public class SpellDropTimer extends SimObject
{
    override protected function addedToDB () :void
    {
        scheduleNextSpellDrop();
    }

    protected function scheduleNextSpellDrop () :void
    {
        if (GameCtx.gameMode.availableSpells.length == 0) {
            return;
        }

        if (GameCtx.diurnalCycle.isNight) {
            var time :Number = GameCtx.gameData.spellDropTime.next();
            if (time >= 0) {
                _timerRef = GameCtx.netObjects.addObject(
                    new SimpleTimer(time, createNextSpellDrop));
            }
        }
    }

    protected function createNextSpellDrop () :void
    {
        // do we have a custom spell drop location?
        var spellLoc :Vector2 = GameCtx.gameMode.mapSettings.spellDropLoc;

        if (null == spellLoc) {
            // no - generate one

            if (GameCtx.numPlayers == 2) {
                // in a two-player game, pick a location somewhere along the line
                // that runs perpendicular to the line that connects the two bases
                var player1 :PlayerInfo = GameCtx.playerInfos[0];
                var player2 :PlayerInfo = GameCtx.playerInfos[1];
                var base1 :WorkshopUnit = player1.workshop;
                var base2 :WorkshopUnit = player2.workshop;
                if (null != base1 && null != base2) {
                    var baseLoc1 :Vector2 = base1.unitLoc;
                    var baseLoc2 :Vector2 = base2.unitLoc;
                    var baseDiff :Vector2 = baseLoc2.subtract(baseLoc1);
                    var baseDistance :Number = baseDiff.length;
                    var baseAngle :Number = baseDiff.angle;

                    // Let's give the losing player a bit of a helping hand. Shift the
                    // "baseCenter" towards the losing player's base by up to 1/2 the distance
                    // between the base and the center.
                    // @TODO - clarify this needlessly complex-looking calculation
                    var shiftAmount :Number;
                    // prevent divide-by-0
                    var baseHealth1 :Number = Math.max(base1.health / base1.maxHealth, 0.001);
                    var baseHealth2 :Number = Math.max(base2.health / base2.maxHealth, 0.001);

                    var maxSpellDropShift :Number = 1.0 -
                        GameCtx.gameData.maxLosingPlayerSpellDropShift;

                    if (baseHealth1 < baseHealth2) {
                        shiftAmount = Math.max((baseHealth1 / baseHealth2), maxSpellDropShift) *
                            (baseDistance * 0.5);
                        spellLoc = baseLoc1.add(Vector2.fromAngle(baseAngle, shiftAmount));
                    } else {
                        shiftAmount = Math.max((baseHealth2 / baseHealth1), maxSpellDropShift) *
                            (baseDistance * 0.5);
                        spellLoc = baseLoc2.subtract(Vector2.fromAngle(baseAngle, shiftAmount));
                    }

                    // pick a random location along the line running perpendicular to the line that
                    // connects our two bases, and passes through the centerLoc we just calculated
                    var direction :Number = baseLoc1.subtract(baseLoc2).angle;
                    direction += (Rand.nextBoolean(Rand.STREAM_GAME) ? Math.PI * 0.5 :
                        -Math.PI * 0.5);
                    var centerDistance :Number = GameCtx.gameData.spellDropCenterOffset.next();
                    spellLoc = spellLoc.addLocal(Vector2.fromAngle(direction, centerDistance));
                }

            } else {
                // otherwise, in a larger game, find a location near the center of the board
                // (average all player base locations together)
                var numBases :int;
                var centerLoc :Vector2 = new Vector2();
                for each (var playerInfo :PlayerInfo in GameCtx.playerInfos) {
                    var playerBase :WorkshopUnit = playerInfo.workshop;
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
        }

        if (null != spellLoc) {
            // randomize the location a bit more
            direction = Rand.nextNumberRange(0, Math.PI * 2, Rand.STREAM_GAME);
            var length :Number = GameCtx.gameData.spellDropScatter.next();
            spellLoc.addLocal(Vector2.fromAngle(direction, length));

            // clamp location
            spellLoc.x = Math.max(spellLoc.x, 75);
            spellLoc.x = Math.min(spellLoc.x, GameCtx.gameMode.battlefieldWidth - 75);
            spellLoc.y = Math.max(spellLoc.y, 75);
            spellLoc.y = Math.min(spellLoc.y, GameCtx.gameMode.battlefieldHeight - 75);

            // pick a spell at random
            var spellType :int = Rand.nextElement(GameCtx.gameMode.availableSpells,
                Rand.STREAM_GAME);
            SpellDropFactory.createSpellDrop(spellType, spellLoc, true);

            // schedule the next drop
            scheduleNextSpellDrop();
        }
    }

    override protected function update (dt :Number) :void
    {
        // spells don't get generated during the day
        if (GameCtx.diurnalCycle.isDay && !_timerRef.isNull) {
            GameCtx.netObjects.destroyObject(_timerRef);
        } else if (GameCtx.diurnalCycle.isNight && _timerRef.isNull) {
            scheduleNextSpellDrop();
        }
    }

    protected var _timerRef :SimObjectRef = new SimObjectRef();

}

}
