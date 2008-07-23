package popcraft {

import com.threerings.util.ArrayUtil;
import com.whirled.contrib.simplegame.audio.AudioManager;
import com.whirled.game.GameSubControl;

import flash.display.DisplayObject;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.text.TextFormatAlign;

import popcraft.ui.UIBits;
import popcraft.util.MoonCalculation;

public class MultiplayerGameOverMode extends SplashScreenModeBase
{
    override protected function setup () :void
    {
        super.setup();

        this.updateStats();
        this.awardTrophies();

        var winningPlayerNames :Array = [];
        for each (var playerInfo :PlayerInfo in GameContext.playerInfos) {
            if (!playerInfo.leftGame && playerInfo.teamId == GameContext.winningTeamId) {
                winningPlayerNames.push(playerInfo.playerName);
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
        _button.addEventListener(MouseEvent.CLICK, handleButtonClicked);

        this.modeSprite.addChild(_button);

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

            AppContext.gameCtrl.game.endGameWithWinners(winners, losers, GameSubControl.CASCADING_PAYOUT);
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
        var someoneHasMorbidInfection :Boolean = ArrayUtil.contains(MultiplayerConfig.morbidInfections, true);
        GameContext.playerStats.hasMorbidInfection = someoneHasMorbidInfection;

        // combine local stats into global, and save
        AppContext.globalPlayerStats.combineWith(GameContext.playerStats);
        UserCookieManager.setNeedsUpdate();
    }

    protected function awardTrophies () :void
    {
        // award trophies for playing lots of multiplayer games
        var totalGamesPlayed :int = AppContext.globalPlayerStats.totalGamesPlayed;
        if (totalGamesPlayed >= TrophyManager.RALPH_NUMGAMES) {
            TrophyManager.awardTrophy(TrophyManager.TROPHY_RALPH);
        }
        if (totalGamesPlayed >= TrophyManager.JACK_NUMGAMES) {
            TrophyManager.awardTrophy(TrophyManager.TROPHY_JACK);
        }
        if (totalGamesPlayed >= TrophyManager.WEARDD_NUMGAMES) {
            TrophyManager.awardTrophy(TrophyManager.TROPHY_WEARDD);
        }

        if (AppContext.globalPlayerStats.hasMorbidInfection) {
            // awarded for playing a game with another player who has the Morbid Infection trophy
            TrophyManager.awardTrophy(TrophyManager.TROPHY_MORBIDINFECTION);
        }

        if (!TrophyManager.hasTrophy(TrophyManager.TROPHY_LIBERALARTS)) {
            if (ArrayUtil.indexIf(AppContext.globalPlayerStats.mpGamesPlayed,
                  function (gamesPlayed :int) :Boolean { return gamesPlayed < 1; }) < 0) {
                // awarded for playing one of each multiplayer game arrangement
                TrophyManager.awardTrophy(TrophyManager.TROPHY_LIBERALARTS);
            }
        }

        if (this.playerWon) {
            // awarded for winning a multiplayer game
            TrophyManager.awardTrophy(TrophyManager.TROPHY_BULLY);

            if (GameContext.localPlayerInfo.healthPercent == 1) {
                // awarded for winning a multiplayer game without taking any damage
                TrophyManager.awardTrophy(TrophyManager.TROPHY_FLAWLESS);
            } else if (GameContext.localPlayerInfo.healthPercent <= TrophyManager.CHEATDEATH_HEALTH_PERCENT) {
                // awarded for winning a multiplayer game with very low health
                TrophyManager.awardTrophy(TrophyManager.TROPHY_CHEATDEATH);
            }

            for (var playerSeat :int = 0; playerSeat < SeatingManager.numExpectedPlayers; ++playerSeat) {
                if (playerSeat != SeatingManager.localPlayerSeat && SeatingManager.getPlayerName(playerSeat) == "Professor Weardd") {
                    // awarded for winning a multiplayer game against another player whose Whirled name is "Professor Weardd"
                    TrophyManager.awardTrophy(TrophyManager.TROPHY_MALEDICTORIAN);
                    break;
                }
            }

            if (MoonCalculation.isFullMoonToday) {
                // awarded for winning a multiplayer game on a full moon
                TrophyManager.awardTrophy(TrophyManager.TROPHY_BADMOON);
            }
        }
    }

    protected function get playerWon () :Boolean
    {
        return (GameContext.localPlayerInfo.teamId == GameContext.winningTeamId);
    }

    protected function handleButtonClicked (...ignored) :void
    {
        _button.removeEventListener(MouseEvent.CLICK, handleButtonClicked);

        // we can only restart the game lobby if nobody has left the game
        // @TODO - change this if Whirled allows seated games that are missing players to
        // be restarted
        if (SeatingManager.allPlayersPresent) {
            AppContext.mainLoop.unwindToMode(new GameLobbyMode());
        } else {
            AppContext.mainLoop.unwindToMode(new MultiplayerFailureMode());
        }
    }

    protected var _playedSound :Boolean;
    protected var _button :SimpleButton;

}

}
