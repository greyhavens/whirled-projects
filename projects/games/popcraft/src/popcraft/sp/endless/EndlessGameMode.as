package popcraft.sp.endless {

import com.threerings.util.ArrayUtil;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.net.*;

import popcraft.*;
import popcraft.battle.*;
import popcraft.data.*;
import popcraft.mp.*;
import popcraft.sp.*;

public class EndlessGameMode extends GameMode
{
    public function EndlessGameMode (level :EndlessLevelData)
    {
        EndlessGameContext.gameMode = this;
        EndlessGameContext.level = level;

        this.cycleMapData();
    }

    override protected function setup () :void
    {
        super.setup();

        var scoreView :ScoreView = new ScoreView();
        scoreView.x = (Constants.SCREEN_SIZE.x - scoreView.width) * 0.5;
        scoreView.y = 5;
        this.addObject(scoreView, GameContext.overlayLayer);
    }

    public function incrementScore (offset :int) :void
    {
        _score += (offset * _scoreMultiplier);
    }

    public function get score () :int
    {
        return _score;
    }

    override public function playerEarnedResources (resourceType :int, offset :int,
        numClearPieces :int) :int
    {
        var actualResourcesEarned :int =
            super.playerEarnedResources(resourceType, offset, numClearPieces);

        this.incrementScore(actualResourcesEarned * EndlessGameContext.level.pointsPerResource);

        return actualResourcesEarned;
    }

    override public function creatureKilled (creature :CreatureUnit, killingPlayerIndex :int) :void
    {
        super.creatureKilled(creature, killingPlayerIndex);

        if (killingPlayerIndex == GameContext.localPlayerIndex) {
            this.incrementScore(EndlessGameContext.level.pointsPerCreatureKill[creature.unitType]);
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

        var baseLocs :Array = GameContext.gameMode.mapSettings.baseLocs.slice();

        var workshopData :UnitData = GameContext.gameData.units[Constants.UNIT_TYPE_WORKSHOP];
        var workshopHealth :Number = workshopData.maxHealth;

        // Create the local player (always playerIndex=0, team=0)
        var localPlayerInfo :LocalPlayerInfo = new LocalPlayerInfo(
            GameContext.localPlayerIndex, 0,
            MapSettingsData.getNextBaseLocForTeam(baseLocs, 0),
            workshopHealth, workshopHealth, false,
            1, "Dennis", null);

        GameContext.playerInfos.push(localPlayerInfo);

        // create computer players
        var playerIndex :int = 1;
        for each (var cpData :EndlessComputerPlayerData in this.curComputerGroup) {
            var team :int = cpData.team;
            var baseLoc :BaseLocationData = MapSettingsData.getNextBaseLocForTeam(baseLocs, team);
            var computerPlayerInfo :ComputerPlayerInfo = new ComputerPlayerInfo(
                playerIndex, team, baseLoc, cpData.baseHealth, cpData.baseStartHealth,
                cpData.invincible, cpData.playerName, cpData.playerHeadshot);
            GameContext.playerInfos.push(computerPlayerInfo);

            // create the computer player object
            GameContext.netObjects.addObject(new EndlessComputerPlayer(cpData, playerIndex));
        }
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

    override protected function handleGameOver () :void
    {
        fadeOutToMode(new EndlessLevelOutroMode(), FADE_OUT_TIME);
        GameContext.musicControls.fadeOut(FADE_OUT_TIME - 0.25);
        GameContext.sfxControls.fadeOut(FADE_OUT_TIME - 0.25);
    }

    protected function cycleMapData () :void
    {
        var level :EndlessLevelData = EndlessGameContext.level;

        _computerGroupIndex = 0;
        _curMapData = level.mapSequence[(++_mapDataIndex) % level.mapSequence.length];
        if (_mapDataIndex >= level.mapSequence.length && !_curMapData.repeats) {
            cycleMapData();
        }
    }

    protected function get mapCycleNumber () :int
    {
        return Math.floor(_mapDataIndex / EndlessGameContext.level.mapSequence.length) + 1;
    }

    protected function get curComputerGroup () :Array
    {
        var groups :Array = _curMapData.computerGroups;
        return groups[_computerGroupIndex % groups.length];
    }

    protected var _curMapData :EndlessMapData;
    protected var _mapDataIndex :int = -1;
    protected var _computerGroupIndex :int;

    protected var _score :int;
    protected var _scoreMultiplier :Number = 1;
}

}
