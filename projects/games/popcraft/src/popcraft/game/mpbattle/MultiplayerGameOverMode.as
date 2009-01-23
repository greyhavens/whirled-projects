package popcraft.game.mpbattle {

import com.threerings.flash.DisplayUtil;
import com.threerings.util.ArrayUtil;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.audio.AudioManager;
import com.whirled.contrib.simplegame.resource.ImageResource;
import com.whirled.game.GameSubControl;

import flash.display.DisplayObject;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFormatAlign;

import popcraft.*;
import popcraft.game.*;
import popcraft.ui.UIBits;
import popcraft.util.MoonCalculation;

public class MultiplayerGameOverMode extends AppMode
{
    override protected function setup () :void
    {
        updateStats();
        awardTrophies();

        // report scores
        if (ClientContext.seatingMgr.isLocalPlayerInControl) {
            var winners :Array = [];
            var losers :Array = [];
            for each (playerInfo in GameContext.playerInfos) {
                if (playerInfo.teamId == GameContext.winningTeamId) {
                    winners.push(playerInfo.whirledId);
                } else {
                    losers.push(playerInfo.whirledId);
                }
            }

            ClientContext.gameCtrl.game.endGameWithWinners(winners, losers,
                GameSubControl.CASCADING_PAYOUT);
        }

        // background
        _modeSprite.addChild(ImageResource.instantiateBitmap("zombieBg"));

        var windowElements :Sprite = new Sprite();

        // win/lose text
        var tfOutcome :TextField = UIBits.createTitleText(this.playerWon ? "Victory!" : "Defeated");
        tfOutcome.x = -(tfOutcome.width * 0.5);
        tfOutcome.y = 0;
        windowElements.addChild(tfOutcome);

        // Winning player names
        var winningPlayerNames :Array = [];
        for each (var playerInfo :PlayerInfo in GameContext.playerInfos) {
            if (!playerInfo.leftGame && playerInfo.teamId == GameContext.winningTeamId) {
                winningPlayerNames.push(playerInfo.displayName);
            }
        }

        var winnersText :String = ""
        if (winningPlayerNames.length == 0) {
            winnersText = "No winner!";
        } else if (winningPlayerNames.length == 1) {
            winnersText = String(winningPlayerNames[0]) + " wins the game!";
        } else {
            for (var i :int = 0; i < winningPlayerNames.length; ++i) {
                winnersText += String(winningPlayerNames[i]);
                if (i < winningPlayerNames.length - 1) {
                    if (winningPlayerNames.length > 2) {
                        winnersText += ",";
                    }
                    winnersText += " ";
                    if (i == winningPlayerNames.length - 2) {
                        winnersText += "and ";
                    }
                }
            }
            winnersText += " win the game!";
        }

        var tfWinners :DisplayObject =
            UIBits.createText(winnersText, 1.5, WIDTH - 30, 0, TextFormatAlign.LEFT);
        tfWinners.x =  -(tfWinners.width * 0.5);
        tfWinners.y = windowElements.height + 10;
        windowElements.addChild(tfWinners);

        var playAgain :SimpleButton = UIBits.createButton("Play Again?", 2);
        playAgain.x = -(playAgain.width * 0.5);
        playAgain.y = windowElements.height + 20;
        windowElements.addChild(playAgain);
        registerOneShotCallback(playAgain, MouseEvent.CLICK,
            function (...ignored) :void {
                // we can only restart the game lobby if nobody has left the game
                // @TODO - change this if Whirled allows seated games that are missing players to
                // be restarted
                if (ClientContext.seatingMgr.allPlayersPresent) {
                    ClientContext.mainLoop.unwindToMode(new MultiplayerLobbyMode());
                } else {
                    ClientContext.mainLoop.unwindToMode(new MultiplayerFailureMode());
                }
            });

        var frame :Sprite = UIBits.createFrame(WIDTH, windowElements.height + (V_BORDER * 2));
        frame.x = (Constants.SCREEN_SIZE.x - WIDTH) * 0.5;
        frame.y = (Constants.SCREEN_SIZE.y - frame.height) * 0.5;
        _modeSprite.addChild(frame);

        windowElements.x = Constants.SCREEN_SIZE.x * 0.5;
        windowElements.y = (Constants.SCREEN_SIZE.y - windowElements.height) * 0.5;
        _modeSprite.addChild(windowElements);
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
        var gameArrangement :int = ClientContext.lobbyConfig.computeTeamArrangement();
        GameContext.playerStats.mpGamesPlayed[gameArrangement] += 1;
        if (this.playerWon) {
            GameContext.playerStats.mpGamesWon[gameArrangement] += 1;
        }

        // viral trophy
        var someoneHasMorbidInfection :Boolean = ArrayUtil.contains(
            ClientContext.lobbyConfig.morbidInfections, true);
        GameContext.playerStats.hasMorbidInfection = someoneHasMorbidInfection;

        // combine local stats into global, and save
        ClientContext.globalPlayerStats.combineWith(GameContext.playerStats);
        ClientContext.userCookieMgr.needsUpdate();
    }

    protected function awardTrophies () :void
    {
        // award trophies for playing lots of multiplayer games
        var totalGamesPlayed :int = ClientContext.globalPlayerStats.totalGamesPlayed;
        if (totalGamesPlayed >= Trophies.RALPH_NUMGAMES) {
            ClientContext.awardTrophy(Trophies.RALPH);
        }
        if (totalGamesPlayed >= Trophies.JACK_NUMGAMES) {
            ClientContext.awardTrophy(Trophies.JACK);
        }
        if (totalGamesPlayed >= Trophies.WEARDD_NUMGAMES) {
            ClientContext.awardTrophy(Trophies.WEARDD);
        }

        if (ClientContext.globalPlayerStats.hasMorbidInfection) {
            // awarded for playing a game with another player who has the Morbid Infection trophy
            ClientContext.awardTrophy(Trophies.MORBIDINFECTION);
        }

        if (!ClientContext.hasTrophy(Trophies.LIBERALARTS)) {
            if (ArrayUtil.indexIf(ClientContext.globalPlayerStats.mpGamesPlayed,
                  function (gamesPlayed :int) :Boolean { return gamesPlayed < 1; }) < 0) {
                // awarded for playing one of each multiplayer game arrangement
                ClientContext.awardTrophy(Trophies.LIBERALARTS);
            }
        }

        if (this.playerWon) {
            // awarded for winning a multiplayer game
            ClientContext.awardTrophy(Trophies.BULLY);

            if (GameContext.localPlayerInfo.healthPercent == 1) {
                // awarded for winning a multiplayer game without taking any damage
                ClientContext.awardTrophy(Trophies.FLAWLESS);
            } else if (GameContext.localPlayerInfo.healthPercent <= Trophies.CHEATDEATH_HEALTH_PERCENT) {
                // awarded for winning a multiplayer game with very low health
                ClientContext.awardTrophy(Trophies.CHEATDEATH);
            }

            for each (var playerInfo :PlayerInfo in GameContext.playerInfos) {
                if (playerInfo.teamId != GameContext.localPlayerInfo.teamId &&
                    playerInfo.displayName == Trophies.MALEDICTORIAN_NAME) {
                    // awarded for winning a multiplayer game against another player whose
                    // Whirled name is "Professor Weardd"
                    ClientContext.awardTrophy(Trophies.MALEDICTORIAN);
                }
            }

            if (MoonCalculation.isFullMoonToday) {
                // awarded for winning a multiplayer game on a full moon
                ClientContext.awardTrophy(Trophies.BADMOON);
            }
        }
    }

    protected function get playerWon () :Boolean
    {
        return (GameContext.localPlayerInfo.teamId == GameContext.winningTeamId);
    }

    protected var _playedSound :Boolean;

    protected static const WIDTH :Number = 320;
    protected static const V_BORDER :Number = 20;
}

}
