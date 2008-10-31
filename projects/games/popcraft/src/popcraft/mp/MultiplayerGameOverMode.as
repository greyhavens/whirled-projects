package popcraft.mp {

import com.threerings.util.ArrayUtil;
import com.whirled.contrib.simplegame.audio.AudioManager;
import com.whirled.game.GameSubControl;

import flash.display.DisplayObject;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.text.TextFormatAlign;

import popcraft.*;
import popcraft.ui.UIBits;
import popcraft.util.MoonCalculation;

public class MultiplayerGameOverMode extends MultiplayerDialog
{
    override protected function setup () :void
    {
        super.setup();

        this.updateStats();
        this.awardTrophies();

        var winningPlayerNames :Array = [];
        for each (var playerInfo :PlayerInfo in GameContext.playerInfos) {
            if (!playerInfo.leftGame && playerInfo.teamId == GameContext.winningTeamId) {
                winningPlayerNames.push(playerInfo.displayName);
            }
        }

        var gameOverText :String = ""
        if (winningPlayerNames.length == 0) {
            gameOverText = "No winner!";
        } else if (winningPlayerNames.length == 1) {
            gameOverText = String(winningPlayerNames[0]) + " wins the game!";
        } else {
            for (var i :int = 0; i < winningPlayerNames.length; ++i) {
                gameOverText += String(winningPlayerNames[i]);
                if (i < winningPlayerNames.length - 1) {
                    if (winningPlayerNames.length > 2) {
                        gameOverText += ",";
                    }
                    gameOverText += " ";
                    if (i == winningPlayerNames.length - 2) {
                        gameOverText += "and ";
                    }
                }
            }
            gameOverText += " win the game!";
        }

        var text :DisplayObject = UIBits.createTextPanel(
            gameOverText, 3,  650, 0, TextFormatAlign.CENTER, 20, 15);

        text.x = (Constants.SCREEN_SIZE.x - text.width) * 0.5;
        text.y = 30;

        this.modeSprite.addChild(text);

        _button = UIBits.createButton("Play Again?", 2);
        _button.x = (Constants.SCREEN_SIZE.x - _button.width) * 0.5;
        _button.y = text.y + text.height + 30;
        this.modeSprite.addChild(_button);
        this.registerOneShotCallback(_button, MouseEvent.CLICK, handleButtonClicked);

        // report scores
        if (SeatingManager.isLocalPlayerInControl) {
            var winners :Array = [];
            var losers :Array = [];
            for each (playerInfo in GameContext.playerInfos) {
                if (playerInfo.teamId == GameContext.winningTeamId) {
                    winners.push(playerInfo.whirledId);
                } else {
                    losers.push(playerInfo.whirledId);
                }
            }

            AppContext.gameCtrl.game.endGameWithWinners(winners, losers,
                GameSubControl.CASCADING_PAYOUT);
        }
    }

    override protected function enter () :void
    {
        super.enter();

        if (!_playedSound) {
            AudioManager.instance.playSoundNamed(this.playerWon ? "sfx_wingame" : "sfx_losegame");
            _playedSound = true;
        }
    }
    protected function updateStats () :void
    {
        var gameArrangement :int = MultiplayerConfig.computeTeamArrangement();
        GameContext.playerStats.mpGamesPlayed[gameArrangement] += 1;
        if (this.playerWon) {
            GameContext.playerStats.mpGamesWon[gameArrangement] += 1;
        }

        // viral trophy
        var someoneHasMorbidInfection :Boolean = ArrayUtil.contains(
            MultiplayerConfig.morbidInfections, true);
        GameContext.playerStats.hasMorbidInfection = someoneHasMorbidInfection;

        // combine local stats into global, and save
        AppContext.globalPlayerStats.combineWith(GameContext.playerStats);
        AppContext.userCookieMgr.needsUpdate();
    }

    protected function awardTrophies () :void
    {
        // award trophies for playing lots of multiplayer games
        var totalGamesPlayed :int = AppContext.globalPlayerStats.totalGamesPlayed;
        if (totalGamesPlayed >= Trophies.RALPH_NUMGAMES) {
            AppContext.awardTrophy(Trophies.RALPH);
        }
        if (totalGamesPlayed >= Trophies.JACK_NUMGAMES) {
            AppContext.awardTrophy(Trophies.JACK);
        }
        if (totalGamesPlayed >= Trophies.WEARDD_NUMGAMES) {
            AppContext.awardTrophy(Trophies.WEARDD);
        }

        if (AppContext.globalPlayerStats.hasMorbidInfection) {
            // awarded for playing a game with another player who has the Morbid Infection trophy
            AppContext.awardTrophy(Trophies.MORBIDINFECTION);
        }

        if (!AppContext.hasTrophy(Trophies.LIBERALARTS)) {
            if (ArrayUtil.indexIf(AppContext.globalPlayerStats.mpGamesPlayed,
                  function (gamesPlayed :int) :Boolean { return gamesPlayed < 1; }) < 0) {
                // awarded for playing one of each multiplayer game arrangement
                AppContext.awardTrophy(Trophies.LIBERALARTS);
            }
        }

        if (this.playerWon) {
            // awarded for winning a multiplayer game
            AppContext.awardTrophy(Trophies.BULLY);

            if (GameContext.localPlayerInfo.healthPercent == 1) {
                // awarded for winning a multiplayer game without taking any damage
                AppContext.awardTrophy(Trophies.FLAWLESS);
            } else if (GameContext.localPlayerInfo.healthPercent <= Trophies.CHEATDEATH_HEALTH_PERCENT) {
                // awarded for winning a multiplayer game with very low health
                AppContext.awardTrophy(Trophies.CHEATDEATH);
            }

            for each (var playerInfo :PlayerInfo in GameContext.playerInfos) {
                if (playerInfo.teamId != GameContext.localPlayerInfo.teamId &&
                    playerInfo.displayName == Trophies.MALEDICTORIAN_NAME) {
                    // awarded for winning a multiplayer game against another player whose
                    // Whirled name is "Professor Weardd"
                    AppContext.awardTrophy(Trophies.MALEDICTORIAN);
                }
            }

            if (MoonCalculation.isFullMoonToday) {
                // awarded for winning a multiplayer game on a full moon
                AppContext.awardTrophy(Trophies.BADMOON);
            }
        }
    }

    protected function get playerWon () :Boolean
    {
        return (GameContext.localPlayerInfo.teamId == GameContext.winningTeamId);
    }

    protected function handleButtonClicked (...ignored) :void
    {
        // we can only restart the game lobby if nobody has left the game
        // @TODO - change this if Whirled allows seated games that are missing players to
        // be restarted
        if (SeatingManager.allPlayersPresent) {
            AppContext.mainLoop.unwindToMode(new MultiplayerLobbyMode());
        } else {
            AppContext.mainLoop.unwindToMode(new MultiplayerFailureMode());
        }
    }

    protected var _playedSound :Boolean;
    protected var _button :SimpleButton;

}

}
