package popcraft.sp {

import com.threerings.flash.SimpleTextButton;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.audio.AudioManager;

import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import popcraft.*;

public class LevelOutroMode extends AppMode
{
    public function LevelOutroMode (success :Boolean)
    {
        _success = success;
    }

    override protected function setup () :void
    {
        // draw dim background
        var g :Graphics = this.modeSprite.graphics;
        g.beginFill(0, 0.6);
        g.drawRect(0, 0, Constants.SCREEN_DIMS.x, Constants.SCREEN_DIMS.y);
        g.endFill();

        var bgSprite :Sprite = new Sprite();
        g = bgSprite.graphics;
        g.beginFill(_success ? 0x76FF86 : 0xFD5CFF);
        g.drawRect(0, 0, 250, 200);
        g.endFill();

        bgSprite.x = (Constants.SCREEN_DIMS.x * 0.5) - (bgSprite.width * 0.5);
        bgSprite.y = (Constants.SCREEN_DIMS.y * 0.5) - (bgSprite.height * 0.5);

        this.modeSprite.addChild(bgSprite);

        // win/lose text
        var tfName :TextField = new TextField();
        tfName.selectable = false;
        tfName.autoSize = TextFieldAutoSize.CENTER;
        tfName.scaleX = 2;
        tfName.scaleY = 2;
        tfName.text = (_success ? "Victory!" : "Defeated");
        tfName.x = (bgSprite.width * 0.5) - (tfName.width * 0.5);
        tfName.y = 30;

        bgSprite.addChild(tfName);

        // buttons
        var button :SimpleTextButton;

        if (_success) {
            button = new SimpleTextButton("Next Level");
            button.addEventListener(MouseEvent.CLICK,
                function (...ignored) :void {
                    AppContext.levelMgr.incrementLevelNum();
                    AppContext.levelMgr.playLevel();
                });
        } else {
            button = new SimpleTextButton("Retry");
            button.addEventListener(MouseEvent.CLICK,
                function (...ignored) :void {
                    AppContext.levelMgr.playLevel();
                });
        }

        button.x = (bgSprite.width * 0.5) - (button.width * 0.5);
        button.y = 100;
        bgSprite.addChild(button);

        button = new SimpleTextButton("Main Menu");
        button.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                AppContext.mainLoop.unwindToMode(new LevelSelectMode());
            });
        button.x = (bgSprite.width * 0.5) - (button.width * 0.5);
        button.y = 150;
        bgSprite.addChild(button);
    }

    override protected function enter () :void
    {
        if (!_playedSound) {
            AudioManager.instance.playSoundNamed(_success ? "sfx_wingame" : "sfx_losegame");
            _playedSound = true;
        }
    }

    protected var _success :Boolean;
    protected var _playedSound :Boolean;

}

}
