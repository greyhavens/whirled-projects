package popcraft.sp.endless {

import com.threerings.flash.Vector2;
import com.threerings.util.ArrayUtil;
import com.threerings.util.KeyboardCodes;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.net.*;
import com.whirled.game.StateChangedEvent;

import popcraft.*;
import popcraft.battle.*;
import popcraft.data.*;
import popcraft.mp.*;
import popcraft.sp.*;

public class EndlessGameMode extends GameMode
{
    public static const HUMAN_TEAM_ID :int = 0;
    public static const FIRST_COMPUTER_TEAM_ID :int = 1;

    public function EndlessGameMode (level :EndlessLevelData, save :SavedEndlessGame,
        isNewGame :Boolean)
    {
        EndlessGameContext.level = level;
        _savedGame = save;
        _needsReset = isNewGame;
    }

    override protected function setup () :void
    {
        if (_needsReset) {
            EndlessGameContext.reset();
        }

        EndlessGameContext.gameMode = this;

        if (_savedGame != null) {
            // restore saved data if it exists
            EndlessGameContext.mapIndex = _savedGame.mapIndex;
            EndlessGameContext.score = _savedGame.score;
            EndlessGameContext.scoreMultiplier = _savedGame.multiplier;

        } else {
            // otherwise, move to the next map
            EndlessGameContext.mapIndex++;
        }

        _curMapData = EndlessGameContext.level.getMapData(EndlessGameContext.mapIndex);

        super.setup();

        var scoreView :ScoreView = new ScoreView();
        this.addObject(scoreView, GameContext.overlayLayer);
    }

    override protected function enter () :void
    {
        super.enter();

        if (_readyToStart) {
            return;
        }

        if (!AppContext.gameCtrl.isConnected()) {
            // if we're in standalone mode, start the game immediately
            this.startGame();
        } else if (GameContext.isSinglePlayerGame) {
            // if this is a singleplayer game, start the game immediately,
            // and tell the server we're playing the game so that coins can be awarded
            this.startGame();
            if (EndlessGameContext.isNewGame) {
                AppContext.gameCtrl.game.playerReady();
            }

        } else if (EndlessGameContext.isNewGame) {
            // if this is a new multiplayer game, start the game when the GAME_STARTED event
            // is received
            this.registerListener(AppContext.gameCtrl.game, StateChangedEvent.GAME_STARTED,
                function (...ignored) :void {
                    startGame();
                });

            // we're ready!
            AppContext.gameCtrl.game.playerReady();

        } else {
            // If we've moved to the next map in an existing multiplayer game, start the game
            // when all the players have arrived. Use the PlayerReadyMonitor for this purpose -
            // this is functionally the same thing as waiting for the GAME_STARTED event, as above,
            // but doesn't require us to end the current game
            EndlessGameContext.playerReadyMonitor.waitForAllPlayersReadyForCurRound(startGame);

            // we're ready
            EndlessGameContext.playerReadyMonitor.setLocalPlayerReadyForCurRound();
        }

        _readyToStart = true;
    }

    override protected function startGame () :void
    {
        super.startGame();

        // if this is not the first level, create a new multiplier drop object
        if (EndlessGameContext.mapIndex != 0) {
            this.createMultiplierDrop(false);
        }
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
        if (!_gameOver) {
            for (var ii :int = 0; ii < _liveComputers.length; ++ii) {
                var computerInfo :PlayerInfo = _liveComputers[ii];
                if (!computerInfo.isAlive) {
                    _liveComputers.splice(ii, 1);
                    ii--;

                    if (_liveComputers.length == 0) {
                        _lastLiveComputerLoc = computerInfo.baseLoc.loc;
                    }
                }
            }

            if (_liveComputers.length == 0) {
                this.switchMaps();
            }
        }
    }

    protected function killAllCreatures () :void
    {
        for each (var creature :CreatureUnit in GameContext.netObjects.getObjectsInGroup(CreatureUnit.GROUP_NAME)) {
            creature.die();
        }
    }

    protected function createMultiplierDrop (playSound :Boolean) :void
    {
        SpellDropFactory.createSpellDrop(Constants.SPELL_TYPE_MULTIPLIER,
            _curMapData.multiplierDropLoc, playSound);
    }

    protected function switchMaps () :void
    {
        // save data about our human players so that they can be resurrected
        // when the next round starts
        EndlessGameContext.savedHumanPlayers = [];
        for each (var playerInfo :PlayerInfo in GameContext.playerInfos) {
            if (playerInfo.teamId == HUMAN_TEAM_ID) {
                EndlessGameContext.savedHumanPlayers.push(playerInfo.saveData());
            }
        }

        // save the game (must be done after the human players are saved, above)
        if (_curMapData.isSavePoint) {
            AppContext.endlessLevelMgr.saveCurrentGame();
        }

        // move to the next map (see handleGameOver())
        _gameOver = true;
        _switchingMaps = true;
    }

    override protected function handleGameOver () :void
    {
        // if we're switching maps, don't show the game-over screen, just switch to a new
        // endless game mode
        if (_switchingMaps) {
            if (Constants.DEBUG_SKIP_LEVEL_INTRO) {
                AppContext.mainLoop.unwindToMode(
                    new EndlessGameMode(EndlessGameContext.level, null, false));
            } else {
                AppContext.mainLoop.pushMode(new EndlessLevelTransitionMode(_lastLiveComputerLoc));
            }

            // end-of-level trophies
            var mapIndex :int = EndlessGameContext.mapIndex;
            var numLevels :int = EndlessGameContext.level.mapSequence.length;
            if (GameContext.isSinglePlayerGame) {
                // get halfway through the levels
                if (mapIndex >= Trophies.ABECEDARIAN_MAP_INDEX) {
                    AppContext.awardTrophy(Trophies.ABECEDARIAN);
                }
                // get all the way through the levels
                for (var ii :int = 0; ii <= Trophies.ENDLESS_SP_COMPLETION_TROPHIES.length; ++ii) {
                    if (mapIndex + 1 >= (numLevels * (ii + 1))) {
                        AppContext.awardTrophy(Trophies.ENDLESS_SP_COMPLETION_TROPHIES[ii]);
                    }
                }

            } else {
                // complete any MP level
                AppContext.awardTrophy(Trophies.COLLABORATOR);
            }

        } else {
            AppContext.mainLoop.pushMode(
                new EndlessLevelSelectMode(EndlessLevelSelectMode.GAME_OVER_MODE));
        }

        GameContext.musicControls.fadeOut(FADE_OUT_TIME - 0.25);
        GameContext.sfxControls.fadeOut(FADE_OUT_TIME - 0.25);
    }

    override protected function applyCheatCode (keyCode :uint) :void
    {
        switch (keyCode) {
        case KeyboardCodes.M:
            this.spellDeliveredToPlayer(GameContext.localPlayerIndex,
                Constants.SPELL_TYPE_MULTIPLIER);
            break;

        case KeyboardCodes.SLASH:
            if (GameContext.isSinglePlayerGame) {
                AppContext.endlessLevelMgr.playSpLevel(null, true);
            }
            break;

        case KeyboardCodes.O:
            this.switchMaps();
            break;

        default:
            super.applyCheatCode(keyCode);
            break;
        }
    }

    override protected function resurrectPlayer (deadPlayerIndex :int) :int
    {
        var resurrectingPlayerIndex :int = super.resurrectPlayer(deadPlayerIndex);
        if (resurrectingPlayerIndex == GameContext.localPlayerIndex) {
            AppContext.awardTrophy(Trophies.REANIMATOR);
        }

        return resurrectingPlayerIndex;
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

    override public function workshopKilled (workshop :WorkshopUnit, killingPlayerIndex :int) :void
    {
        super.workshopKilled(workshop, killingPlayerIndex);

        if (killingPlayerIndex == GameContext.localPlayerIndex) {
            EndlessGameContext.incrementScore(EndlessGameContext.level.pointsPerOpponentKill);

            // award the Handicapper trophy if the local player killed an opponent who stole
            // a multiplier from the battlefield
            if (_playerGotMultiplier[workshop.owningPlayerIndex]) {
                AppContext.awardTrophy(Trophies.HANDICAPPER);
            }
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
                if (EndlessGameContext.scoreMultiplier >= 5) {
                    AppContext.awardTrophy(Trophies.MAX_X);
                }
            }

            // we keep track of this for the "Handicapper" trophy
            _playerGotMultiplier[playerIndex] = true;
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
        GameContext.localPlayerIndex = SeatingManager.localPlayerSeat;
        GameContext.playerInfos = [];

        var workshopData :UnitData = GameContext.gameData.units[Constants.UNIT_TYPE_WORKSHOP];
        var workshopHealth :Number = workshopData.maxHealth;

        // create PlayerInfos for the human players
        var numPlayers :int = SeatingManager.numExpectedPlayers;
        for (var playerIndex :int = 0; playerIndex < numPlayers; ++playerIndex) {

            var playerDisplayData :PlayerDisplayData = GameContext.gameData.getPlayerDisplayData(
                    EndlessGameContext.level.humanPlayerNames[playerIndex]);

            var baseLoc :BaseLocationData =
                _curMapData.humanBaseLocs.get(playerDisplayData.dataName);

            if (playerIndex == GameContext.localPlayerIndex) {
                GameContext.playerInfos.push(new LocalPlayerInfo(
                    playerIndex,
                    HUMAN_TEAM_ID,
                    baseLoc,
                    workshopHealth,
                    workshopHealth,
                    false,
                    1,
                    playerDisplayData.color,
                    playerDisplayData.displayName,
                    playerDisplayData.headshot));

            } else {
                GameContext.playerInfos.push(new PlayerInfo(
                    playerIndex,
                    HUMAN_TEAM_ID,
                    baseLoc,
                    workshopHealth,
                    workshopHealth,
                    false,
                    1,
                    playerDisplayData.color,
                    playerDisplayData.displayName,
                    playerDisplayData.headshot));
            }
        }

        _liveComputers = this.createComputerPlayers();

        // init all players players
        for each (var playerInfo :PlayerInfo in GameContext.playerInfos) {
            playerInfo.init();
        }

        var damageShieldHealth :Number = EndlessGameContext.level.multiplierDamageSoak;

        // restore data that was saved from the previous map (must be done after playerInfos
        // are init()'d)
        for (playerIndex = 0; playerIndex < EndlessGameContext.savedHumanPlayers.length;
            ++playerIndex) {

            var savedPlayer :SavedPlayerInfo = EndlessGameContext.savedHumanPlayers[playerIndex];
            var player :PlayerInfo = GameContext.playerInfos[playerIndex];
            player.restoreSavedPlayerInfo(savedPlayer, damageShieldHealth);
        }

        // restore data from the saved game, if it exists
        if (_savedGame != null) {
            GameContext.localPlayerInfo.restoreSavedGameData(_savedGame, damageShieldHealth);
        }

        _playerGotMultiplier = ArrayUtil.create(GameContext.numPlayers, false);
    }

    protected function createComputerPlayers () :Array
    {
        var mapCycleNumber :int = EndlessGameContext.mapCycleNumber;

        // the first computer index is 1 more than the number of human players in the game
        var playerIndex :int = SeatingManager.numExpectedPlayers;

        var newInfos :Array  = [];
        for each (var cpData :EndlessComputerPlayerData in _curMapData.computers) {
            var playerInfo :PlayerInfo = new EndlessComputerPlayerInfo(playerIndex, cpData,
                mapCycleNumber);

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
    protected var _needsReset :Boolean;
    protected var _switchingMaps :Boolean;
    protected var _savedGame :SavedEndlessGame;
    protected var _liveComputers :Array;
    protected var _lastLiveComputerLoc :Vector2 = new Vector2();
    protected var _readyToStart :Boolean;
    protected var _playerGotMultiplier :Array;

    protected var _playersCheckedIn :Array = [];
}

}
