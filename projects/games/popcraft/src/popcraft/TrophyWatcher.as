package popcraft {

import popcraft.battle.*;

/**
 * Keeps track of several trophies that are awarded through in-game events:
 * "Doomsday"
 * "Cry Havoc"
 */
public class TrophyWatcher
{
    public function TrophyWatcher ()
    {
        var hasDoomsday :Boolean = AppContext.hasTrophy(Trophies.DOOMSDAY);
        var hasCryHavoc :Boolean = AppContext.hasTrophy(Trophies.CRYHAVOC);

        if (!hasDoomsday) {
            _localPlayerSpellSet = GameContext.getActiveSpellSet(GameContext.localPlayerIndex);
            _localPlayerSpellSet.addEventListener(CreatureSpellSet.SET_MODIFIED, onSpellSetModified);
        }

        if (!hasDoomsday || !hasCryHavoc) {
            GameContext.unitFactory.addEventListener(UnitCreatedEvent.UNIT_CREATED, onUnitCreated);
        }
    }

    protected function onSpellSetModified (...ignored) :void
    {
        checkDoomsdayTrophy();
    }

    protected function onUnitCreated (e :UnitCreatedEvent) :void
    {
        if (e.owningPlayerIndex == GameContext.localPlayerIndex) {
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
        if (AppContext.hasTrophy(Trophies.DOOMSDAY)) {
            return;
        }

        if (_localPlayerSpellSet.isSpellActive(Constants.SPELL_TYPE_BLOODLUST) &&
            _localPlayerSpellSet.isSpellActive(Constants.SPELL_TYPE_RIGORMORTIS) &&
            CreatureUnit.getNumPlayerCreatures(GameContext.localPlayerIndex, Constants.UNIT_TYPE_COLOSSUS) >=
                Trophies.DOOMSDAY_BEHEMOTHS) {
            AppContext.awardTrophy(Trophies.DOOMSDAY);
        }
    }

    protected function checkCryHavocTrophy () :void
    {
        if (AppContext.hasTrophy(Trophies.CRYHAVOC)) {
            return;
        }

        if (CreatureUnit.getNumPlayerCreatures(GameContext.localPlayerIndex, Constants.UNIT_TYPE_SAPPER) >=
             Trophies.CRYHAVOC_SAPPERS) {
            AppContext.awardTrophy(Trophies.CRYHAVOC);
        }
    }

    protected var _localPlayerSpellSet :CreatureSpellSet;
}

}
