package popcraft.sp.endless {

import com.whirled.contrib.simplegame.net.OnlineTickedMessageManager;

import popcraft.*;
import popcraft.data.EndlessMapData;
import popcraft.mp.*;

public class EndlessGameMode extends GameMode
{
    override public function get canPause () :Boolean
    {
        return GameContext.isSinglePlayerGame;
    }

    override protected function createPlayers () :void
    {
        GameContext.localPlayerIndex = 0;
        GameContext.playerInfos = [];

        var level :LevelData = GameContext.storyLevel;

        // in single player levels, base location are arranged in order of player id
        var baseLocs :Array = GameContext.gameMode.mapSettings.baseLocs;

        // Create the local player (always playerIndex=0, team=0)
        var localPlayerInfo :LocalPlayerInfo = new LocalPlayerInfo(
            0, 0, baseLocs[0], 1, level.playerName, level.playerHeadshot);

        // grant the player some starting resources
        var initialResources :Array = level.initialResources;
        for (var resType :int = 0; resType < initialResources.length; ++resType) {
            localPlayerInfo.setResourceAmount(resType, int(initialResources[resType]));
        }

        // ...and some starting spells
        var initialSpells :Array = level.initialSpells;
        for (var spellType :int = 0; spellType < initialSpells.length; ++spellType) {
            localPlayerInfo.addSpell(spellType, int(initialSpells[spellType]));
        }

        GameContext.playerInfos.push(localPlayerInfo);

        // create computer players
        var numComputers :int = level.computers.length;
        for (var playerIndex :int = 1; playerIndex < numComputers + 1; ++playerIndex) {
            var cpData :ComputerPlayerData = level.computers[playerIndex - 1];
            var computerPlayerInfo :ComputerPlayerInfo = new ComputerPlayerInfo(
                playerIndex, cpData.team, baseLocs[playerIndex], cpData.playerName,
                cpData.playerHeadshot);
            GameContext.playerInfos.push(computerPlayerInfo);

            // create the computer player object
            GameContext.netObjects.addObject(new ComputerPlayer(cpData, playerIndex));
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

    override protected function createInitialWorkshops () :void
    {
        var numPlayers :int = GameContext.numPlayers;
        for (var playerIndex :int = 0; playerIndex < numPlayers; ++playerIndex) {

            // in single-player levels, bases have custom health
            var maxHealthOverride :int = 0;
            var startingHealthOverride :int = 0;
            var invincible :Boolean;
            if (playerIndex == 0) {
                maxHealthOverride = GameContext.storyLevel.playerBaseHealth;
                startingHealthOverride = GameContext.storyLevel.playerBaseStartHealth;
            } else {
                var cpData :ComputerPlayerData = GameContext.storyLevel.computers[playerIndex - 1];
                maxHealthOverride = cpData.baseHealth;
                startingHealthOverride = cpData.baseStartHealth;
                invincible = cpData.invincible;
            }

            var playerInfo :PlayerInfo = GameContext.playerInfos[playerIndex];
            var baseLoc :Vector2 = playerInfo.baseLoc;

            var base :WorkshopUnit = GameContext.unitFactory.createBaseUnit(playerIndex,
                maxHealthOverride, startingHealthOverride);
            base.isInvincible = invincible;
            base.x = baseLoc.x;
            base.y = baseLoc.y;

            playerInfo.base = base;
        }
    }

    override public function localPlayerPurchasedCreature (unitType :int) :void
    {
        if (GameContext.storyLevel.isAvailableUnit(unitType)) {
            super.localPlayerPurchasedCreature(unitType);
        }
    }

    override protected function handleGameOver () :void
    {
        // show the appropriate outro screen
        var nextMode :AppMode;
        var levelPackResources :Array = [];
        if (AppContext.levelMgr.isLastLevel &&
            GameContext.winningTeamId == GameContext.localPlayerInfo.teamId) {

            nextMode = new EpilogueMode(EpilogueMode.TRANSITION_LEVELOUTRO);
            levelPackResources = Resources.EPILOGUE_RESOURCES;

        } else {
            nextMode = new LevelOutroMode();
        }

        fadeOut(function () :void {
            Resources.loadLevelPackResourcesAndSwitchModes(levelPackResources, nextMode);
        }, FADE_OUT_TIME);

        GameContext.musicControls.fadeOut(FADE_OUT_TIME - 0.25);
        GameContext.sfxControls.fadeOut(FADE_OUT_TIME - 0.25);
    }

    protected function get mapData () :EndlessMapData
    {
        return GameContext.endlessLevel.mapSequence[_mapDataIndex];
    }

    protected var _mapDataIndex :int;
}

}
