package popcraft.sp.endless {

import com.threerings.flash.Vector2;
import com.threerings.util.ArrayUtil;
import com.threerings.util.KeyboardCodes;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.net.*;
import com.whirled.contrib.simplegame.objects.SimpleTimer;
import com.whirled.contrib.simplegame.util.Rand;

import popcraft.*;
import popcraft.battle.*;
import popcraft.data.*;
import popcraft.mp.*;
import popcraft.sp.*;

public class EndlessGameMode extends GameMode
{
    public static const HUMAN_TEAM_ID :int = 0;
    public static const FIRST_COMPUTER_TEAM_ID :int = 1;

    public function EndlessGameMode (level :EndlessLevelData = null)
    {
        if (level != null) {
            EndlessGameContext.level = level;
            _needsReset = true;
        } else {
            _needsReset = false;
        }
    }

    override protected function setup () :void
    {
        if (_needsReset) {
            EndlessGameContext.reset();
        }

        EndlessGameContext.gameMode = this;
        _curMapData = EndlessGameContext.cycleMapData();

        super.setup();

        var scoreView :ScoreView = new ScoreView();
        scoreView.x = (Constants.SCREEN_SIZE.x - scoreView.width) * 0.5;
        scoreView.y = 5;
        this.addObject(scoreView, GameContext.overlayLayer);

        // create the multipliers that were left over from the last map
        for (var ii :int = 0; ii < EndlessGameContext.numMultiplierObjects; ++ii) {
            this.createMultiplierDrop(false);
        }
    }

    override protected function destroy () :void
    {
        // save data about our human players so that they can be resurrected
        // when the next round starts
        for each (var playerInfo :PlayerInfo in GameContext.playerInfos) {
            if (playerInfo.teamId == HUMAN_TEAM_ID) {
                if (playerInfo.playerIndex == GameContext.localPlayerIndex) {
                    EndlessGameContext.savedLocalPlayer = GameContext.localPlayerInfo.saveData();
                } else {
                    EndlessGameContext.savedRemotePlayer = playerInfo.saveData();
                }
            }
        }

        // save the number of multipliers left on the field so the player has a chance
        // to grab them on the next map
        var numMultipliers :int;
        var netObjs :ObjectDB = GameContext.netObjects;
        for each (var spellDrop :SpellDropObject in netObjs.getObjectsInGroup(SpellDropObject.GROUP_NAME)) {
            if (spellDrop.spellType == Constants.SPELL_TYPE_MULTIPLIER) {
                numMultipliers += 1;
            }
        }

        for each (var carriedSpell :CarriedSpellObject in netObjs.getObjectsInGroup(CarriedSpellObject.GROUP_NAME)) {
            if (carriedSpell.spellType == Constants.SPELL_TYPE_MULTIPLIER) {
                numMultipliers += 1;
            }
        }

        EndlessGameContext.numMultiplierObjects = numMultipliers;

        super.destroy();
    }

    override protected function updateNetworkedObjects () :void
    {
        super.updateNetworkedObjects();

        // sync the local player's workshop damage shield count to their score multiplier
        var localPlayerWorkshop :WorkshopUnit = GameContext.localPlayerInfo.workshop;
        var multiplier :int =
            (localPlayerWorkshop != null ? localPlayerWorkshop.damageShields.length + 1 : 1);
        EndlessGameContext.scoreMultiplier = multiplier;

        this.checkForComputerDeath();
    }

    override protected function checkForGameOver () :void
    {
        if (!Boolean(_teamLiveStatuses[HUMAN_TEAM_ID])) {
            _gameOver = true;
        }
    }

    protected function checkForComputerDeath () :void
    {
        if (!_swappingInNextOpponents) {
            var computersAreDead :Boolean = true;
            for (var teamId :int = FIRST_COMPUTER_TEAM_ID; teamId < _teamLiveStatuses.length;
                ++teamId) {
                if (Boolean(_teamLiveStatuses[teamId])) {
                    computersAreDead = false;
                    break;
                }
            }

            if (computersAreDead) {
                this.createMultiplierDrop(true);

                // swap in the next opponents when 5 seconds have passed
                GameContext.netObjects.addObject(new SimpleTimer(5, swapInNextOpponents));
                _swappingInNextOpponents = true;
            }
        }
    }

    protected function createMultiplierDrop (playSound :Boolean) :void
    {
        var scatterLen :Number = Rand.nextNumberRange(0, _curMapData.multiplierScatterRadius,
            Rand.STREAM_GAME);
        var rotation :Number = Rand.nextNumberRange(0, Math.PI * 2, Rand.STREAM_GAME);
        var loc :Vector2 = Vector2.fromAngle(rotation, scatterLen).addLocal(
            _curMapData.multiplierDropLoc);

        SpellDropFactory.createSpellDrop(Constants.SPELL_TYPE_MULTIPLIER, loc, playSound);
    }

    protected function multiplierIsOnPlayfield () :Boolean
    {
        var spellDrops :Array = GameContext.netObjects.getObjectsInGroup(SpellDropObject.GROUP_NAME);
        for each (var spellDrop :SpellDropObject in spellDrops) {
            if (spellDrop.spellType == Constants.SPELL_TYPE_MULTIPLIER) {
                return true;
            }
        }

        return false;
    }

    protected function swapInNextOpponents () :void
    {
        if (_computerGroupIndex < _curMapData.computerGroups.length - 1) {
            // there are more opponents left on this map. swap the next ones in.

            var playerInfo :PlayerInfo;
            for (;;) {
                var playerIndex :int =  GameContext.playerInfos.length - 1;
                playerInfo = GameContext.playerInfos[playerIndex];
                if (playerInfo.teamId == HUMAN_TEAM_ID) {
                    break;
                }

                GameContext.playerInfos.pop();
                playerInfo.destroy();
            }

            ++_computerGroupIndex;
            // createComputerPlayers() populates GameContext.playerInfos
            var newPlayerInfos :Array = this.createComputerPlayers();
            for each (playerInfo in newPlayerInfos) {
                playerInfo.init();
            }

            // switch immediately to daytime
            if (!GameContext.diurnalCycle.isDay) {
                GameContext.diurnalCycle.resetPhase(Constants.PHASE_DAY);
            }

            GameContext.dashboard.updatePlayerStatusViews();

        } else {
            // move to the next map (see handleGameOver())
            _gameOver = true;
            _switchingMaps = true;
        }

        _swappingInNextOpponents = false;
    }

    override protected function handleGameOver () :void
    {
        if (_switchingMaps) {
            // if we're switching maps, don't show the game-over screen, just switch to a new
            // endless game mode
            this.fadeOutToMode(new EndlessGameMode());

        } else {
            this.fadeOutToMode(new EndlessLevelOutroMode(), FADE_OUT_TIME);
            GameContext.musicControls.fadeOut(FADE_OUT_TIME - 0.25);
            GameContext.sfxControls.fadeOut(FADE_OUT_TIME - 0.25);
        }
    }

    override protected function applyCheatCode (keyCode :uint) :void
    {
        switch (keyCode) {
        case KeyboardCodes.M:
            this.spellDeliveredToPlayer(GameContext.localPlayerIndex,
                Constants.SPELL_TYPE_MULTIPLIER);
            break;

        case KeyboardCodes.SLASH:
            AppContext.endlessLevelMgr.playLevel(null, true);
            break;

        case KeyboardCodes.O:
            this.swapInNextOpponents();
            break;

        default:
            super.applyCheatCode(keyCode);
            break;
        }
    }

    override public function playerEarnedResources (resourceType :int, offset :int,
        numClearPieces :int) :int
    {
        var actualResourcesEarned :int =
            super.playerEarnedResources(resourceType, offset, numClearPieces);

        EndlessGameContext.incrementScore(
            actualResourcesEarned * EndlessGameContext.level.pointsPerResource);

        return actualResourcesEarned;
    }

    override public function creatureKilled (creature :CreatureUnit, killingPlayerIndex :int) :void
    {
        super.creatureKilled(creature, killingPlayerIndex);

        if (killingPlayerIndex == GameContext.localPlayerIndex) {
            EndlessGameContext.incrementScore(
                EndlessGameContext.level.pointsPerCreatureKill[creature.unitType]);
        }
    }

    override public function spellDeliveredToPlayer (playerIndex :int, spellType :int) :void
    {
        super.spellDeliveredToPlayer(playerIndex, spellType);

        // multiplier spells increase the player's score multiplier, and also add little damage
        // shields to his workshop
        if (spellType == Constants.SPELL_TYPE_MULTIPLIER) {
            var workshop :WorkshopUnit = PlayerInfo(GameContext.playerInfos[playerIndex]).workshop;
            if (workshop != null &&
                workshop.damageShields.length < EndlessGameContext.level.maxMultiplier) {

                workshop.addDamageShield(EndlessGameContext.level.multiplierDamageSoak);
            }

            if (playerIndex == GameContext.localPlayerIndex) {
                EndlessGameContext.incrementMultiplier();
            }
        }
    }

    override public function get canPause () :Boolean
    {
        return GameContext.isSinglePlayerGame;
    }

    override public function isAvailableUnit (unitType :int) :Boolean
    {
        return ArrayUtil.contains(_curMapData.availableUnits, unitType);
    }

    override public function get availableSpells () :Array
    {
        return _curMapData.availableSpells;
    }

    override public function get mapSettings () :MapSettingsData
    {
        return _curMapData.mapSettings;
    }

    override protected function createPlayers () :void
    {
        if (GameContext.isMultiplayerGame) {
            // TODO
            throw new Error("implement this");
        }

        GameContext.localPlayerIndex = 0;
        GameContext.playerInfos = [];

        var workshopData :UnitData = GameContext.gameData.units[Constants.UNIT_TYPE_WORKSHOP];
        var workshopHealth :Number = workshopData.maxHealth;

        // Create the local player
        var playerDisplayData :PlayerDisplayData =
            GameContext.gameData.getPlayerDisplayData(EndlessGameContext.level.humanPlayerNames[0]);
        var localPlayerInfo :LocalPlayerInfo = new LocalPlayerInfo(
            GameContext.localPlayerIndex,
            HUMAN_TEAM_ID,
            _curMapData.humanBaseLocs[0],
            workshopHealth, workshopHealth, false,
            1, playerDisplayData.color, playerDisplayData.displayName, playerDisplayData.headshot);

        GameContext.playerInfos.push(localPlayerInfo);

        this.createComputerPlayers();

        // init players
        for each (var playerInfo :PlayerInfo in GameContext.playerInfos) {
            playerInfo.init();
        }

        // restore saved data
        if (EndlessGameContext.savedLocalPlayer != null) {
            localPlayerInfo.restoreSavedData(EndlessGameContext.savedLocalPlayer);
        }
    }

    protected function createComputerPlayers () :Array
    {
        if (GameContext.isMultiplayerGame) {
            // TODO
            throw new Error("implement this");
        }

        var mapCycleNumber :int = EndlessGameContext.mapCycleNumber;

        var playerIndex :int = 1;
        var computerGroup :Array = _curMapData.computerGroups[_computerGroupIndex];
        var newInfos :Array  = [];
        for each (var cpData :EndlessComputerPlayerData in computerGroup) {
            var healthScale :Number = Math.pow(cpData.baseHealthScale, mapCycleNumber);
            var playerInfo :PlayerInfo =
                new EndlessComputerPlayerInfo(playerIndex, cpData, healthScale);

            GameContext.playerInfos.push(playerInfo);
            newInfos.push(playerInfo);

            ++playerIndex;
        }

        return newInfos;
    }

    override protected function createRandSeed () :uint
    {
        if (GameContext.isSinglePlayerGame) {
            return uint(Math.random() * uint.MAX_VALUE);
        } else {
            return MultiplayerConfig.randSeed;
        }
    }

    override protected function createMessageManager () :TickedMessageManager
    {
        if (GameContext.isSinglePlayerGame) {
            return new OfflineTickedMessageManager(AppContext.gameCtrl, TICK_INTERVAL_MS);
        } else {
            return new OnlineTickedMessageManager(AppContext.gameCtrl,
                SeatingManager.isLocalPlayerInControl, TICK_INTERVAL_MS);
        }
    }

    protected var _curMapData :EndlessMapData;
    protected var _computerGroupIndex :int;
    protected var _needsReset :Boolean;
    protected var _switchingMaps :Boolean;
    protected var _swappingInNextOpponents :Boolean;
}

}

