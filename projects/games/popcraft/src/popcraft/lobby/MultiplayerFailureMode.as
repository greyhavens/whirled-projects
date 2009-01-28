package popcraft.lobby {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.audio.*;

import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;

import popcraft.*;
import popcraft.game.story.LevelSelectMode;
import popcraft.ui.UIBits;

public class MultiplayerFailureMode extends TransitionMode
{
    override protected function setup () :void
    {
        super.setup();

        _modeLayer.addChild(ClientCtx.instantiateBitmap("zombieBg"));
        _soundChannel = ClientCtx.audio.playSoundNamed("sfx_introscreen", null, -1);

        var windowElements :Sprite = new Sprite();

        var tfOutcome :TextField = UIBits.createTitleText("Your classmates have fled!");
        tfOutcome.x = -(tfOutcome.width * 0.5);
        tfOutcome.y = 0;
        windowElements.addChild(tfOutcome);

        var playAgain :SimpleButton = UIBits.createButton("Gather Another Game", 2.5, 300);
        playAgain.x = -(playAgain.width * 0.5);
        playAgain.y = windowElements.height + 20;
        windowElements.addChild(playAgain);
        registerOneShotCallback(playAgain, MouseEvent.CLICK,
            function (...ignored) :void {
                ClientCtx.showMultiplayerLobby();
            });

        var singlePlayerButton :SimpleButton = UIBits.createButton("Play Alone", 1.5, 300);
        singlePlayerButton.x = -(singlePlayerButton.width * 0.5);
        singlePlayerButton.y = windowElements.height + 20;
        windowElements.addChild(singlePlayerButton);
        registerOneShotCallback(singlePlayerButton, MouseEvent.CLICK,
            function (...ignored) :void {
                Resources.loadLevelPackResources(Resources.SP_LEVEL_PACK_RESOURCES,
                                                 LevelSelectMode.create);
            });

        var frame :Sprite = UIBits.createFrame(WIDTH, HEIGHT);
        frame.x = (Constants.SCREEN_SIZE.x - WIDTH) * 0.5;
        frame.y = (Constants.SCREEN_SIZE.y - frame.height) * 0.5;
        _modeLayer.addChild(frame);

        windowElements.x = Constants.SCREEN_SIZE.x * 0.5;
        windowElements.y = (Constants.SCREEN_SIZE.y - windowElements.height) * 0.5;
        _modeLayer.addChild(windowElements);
    }

    override protected function destroy () :void
    {
        _soundChannel.audioControls.fadeOut(0.5).stopAfter(0.5);
        super.destroy();
    }

    protected var _soundChannel :AudioChannel;

    protected static const WIDTH :Number = 370;
    protected static const HEIGHT :Number = 250;
}

}
