package popcraft {

import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.audio.AudioManager;

import flash.display.Shape;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

public class GameOverMode extends AppMode
{
    public function GameOverMode (winningTeam :int)
    {
        _winningTeam = winningTeam;
    }

    override protected function setup () :void
    {
        var rect :Shape = new Shape();
        rect.graphics.beginFill(0xFFFFFF);
        rect.graphics.drawRect(0, 0, Constants.SCREEN_DIMS.x, Constants.SCREEN_DIMS.y);
        rect.graphics.endFill();

        this.modeSprite.addChild(rect);

        var winningPlayerNames :Array = [];
        for each (var playerInfo :PlayerInfo in GameContext.playerInfos) {
            if (!playerInfo.leftGame && playerInfo.teamId == _winningTeam) {
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
        text.textColor = 0;
        text.autoSize = TextFieldAutoSize.LEFT;
        text.selectable = false;
        text.multiline = true;
        text.defaultTextFormat.size = 24;
        text.scaleX = 3;
        text.scaleY = 3;
        text.width = Constants.SCREEN_DIMS.x - 30;
        text.text = gameOverText;

        text.x = (Constants.SCREEN_DIMS.x / 2) - (text.width / 2);
        text.y = (Constants.SCREEN_DIMS.y / 2) - (text.height / 2);

        this.modeSprite.addChild(text);
    }

    override protected function enter () :void
    {
        if (!_playedSound) {
            var localPlayerWon :Boolean = (GameContext.localPlayerInfo.teamId == _winningTeam);
            AudioManager.instance.playSoundNamed(localPlayerWon ? "sfx_wingame" : "sfx_losegame");
            _playedSound = true;
        }
    }

    protected var _winningTeam :int;
    protected var _playedSound :Boolean;

}

}