import com.whirled.contrib.simplegame.*;

import popcraft.*;
import popcraft.battle.*;

class WaitForMultiplierRetrievalTask
    implements ObjectTask
{
    public function WaitForMultiplierRetrievalTask (maxTime :Number)
    {
        _maxTime = maxTime;
    }

    public function update (dt :Number, obj :SimObject) :Boolean
    {
        _elapsedTime += dt;
        if (_elapsedTime >= _maxTime) {
            return true;
        } else {
            return !this.multipliersExist;
        }
    }

    protected function get multipliersExist () :Boolean
    {
        var netObjs :ObjectDB = GameContext.netObjects;
        for each (var spellDrop :SpellDropObject in netObjs.getObjectsInGroup(SpellDropObject.GROUP_NAME)) {
            if (spellDrop.spellType == Constants.SPELL_TYPE_MULTIPLIER) {
                return true;
            }
        }

        for each (var carriedSpell :CarriedSpellObject in netObjs.getObjectsInGroup(CarriedSpellObject.GROUP_NAME)) {
            if (carriedSpell.spellType == Constants.SPELL_TYPE_MULTIPLIER) {
                return true;
            }
        }

        return false;
    }

    public function clone () :ObjectTask
    {
        return new WaitForMultiplierRetrievalTask(_maxTime);
    }

    public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        return false;
    }

    protected var _maxTime :Number;
    protected var _elapsedTime :Number = 0;
}
