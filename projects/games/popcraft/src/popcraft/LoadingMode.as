package popcraft {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.resource.*;

import flash.display.Graphics;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

public class LoadingMode extends AppMode
{
    override protected function setup () :void
    {
        var g :Graphics = this.modeSprite.graphics;
        g.beginFill(0, 1);
        g.drawRect(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);
        g.endFill();

        _text = new TextField();
        _text.selectable = false;
        _text.autoSize = TextFieldAutoSize.CENTER;
        _text.textColor = 0xFFFFFF;
        _text.scaleX = 2;
        _text.scaleY = 2;
        _text.x = (this.modeSprite.width * 0.5) - (_text.width * 0.5);
        _text.y = (this.modeSprite.height * 0.5) - (_text.height * 0.5);
        _text.text = "Loading...";

        this.modeSprite.addChild(_text);

        // load resources
        this.load();

        // load the user cookie
        UserCookieManager.readCookie();
    }

    override public function update (dt :Number) :void
    {
        if (!_loading && !UserCookieManager.isLoadingCookie) {
            if (SeatingManager.allPlayersPresent) {
                AppContext.mainLoop.popMode();
            } else {
                _text.text = "Waiting for players...";
                _text.x = (this.modeSprite.width * 0.5) - (_text.width * 0.5);
            }
        }
    }

    protected function load () :void
    {
        Resources.loadBaseResources(handleResourcesLoaded, handleResourceLoadErr);
        _loading = true;
    }

    protected function handleResourcesLoaded () :void
    {
        _loading = false;
    }

    protected function handleResourceLoadErr (err :String) :void
    {
        AppContext.mainLoop.unwindToMode(new ResourceLoadErrorMode(err));
    }

    protected var _text :TextField;
    protected var _loading :Boolean;
}

}

import com.threerings.flash.SimpleTextButton;
import com.whirled.contrib.simplegame.AppMode;

import flash.display.Graphics;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import popcraft.*;

class ResourceLoadErrorMode extends AppMode
{
    public function ResourceLoadErrorMode (err :String)
    {
        _err = err;
    }

    override protected function setup () :void
    {
        var g :Graphics = this.modeSprite.graphics;
        g.beginFill(0xFF7272);
        g.drawRect(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);
        g.endFill();

        var tf :TextField = new TextField();
        tf.multiline = true;
        tf.wordWrap = true;
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.scaleX = 1.5;
        tf.scaleY = 1.5;
        tf.width = 400;
        tf.x = 50;
        tf.y = 50;
        tf.text = _err;

        this.modeSprite.addChild(tf);
    }

    protected var _err :String;
}
