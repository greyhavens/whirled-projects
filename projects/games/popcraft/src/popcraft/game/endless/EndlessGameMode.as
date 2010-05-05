//
// $Id$

package popcraft.game.endless {

import com.threerings.geom.Vector2;
import com.threerings.util.ArrayUtil;
import com.threerings.ui.KeyboardCodes;
import com.threerings.flashbang.*;
import popcraft.net.messagemgr.*;
import com.whirled.game.StateChangedEvent;

import flash.display.DisplayObject;

import popcraft.*;
import popcraft.game.battle.*;
import popcraft.game.battle.view.SpellDropView;
import popcraft.data.*;
import popcraft.game.*;
import popcraft.game.mpbattle.*;
import popcraft.net.PlayerScoreMsg;

public class EndlessGameMode extends GameMode
{
    public static const HUMAN_TEAM_ID :int = 0;
    public static const FIRST_COMPUTER_TEAM_ID :int = 1;

    public function EndlessGameMode (isMultiplayer :Boolean, level :EndlessLevelData, saves :Array,
        isNewGame :Boolean)
    {
        EndlessGameContext.level = level;
        _playerSaves = saves;
        _needsReset = isNewGame;
        _isMultiplayer = isMultiplayer;
    }

    override protected function setup () :void
    {
        if (_needsReset) {
            EndlessGameContext.resetGameData();
        } else {
            EndlessGameContext.resetLevelData();
            EndlessGameContext.roundId += 1;
        }

        EndlessGameContext.gameMode = this;

        if (_playerSaves != null) {
            // all saved games will point to the same mapIndex
            var save :SavedEndlessGame = _playerSaves[0];

            // restore saved data if it exists
            EndlessGameContext.mapIndex = save.mapIndex;
            EndlessGameContext.resourceScore = save.resourceScore;
            EndlessGameContext.damageScore = save.damageScore;
            EndlessGameContext.scoreMultiplier = save.multiplier;

        } else {
            // otherwise, move to the next map
            EndlessGameContext.mapIndex++;
        }

        _curMapData = EndlessGameContext.level.getMapData(EndlessGameContext.mapIndex);

        super.setup();

        // if this is not the first level, create a new multiplier drop object
        if (EndlessGameContext.mapIndex != 0) {
            var multiplierView :SpellDropView = createMultiplierDrop(false);
            // hide the multiplier until the mode is entered for the first time,
            // to allow the interstitial movie to play
            multiplierView.visible = false;
            _unhideMultiplierOnEnter = multiplierView.ref;
        }

        var scoreView :ScoreView = new ScoreView();
        addSceneObject(scoreView, GameCtx.overlayLayer);
    }

    override protected function enter () :void
    {
        super.enter();

        if (_unhideMultiplierOnEnter != null) {
            var spellDropView :SpellDropView = _unhideMultiplierOnEnter.object as SpellDropView;
            if (spellDropView != null) {
                spellDropView.visible = true;
            }

            _unhideMultiplierOnEnter = null;
        }

        if (_readyToStart) {
            return;
        }

        if (!ClientCtx.gameCtrl.isConnected()) {
            // we're in standalone mode; start the game immediately
            startGame();

        } else if (GameCtx.isSinglePlayerGame) {
            // this is a singleplayer game; start the game immediately,
            // and tell the server we're playing the game so that coins can be awarded
            ClientCtx.gameCtrl.game.playerReady();
            startGame();

        } else {
            // this is a multiplayer game; start the game when the GAME_STARTED event
            // is received
            registerListener(ClientCtx.gameCtrl.game, StateChangedEvent.GAME_STARTED,
                function (...ignored) :void {
                    startGame();
                });

            // we're ready!
            ClientCtx.gameCtrl.game.playerReady();

        }

        _readyToStart = true;
    }

    override protected function updateNetworkedObjects () :void
    {
        super.updateNetworkedObjects();

        // sync the local player's workshop damage shield count to their score multiplier
        var localPlayerWorkshop :WorkshopUnit = GameCtx.localPlayerInfo.workshop;
        var multiplier :int =
            (localPlayerWorkshop != null ? localPlayerWorkshop.damageShields.length + 1 : 1);
        EndlessGameContext.scoreMultiplier = multiplier;

        checkForComputerDeath();
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
                switchMaps();
            }
        }
    }

    protected function killAllCreatures () :void
    {
        for each (var creature :CreatureUnit in GameCtx.netObjects.getObjectsInGroup(CreatureUnit.GROUP_NAME)) {
            creature.die();
        }
    }

    protected function createMultiplierDrop (playSound :Boolean) :SpellDropView
    {
        return SpellDropFactory.createSpellDrop(Constants.SPELL_TYPE_MULTIPLIER,
            _curMapData.multiplierDropLoc, playSound);
    }

    protected function switchMaps () :void
    {
        // save data about our human players so that they can be resurrected
        // when the next round starts
        EndlessGameContext.savedHumanPlayers = [];
        for each (var playerInfo :PlayerInfo in GameCtx.playerInfos) {
            if (playerInfo.teamId == HUMAN_TEAM_ID) {
                EndlessGameContext.savedHumanPlayers.push(playerInfo.saveData());
            }
        }

        // save the game (must be done after the human players are saved, above)
        if (_curMapData.isSavePoint) {
            ClientCtx.endlessLevelMgr.saveCurrentGame();
        }

        // move to the next map (see handleGameOver())
        _gameOver = true;
        _switchingMaps = true;
    }

    override protected function handleGameOver () :void
    {
        var audioFadeOutTime :Number = 0;
        var nextMode :AppMode;

        // if we're switching maps, don't show the game-over screen, just switch to a new
        // endless game mode
        if (_switchingMaps) {
            if (Constants.DEBUG_SKIP_LEVEL_INTRO) {
                ClientCtx.mainLoop.unwindToMode(
                    new EndlessGameMode(_isMultiplayer, EndlessGameContext.level, null, false));
                return;
            }

            audioFadeOutTime = SWITCH_MAP_AUDIO_FADE_TIME;
            nextMode = new EndlessInterstitialMode(_lastLiveComputerLoc);

            // end-of-level trophies
            var mapIndex :int = EndlessGameContext.mapIndex;
            var numLevels :int = EndlessGameContext.level.mapSequence.length;
            // get halfway through the levels
            if (mapIndex >= Trophies.ABECEDARIAN_MAP_INDEX) {
                ClientCtx.awardTrophy(Trophies.ABECEDARIAN);
            }
            // get all the way through the levels
            for (var ii :int = 0; ii < Trophies.ENDLESS_COMPLETION_TROPHIES.length; ++ii) {
                if (mapIndex + 1 >= (numLevels * (ii + 1))) {
                    ClientCtx.awardTrophy(Trophies.ENDLESS_COMPLETION_TROPHIES[ii]);
                }
            }

            if (GameCtx.isMultiplayerGame && mapIndex >= Trophies.COLLABORATOR_MP_MAP_INDEX) {
                // complete MP level 9
                ClientCtx.awardTrophy(Trophies.COLLABORATOR);
            }

        } else {
            audioFadeOutTime = GAME_OVER_AUDIO_FADE_TIME;

            if (GameCtx.isSinglePlayerGame) {
                nextMode = new SpEndlessGameOverMode();
            } else {
                // send our new saved games to everyone, in case the game is restarted.
                EndlessMultiplayerConfig.setPlayerSavedGames(
                    ClientCtx.seatingMgr.localPlayerSeat, ClientCtx.endlessLevelMgr.savedMpGames);

                nextMode = new MpEndlessGameOverMode();
            }
        }

        if (GameCtx.isMultiplayerGame) {
            // In a multiplayer game, wait for everyone to report their scores so that the next mode
            // can call endGameWithScores
            EndlessGameContext.playerMonitor.reportScore(PlayerScoreMsg.create(
                    GameCtx.localPlayerIndex,
                    EndlessGameContext.resourceScore,
                    EndlessGameContext.damageScore,
                    EndlessGameContext.resourceScoreThisRound,
                    EndlessGameContext.damageScoreThisRound,
                    EndlessGameContext.roundId));

            EndlessGameContext.playerMonitor.waitForScores(
                function () :void {
                    ClientCtx.mainLoop.pushMode(nextMode);
                },
                EndlessGameContext.roundId);

        } else {
            // otherwise, just move to the next mode immediately
            ClientCtx.mainLoop.pushMode(nextMode);
        }

        GameCtx.musicControls.fadeOut(audioFadeOutTime);
        GameCtx.sfxControls.fadeOut(audioFadeOutTime);
    }

    override protected function applyCheatCode (keyCode :uint) :void
    {
        switch (keyCode) {
        case KeyboardCodes.M:
            spellDeliveredToPlayer(GameCtx.localPlayerIndex,
                Constants.SPELL_TYPE_MULTIPLIER);
            break;

        case KeyboardCodes.SLASH:
            if (GameCtx.isSinglePlayerGame) {
                ClientCtx.endlessLevelMgr.playSpLevel(null, true);
            }
            break;

        case KeyboardCodes.O:
            switchMaps();
            break;

        default:
            super.applyCheatCode(keyCode);
            break;
        }
    }

    override protected function resurrectPlayer (deadPlayerIndex :int) :int
    {
        var resurrectingPlayerIndex :int = super.resurrectPlayer(deadPlayerIndex);
        if (resurrectingPlayerIndex == GameCtx.localPlayerIndex) {
            ClientCtx.awardTrophy(Trophies.REANIMATOR);
        }

        return resurrectingPlayerIndex;
    }

    override public function playerEarnedResources (resourceType :int, offset :int,
        numClearPieces :int) :int
    {
        var actualResourcesEarned :int =
            super.playerEarnedResources(resourceType, offset, numClearPieces);

        EndlessGameContext.incrementResourceScore(
            actualResourcesEarned * GameCtx.gameData.scoreData.pointsPerResource);

        return actualResourcesEarned;
    }

    override public function creatureKilled (creature :CreatureUnit, killingPlayerIndex :int) :void
    {
        super.creatureKilled(creature, killingPlayerIndex);

        if (killingPlayerIndex == GameCtx.localPlayerIndex) {
            EndlessGameContext.incrementDamageScore(
                GameCtx.gameData.scoreData.pointsPerCreatureKill[creature.unitType]);
        }
    }

    override public function workshopKilled (workshop :WorkshopUnit, killingPlayerIndex :int) :void
    {
        super.workshopKilled(workshop, killingPlayerIndex);

        if (killingPlayerIndex == GameCtx.localPlayerIndex) {
            EndlessGameContext.incrementDamageScore(
                GameCtx.gameData.scoreData.pointsPerOpponentKill);

            // award the Handicapper trophy if the local player killed an opponent who stole
            // a multiplier from the battlefield
            if (_playerGotMultiplier[workshop.owningPlayerIndex]) {
                ClientCtx.awardTrophy(Trophies.HANDICAPPER);
            }
        }
    }

    override public function spellDeliveredToPlayer (playerIndex :int, spellType :int) :void
    {
        super.spellDeliveredToPlayer(playerIndex, spellType);

        // multiplier spells increase the player's score multiplier, and also add little damage
        // shields to his workshop
        if (spellType == Constants.SPELL_TYPE_MULTIPLIER) {
            var workshop :WorkshopUnit = PlayerInfo(GameCtx.playerInfos[playerIndex]).workshop;
            if (workshop != null &&
                workshop.damageShields.length < GameCtx.gameData.maxMultiplier) {

                workshop.addDamageShield(GameCtx.gameData.multiplierDamageSoak);
            }

            if (playerIndex == GameCtx.localPlayerIndex) {
                EndlessGameContext.incrementMultiplier();
                if (EndlessGameContext.scoreMultiplier >= 5) {
                    ClientCtx.awardTrophy(Trophies.MAX_X);
                }
            }

            // we keep track of this for the "Handicapper" trophy
            _playerGotMultiplier[playerIndex] = true;
        }
    }

    override public function get canPause () :Boolean
    {
        return GameCtx.isSinglePlayerGame;
    }

    override public function isAvailableUnit (unitType :int) :Boolean
    {
        return ArrayUtil.contains(_localHumanPlayerData.availableUnits, unitType);
    }

    override public function get availableSpells () :Array
    {
        return _localHumanPlayerData.availableSpells;
    }

    override public function get mapSettings () :MapSettingsData
    {
        return _curMapData.mapSettings;
    }

    override protected function createPlayers () :void
    {
        GameCtx.localPlayerIndex =
            (GameCtx.isMultiplayerGame ? ClientCtx.seatingMgr.localPlayerSeat : 0);
        GameCtx.playerInfos = [];

        var workshopData :UnitData = GameCtx.gameData.units[Constants.UNIT_TYPE_WORKSHOP];
        var workshopHealth :Number = workshopData.maxHealth;

        // create PlayerInfos for the human players
        for (var playerIndex :int = 0; playerIndex < this.numHumanPlayers; ++playerIndex) {
            var playerName :String = EndlessGameContext.level.humanPlayerNames[playerIndex];
            var playerDisplayData :PlayerDisplayData =
                GameCtx.gameData.getPlayerDisplayData(playerName);

            var humanPlayerData :EndlessHumanPlayerData =
                _curMapData.humans.get(playerDisplayData.playerName);

            var color :uint;
            var displayName :String;
            var headshot :DisplayObject;
            if (GameCtx.isSinglePlayerGame) {
                color = playerDisplayData.color;
                displayName = playerDisplayData.displayName;
                headshot = playerDisplayData.headshot;
            } else {
                color = ClientCtx.lobbyConfig.getPlayerColor(playerIndex);
                if (color == Constants.RANDOM_COLOR) {
                    color = playerDisplayData.color;
                }
                displayName = ClientCtx.seatingMgr.getPlayerName(playerIndex);
                var headshotName :String = ClientCtx.lobbyConfig.getPlayerPortraitName(playerIndex);
                if (headshotName == Constants.DEFAULT_PORTRAIT) {
                    headshot = ClientCtx.seatingMgr.getPlayerHeadshot(playerIndex, true);
                } else {
                    headshot = ClientCtx.instantiateBitmap(headshotName);
                }
            }

            if (playerIndex == GameCtx.localPlayerIndex) {
                GameCtx.playerInfos.push(new LocalPlayerInfo(
                    playerIndex,
                    HUMAN_TEAM_ID,
                    humanPlayerData.baseLoc,
                    workshopHealth,
                    workshopHealth,
                    false,
                    humanPlayerData.resourceHandicap,
                    color,
                    playerName,
                    displayName,
                    headshot));

                _localHumanPlayerData = humanPlayerData;

            } else {
                GameCtx.playerInfos.push(new PlayerInfo(
                    playerIndex,
                    HUMAN_TEAM_ID,
                    humanPlayerData.baseLoc,
                    workshopHealth,
                    workshopHealth,
                    false,
                    humanPlayerData.resourceHandicap,
                    color,
                    playerName,
                    displayName,
                    headshot));
            }
        }

        _liveComputers = createComputerPlayers();

        var playerInfo :PlayerInfo;

        var damageShieldHealth :Number = GameCtx.gameData.multiplierDamageSoak;

        // restore data that was saved from the previous map (must be done after playerInfos
        // are init()'d)
        for (playerIndex = 0; playerIndex < EndlessGameContext.savedHumanPlayers.length;
            ++playerIndex) {

            var savedPlayer :SavedPlayerInfo = EndlessGameContext.savedHumanPlayers[playerIndex];
            playerInfo = GameCtx.playerInfos[playerIndex];
            playerInfo.restoreSavedPlayerInfo(savedPlayer, damageShieldHealth);
        }

        // restore data from the saved games, if they exist
        if (_playerSaves != null) {
            for (playerIndex = 0; playerIndex < _playerSaves.length; ++playerIndex) {
                var save :SavedEndlessGame = _playerSaves[playerIndex];
                playerInfo = GameCtx.playerInfos[playerIndex];
                playerInfo.restoreSavedGameData(save, damageShieldHealth);
            }
        }

        // init all players (creates Workshop units)
        for each (playerInfo in GameCtx.playerInfos) {
            playerInfo.init();
        }

        _playerGotMultiplier = ArrayUtil.create(GameCtx.numPlayers, false);
    }

    protected function createComputerPlayers () :Array
    {
        var mapCycleNumber :int = EndlessGameContext.mapCycleNumber;

        // the first computer index is 1 more than the number of human players in the game
        var playerIndex :int = this.numHumanPlayers;

        var newInfos :Array  = [];
        for each (var cpData :EndlessComputerPlayerData in _curMapData.computers) {
            var playerInfo :PlayerInfo = new EndlessComputerPlayerInfo(playerIndex, cpData,
                mapCycleNumber);

            GameCtx.playerInfos.push(playerInfo);
            newInfos.push(playerInfo);

            ++playerIndex;
        }

        return newInfos;
    }

    protected function get numHumanPlayers () :int
    {
        return (GameCtx.isMultiplayerGame ? ClientCtx.seatingMgr.numExpectedPlayers : 1);
    }

    override protected function createRandSeed () :uint
    {
        if (GameCtx.isSinglePlayerGame) {
            return uint(Math.random() * uint.MAX_VALUE);
        } else {
            return ClientCtx.lobbyConfig.randSeed;
        }
    }

    override protected function createMessageManager () :TickedMessageManager
    {
        if (GameCtx.isSinglePlayerGame) {
            return new OfflineTickedMessageManager(ClientCtx.gameCtrl, TICK_INTERVAL_MS);
        } else {
            return new OnlineTickedMessageManager(ClientCtx.gameCtrl,
                ClientCtx.seatingMgr.isLocalPlayerInControl, TICK_INTERVAL_MS);
        }
    }

    override protected function get gameType () :int
    {
        return (_isMultiplayer ? GameCtx.GAME_TYPE_ENDLESS_MP :
                GameCtx.GAME_TYPE_ENDLESS_SP);
    }

    override protected function get gameData () :GameData
    {
        return (_curMapData.gameDataOverride != null ? _curMapData.gameDataOverride :
                ClientCtx.defaultGameData);
    }

    protected var _curMapData :EndlessMapData;
    protected var _localHumanPlayerData :EndlessHumanPlayerData;
    protected var _needsReset :Boolean;
    protected var _isMultiplayer :Boolean;
    protected var _switchingMaps :Boolean;
    protected var _playerSaves :Array;
    protected var _liveComputers :Array;
    protected var _lastLiveComputerLoc :Vector2 = new Vector2();
    protected var _readyToStart :Boolean;
    protected var _playerGotMultiplier :Array;

    protected var _unhideMultiplierOnEnter :GameObjectRef;

    protected var _playersCheckedIn :Array = [];

    protected static const SWITCH_MAP_AUDIO_FADE_TIME :Number = 2.5;
    protected static const GAME_OVER_AUDIO_FADE_TIME :Number = 2.75;
}

}
