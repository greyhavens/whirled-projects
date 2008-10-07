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
        var hasDoomsday :Boolean = TrophyManager.hasTrophy(TrophyManager.TROPHY_DOOMSDAY);
        var hasCryHavoc :Boolean = TrophyManager.hasTrophy(TrophyManager.TROPHY_CRYHAVOC);

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
        this.checkDoomsdayTrophy();
    }

    protected function onUnitCreated (e :UnitCreatedEvent) :void
    {
        if (e.owningPlayerIndex == GameContext.localPlayerIndex) {
            var unitType :int = e.unitType;
            if (unitType == Constants.UNIT_TYPE_COLOSSUS) {
                this.checkDoomsdayTrophy();
            } else if (unitType == Constants.UNIT_TYPE_SAPPER) {
                this.checkCryHavocTrophy();
            }
        }
    }

    protected function checkDoomsdayTrophy () :void
    {
        if (TrophyManager.hasTrophy(TrophyManager.TROPHY_DOOMSDAY)) {
            return;
        }

        if (_localPlayerSpellSet.isSpellActive(Constants.SPELL_TYPE_BLOODLUST) &&
            _localPlayerSpellSet.isSpellActive(Constants.SPELL_TYPE_RIGORMORTIS) &&
            CreatureUnit.getNumPlayerCreatures(GameContext.localPlayerIndex, Constants.UNIT_TYPE_COLOSSUS) >=
                TrophyManager.DOOMSDAY_BEHEMOTHS) {
            TrophyManager.awardTrophy(TrophyManager.TROPHY_DOOMSDAY);
        }
    }

    protected function checkCryHavocTrophy () :void
    {
        if (TrophyManager.hasTrophy(TrophyManager.TROPHY_CRYHAVOC)) {
            return;
        }

        if (CreatureUnit.getNumPlayerCreatures(GameContext.localPlayerIndex, Constants.UNIT_TYPE_SAPPER) >=
             TrophyManager.CRYHAVOC_SAPPERS) {
            TrophyManager.awardTrophy(TrophyManager.TROPHY_CRYHAVOC);
        }
    }

    protected var _localPlayerSpellSet :CreatureSpellSet;
}

}
