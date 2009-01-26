package popcraft {

import popcraft.battle.*;
import popcraft.game.*;

/**
 * Keeps track of several trophies that are awarded through in-game events:
 * "Doomsday"
 * "Cry Havoc"
 */
public class TrophyWatcher
{
    public function TrophyWatcher ()
    {
        var hasDoomsday :Boolean = ClientCtx.hasTrophy(Trophies.DOOMSDAY);
        var hasCryHavoc :Boolean = ClientCtx.hasTrophy(Trophies.CRYHAVOC);

        if (!hasDoomsday) {
            _localPlayerSpellSet = GameCtx.getActiveSpellSet(GameCtx.localPlayerIndex);
            _localPlayerSpellSet.addEventListener(CreatureSpellSet.SET_MODIFIED, onSpellSetModified);
        }

        if (!hasDoomsday || !hasCryHavoc) {
            GameCtx.unitFactory.addEventListener(UnitCreatedEvent.UNIT_CREATED, onUnitCreated);
        }
    }

    protected function onSpellSetModified (...ignored) :void
    {
        checkDoomsdayTrophy();
    }

    protected function onUnitCreated (e :UnitCreatedEvent) :void
    {
        if (e.owningPlayerIndex == GameCtx.localPlayerIndex) {
            var unitType :int = e.unitType;
            if (unitType == Constants.UNIT_TYPE_COLOSSUS) {
                checkDoomsdayTrophy();
            } else if (unitType == Constants.UNIT_TYPE_SAPPER) {
                checkCryHavocTrophy();
            }
        }
    }

    protected function checkDoomsdayTrophy () :void
    {
        if (ClientCtx.hasTrophy(Trophies.DOOMSDAY)) {
            return;
        }

        if (_localPlayerSpellSet.isSpellActive(Constants.SPELL_TYPE_BLOODLUST) &&
            _localPlayerSpellSet.isSpellActive(Constants.SPELL_TYPE_RIGORMORTIS) &&
            CreatureUnit.getNumPlayerCreatures(GameCtx.localPlayerIndex, Constants.UNIT_TYPE_COLOSSUS) >=
                Trophies.DOOMSDAY_BEHEMOTHS) {
            ClientCtx.awardTrophy(Trophies.DOOMSDAY);
        }
    }

    protected function checkCryHavocTrophy () :void
    {
        if (ClientCtx.hasTrophy(Trophies.CRYHAVOC)) {
            return;
        }

        if (CreatureUnit.getNumPlayerCreatures(GameCtx.localPlayerIndex, Constants.UNIT_TYPE_SAPPER) >=
             Trophies.CRYHAVOC_SAPPERS) {
            ClientCtx.awardTrophy(Trophies.CRYHAVOC);
        }
    }

    protected var _localPlayerSpellSet :CreatureSpellSet;
}

}
