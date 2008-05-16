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
        // draw dim background
        var g :Graphics = this.modeSprite.graphics;
        g.beginFill(0, 0.6);
        g.drawRect(0, 0, Constants.SCREEN_DIMS.x, Constants.SCREEN_DIMS.y);
        g.endFill();

        var bgSprite :Sprite = new Sprite();
        g = bgSprite.graphics;
        g.beginFill(0);
        g.drawRect(0, 0, 250, 1);
        g.endFill();

        this.modeSprite.addChild(bgSprite);

        // level name
        var tfName :TextField = new TextField();
        tfName.selectable = false;
        tfName.autoSize = TextFieldAutoSize.CENTER;
        tfName.scaleX = 2;
        tfName.scaleY = 2;
        tfName.x = (bgSprite.width * 0.5) - (tfName.width * 0.5);
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
        tfDesc.y = tfName.y + tfName.height + 3;

        tfDesc.text = GameContext.spLevel.introText;

        bgSprite.addChild(tfDesc);

        // Play button
        var button :SimpleTextButton = new SimpleTextButton("Play");
        button.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                AppContext.mainLoop.popMode();
            });

        button.x = (bgSprite.width * 0.5) - (button.width * 0.5);
        button.y = tfDesc.y + tfDesc.height + 8;

        bgSprite.addChild(button);

        // draw the background
        g = bgSprite.graphics;
        g.beginFill(0xF1B932);
        g.drawRect(0, 0, 250, bgSprite.height + 20);
        g.endFill();

        bgSprite.x = (Constants.SCREEN_DIMS.x * 0.5) - (bgSprite.width * 0.5);
        bgSprite.y = (Constants.SCREEN_DIMS.y * 0.5) - (bgSprite.height * 0.5);
    }
}

}
