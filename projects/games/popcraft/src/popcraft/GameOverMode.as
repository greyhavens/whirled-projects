package popcraft {

import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.audio.AudioManager;

import flash.display.Shape;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

public class GameOverMode extends AppMode
{
    public function GameOverMode (winningPlayer :PlayerInfo)
    {
        _winningPlayer = winningPlayer;
    }

    override protected function setup () :void
    {
        var rect :Shape = new Shape();
        rect.graphics.beginFill(0xFFFFFF);
        rect.graphics.drawRect(0, 0, Constants.SCREEN_DIMS.x, Constants.SCREEN_DIMS.y);
        rect.graphics.endFill();

        this.modeSprite.addChild(rect);

        var gameOverText :String;
        if (null == _winningPlayer) {
            gameOverText = "No winner!";
        } else {
            gameOverText = _winningPlayer.playerName + " is the winner!";
        }

        var text :TextField = new TextField();
        text.textColor = 0;
        text.autoSize = TextFieldAutoSize.LEFT;
        text.selectable = false;
        text.defaultTextFormat.size = 24;
        text.text = gameOverText;

        text.scaleX = 5;
        text.scaleY = 5;

        text.x = (Constants.SCREEN_DIMS.x / 2) - (text.width / 2);
        text.y = (Constants.SCREEN_DIMS.y / 2) - (text.height / 2);

        this.modeSprite.addChild(text);
    }

    override protected function enter () :void
    {
        if (!_playedSound) {
            var localPlayerWon :Boolean = _winningPlayer.playerId == GameContext.localPlayerId;
            AudioManager.instance.playSoundNamed(localPlayerWon ? "sfx_wingame" : "sfx_losegame");
            _playedSound = true;
        }
    }

    protected var _winningPlayer :PlayerInfo;
    protected var _playedSound :Boolean;

}

}
