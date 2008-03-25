package popcraft {

import com.whirled.contrib.simplegame.AppMode;
import flash.display.Shape;
import flash.text.TextField;

public class GameOverMode extends AppMode
{
    public function GameOverMode (winningPlayer :int)
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
        if (_winningPlayer < 0) {
            gameOverText = "No winner!";
        } else {
            gameOverText = "Player " + _winningPlayer + " is the winner!";
        }

        var text :TextField = new TextField();
        text.textColor = 0;
        text.defaultTextFormat.size = 24;
        text.text = gameOverText;
        text.width = text.textWidth + 3;
        text.height = text.textHeight + 3;

        text.x = (Constants.SCREEN_DIMS.x / 2) - (text.width / 2);
        text.y = (Constants.SCREEN_DIMS.y / 2) - (text.height / 2);

        this.modeSprite.addChild(text);
    }

    protected var _winningPlayer :int;

}

}
