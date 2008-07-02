package popcraft {

import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.text.TextField;

import popcraft.sp.LevelSelectMode;
import popcraft.ui.UIBits;

public class TutorialMode extends TransitionMode
{
    override protected function setup () :void
    {
        _skipButton = UIBits.createButton("Skip");
        _skipButton.x = Constants.SCREEN_SIZE.x - _skipButton.width - 15;
        _skipButton.y = Constants.SCREEN_SIZE.y - _skipButton.height - 15;
        _skipButton.addEventListener(MouseEvent.CLICK, endTutorial);

        _modeLayer.addChild(_skipButton);

        var text :TextField = UIBits.createTitleText("Placeholder Tutorial");
        text.x = (Constants.SCREEN_SIZE.x * 0.5) - (text.width * 0.5);
        text.y = (Constants.SCREEN_SIZE.y * 0.5) - (text.height * 0.5);
        _modeLayer.addChild(text);
    }

    protected function endTutorial (...ignored) :void
    {
        _modeLayer.removeChild(_skipButton);
        this.fadeOutToMode(new LevelSelectMode());
    }

    protected var _skipButton :SimpleButton;
}

}
