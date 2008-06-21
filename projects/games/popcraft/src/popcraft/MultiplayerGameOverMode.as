package popcraft {

import com.threerings.flash.SimpleTextButton;
import com.threerings.util.ArrayUtil;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.audio.AudioManager;
import com.whirled.contrib.simplegame.resource.SwfResource;
import com.whirled.game.GameSubControl;

import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import popcraft.util.MoonCalculation;

public class MultiplayerGameOverMode extends AppMode
{
    public function MultiplayerGameOverMode (winningTeam :int)
    {
        _winningTeamId = winningTeam;
    }

    protected function updateStats () :void
    {
        var gameArrangement :int = MultiplayerConfig.computeTeamArrangement();
        GameContext.playerStats.mpGamesPlayed[gameArrangement] = 1;
        if (this.playerWon) {
            GameContext.playerStats.mpGamesWon[gameArrangement] = 1;
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
        if (AppContext.globalPlayerStats.totalGamesPlayed >= TrophyManager.JACK_NUMGAMES) {
            // awarded for completing 25 multiplayer games
            TrophyManager.awardTrophy(TrophyManager.TROPHY_JACK);
        }

        if (AppContext.globalPlayerStats.totalGamesPlayed >= TrophyManager.WEARDD_NUMGAMES) {
            // awarded for completing 100 multiplayer games
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

        if (MoonCalculation.isFullMoonToday) {
            // awarded for playing a multiplayer game on a full moon
            TrophyManager.awardTrophy(TrophyManager.TROPHY_BADMOONONTHERISE);
        }

        if (this.playerWon) {
            // awarded for winning a multiplayer game
            TrophyManager.awardTrophy(TrophyManager.TROPHY_BULLY);

            if (GameContext.localPlayerInfo.healthPercent == 1) {
                // awarded for winning a multiplayer game without taking any damage
                TrophyManager.awardTrophy(TrophyManager.TROPHY_FLAWLESS);
            }

            for (var playerSeat :int = 0; playerSeat < SeatingManager.numExpectedPlayers; ++playerSeat) {
                if (playerSeat != SeatingManager.localPlayerSeat && SeatingManager.getPlayerName(playerSeat) == "Professor Weardd") {
                    // awarded for winning a multiplayer game against another player whose Whirled name is "Professor Weardd"
                    TrophyManager.awardTrophy(TrophyManager.TROPHY_MALEFACTOR);
                    break;
                }
            }
        }
    }

    protected function get playerWon () :Boolean
    {
        return (GameContext.localPlayerInfo.teamId == _winningTeamId);
    }

    override protected function setup () :void
    {
        this.updateStats();
        this.awardTrophies();

        this.modeSprite.addChild(SwfResource.getSwfDisplayRoot("splash"));

        var winningPlayerNames :Array = [];
        for each (var playerInfo :PlayerInfo in GameContext.playerInfos) {
            if (!playerInfo.leftGame && playerInfo.teamId == _winningTeamId) {
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
                    gameOverText += ", ";
                }
            }
            gameOverText += " win the game!";
        }

        var text :TextField = new TextField();
        text.background = true;
        text.backgroundColor = 0;
        text.textColor = 0xFFFFFF;
        text.autoSize = TextFieldAutoSize.LEFT;
        text.selectable = false;
        text.multiline = true;
        text.defaultTextFormat.size = 24;
        text.scaleX = 3;
        text.scaleY = 3;
        text.width = Constants.SCREEN_SIZE.x - 30;
        text.text = gameOverText;

        text.x = (Constants.SCREEN_SIZE.x / 2) - (text.width / 2);
        text.y = (Constants.SCREEN_SIZE.y / 2) - (text.height / 2);

        this.modeSprite.addChild(text);

        _button = new SimpleTextButton("Play Again?");
        _button.x = (Constants.SCREEN_SIZE.x * 0.5) - (_button.width * 0.5);
        _button.y = 350;
        _button.addEventListener(MouseEvent.CLICK, handleButtonClicked);

        this.modeSprite.addChild(_button);

        // report scores
        if (SeatingManager.isLocalPlayerInControl) {
            var winners :Array = [];
            var losers :Array = [];
            for each (playerInfo in GameContext.playerInfos) {
                if (playerInfo.teamId == _winningTeamId) {
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
        if (!_playedSound) {
            var localPlayerWon :Boolean = (GameContext.localPlayerInfo.teamId == _winningTeamId);
            AudioManager.instance.playSoundNamed(localPlayerWon ? "sfx_wingame" : "sfx_losegame");
            _playedSound = true;
        }
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

    protected var _winningTeamId :int;
    protected var _playedSound :Boolean;
    protected var _button :SimpleButton;

}

}
