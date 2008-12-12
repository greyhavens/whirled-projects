package redrover.game.view {

import com.whirled.contrib.simplegame.AppMode;

import flash.display.Graphics;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFormatAlign;

import redrover.*;
import redrover.game.*;
import redrover.ui.UIBits;

public class GameOverMode extends AppMode
{
    public function GameOverMode ()
    {
        // draw dim background
        var g :Graphics = _modeSprite.graphics;
        g.beginFill(0, 0.6);
        g.drawRect(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);
        g.endFill();

        var bg :Sprite = UIBits.createFrame(640, 460);
        bg.x = (Constants.SCREEN_SIZE.x - bg.width) * 0.5;
        bg.y = ((Constants.SCREEN_SIZE.y - bg.height) * 0.5) + 10;
        _modeSprite.addChild(bg);

        var scoresText :String = "";
        for (var ii :int = 0; ii < GameContext.winningPlayers.length; ++ii) {
            if (ii > 0) {
                scoresText += "\n";
            }

            var player :Player = GameContext.winningPlayers[ii];
            scoresText += String(ii + 1) + ". " + player.playerName + " (" + player.score + ")";
        }

        var scorePanel :Sprite = UIBits.createTextPanel(scoresText, 1.5, 0, 0,
            TextFormatAlign.LEFT, 20, 10);
        scorePanel.x = (bg.width - scorePanel.width) * 0.5;
        scorePanel.y = (bg.height - scorePanel.height) * 0.5;
        bg.addChild(scorePanel);

        var winnersTf :TextField = UIBits.createTitleText("THE WINNERS!", 2);
        winnersTf.x = (bg.width - winnersTf.width) * 0.5;
        winnersTf.y = scorePanel.y - winnersTf.height - 40;
        bg.addChild(winnersTf);

        var tryAgainButton :SimpleButton = UIBits.createButton("Again!", 2);
        this.registerOneShotCallback(tryAgainButton, MouseEvent.CLICK,
            function (...ignored) :void {
                AppContext.mainLoop.unwindToMode(new GameMode(GameContext.levelData));
            });
        tryAgainButton.x = (bg.width - tryAgainButton.width) * 0.5;
        tryAgainButton.y = scorePanel.y + scorePanel.height + 40;
        bg.addChild(tryAgainButton);
    }

}

}
