package popcraft.lobby {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.audio.*;

import flash.display.DisplayObject;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.text.TextFormatAlign;

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

        var tf :DisplayObject = UIBits.createTextPanel(
            "Your classmates have fled!",
            3, 0, 0, TextFormatAlign.CENTER, 20, 15);

        tf.x = (Constants.SCREEN_SIZE.x - tf.width) * 0.5;
        tf.y = 30;
        _modeLayer.addChild(tf);

        var gatherButton :SimpleButton = UIBits.createButton("Gather Another Game", 3);
        gatherButton.x = (Constants.SCREEN_SIZE.x - gatherButton.width) * 0.5;
        gatherButton.y = (Constants.SCREEN_SIZE.y - gatherButton.height) * 0.5;
        _modeLayer.addChild(gatherButton);
        registerOneShotCallback(gatherButton, MouseEvent.CLICK,
            function (...ignored) :void {
                ClientCtx.showMultiplayerLobby();
            });

        var singlePlayerButton :SimpleButton = UIBits.createButton("Play Alone", 2);
        singlePlayerButton.x = (Constants.SCREEN_SIZE.x - singlePlayerButton.width) * 0.5;
        singlePlayerButton.y = gatherButton.y + gatherButton.height + 10;
        _modeLayer.addChild(singlePlayerButton);
        registerOneShotCallback(singlePlayerButton, MouseEvent.CLICK,
            function (...ignored) :void {
                Resources.loadLevelPackResources(Resources.SP_LEVEL_PACK_RESOURCES,
                                                 LevelSelectMode.create);
            });
    }

    override protected function destroy () :void
    {
        _soundChannel.audioControls.fadeOut(0.5).stopAfter(0.5);
        super.destroy();
    }

    protected var _soundChannel :AudioChannel;
}

}
