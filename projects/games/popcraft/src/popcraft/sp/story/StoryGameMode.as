package popcraft.sp.story {

import com.whirled.contrib.simplegame.net.OfflineTickedMessageManager;
import com.whirled.contrib.simplegame.net.TickedMessageManager;

import popcraft.*;
import popcraft.data.*;
import popcraft.sp.*;

public class StoryGameMode extends GameMode
{
    public function StoryGameMode ()
    {
    }

    override protected function setup () :void
    {
        super.setup();
        showIntro();
    }

    protected function showIntro () :void
    {
        AppContext.mainLoop.pushMode(new LevelIntroMode());
    }

    override public function get canPause () :Boolean
    {
        return true;
    }

    override protected function createPlayers () :void
    {
        GameContext.localPlayerIndex = 0;
        GameContext.playerInfos = [];

        var level :LevelData = GameContext.spLevel;

        // in single player levels, base location are arranged in order of player id
        var baseLocs :Array = GameContext.mapSettings.baseLocs;

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

        // setup target enemies
        for each (var playerInfo :PlayerInfo in GameContext.playerInfos) {
            playerInfo.targetedEnemyId =
                GameContext.findEnemyForPlayer(playerInfo.playerIndex).playerIndex;
        }
    }

    override protected function createRandSeed () :uint
    {
        return uint(Math.random() * uint.MAX_VALUE);
    }
    
    override protected function createMessageManager () :TickedMessageManager
    {
        return new OfflineTickedMessageManager(AppContext.gameCtrl, TICK_INTERVAL_MS);
    }

}

}
