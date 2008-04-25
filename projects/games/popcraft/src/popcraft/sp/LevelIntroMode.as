package popcraft.sp {

import com.threerings.flash.SimpleTextButton;
import com.whirled.contrib.simplegame.AppMode;

import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import popcraft.*;

public class LevelIntroMode extends AppMode
{
    override protected function setup () :void
    {
        var bgSprite :Sprite = new Sprite();
        var g :Graphics = bgSprite.graphics;
        g.beginFill(0xF1B932);
        g.drawRect(0, 0, 250, 200);
        g.endFill();

        bgSprite.x = (Constants.SCREEN_DIMS.x * 0.5) - (bgSprite.width * 0.5);
        bgSprite.y = (Constants.SCREEN_DIMS.y * 0.5) - (bgSprite.height * 0.5);

        this.modeSprite.addChild(bgSprite);

        // level name
        var tfName :TextField = new TextField();
        tfName.selectable = false;
        tfName.autoSize = TextFieldAutoSize.CENTER;
        tfName.scaleX = 2;
        tfName.scaleY = 2;
        tfName.x = (this.modeSprite.width * 0.5) - (tfName.width * 0.5);
        tfName.y = 20;

        tfName.text = GameContext.spLevel.name;

        bgSprite.addChild(tfName);

        // level intro text
        var tfDesc :TextField = new TextField();
        tfDesc.selectable = false;
        tfDesc.multiline = true;
        tfDesc.wordWrap = true;
        tfDesc.autoSize = TextFieldAutoSize.LEFT;
        tfDesc.width = 250 - 24;
        tfDesc.x = 12;
        tfDesc.y = 50;

        tfDesc.text = GameContext.spLevel.introText;

        bgSprite.addChild(tfDesc);

        var button :SimpleTextButton = new SimpleTextButton("Play");
        button.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                AppContext.mainLoop.popMode();
            });

        button.x = (bgSprite.width * 0.5) - (button.width * 0.5);
        button.y = 150;

        bgSprite.addChild(button);
    }
}

}
