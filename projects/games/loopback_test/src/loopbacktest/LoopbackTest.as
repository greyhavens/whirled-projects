package loopbacktest {

import com.threerings.flash.SimpleTextButton;
import com.whirled.game.GameControl;
import com.whirled.game.loopback.LoopbackGameControl;
import com.whirled.net.MessageReceivedEvent;

import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;

[SWF(width="700", height="500", frameRate="30")]
public class LoopbackTest extends Sprite
{
    public function LoopbackTest ()
    {
        _gameCtrl = new LoopbackGameControl(this);
        _gameCtrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, onMsgReceived);

        // background
        var g :Graphics = this.graphics;
        g.lineStyle(2, 0);
        g.beginFill(0xffffff);
        g.drawRect(0, 0, 700, 500);
        g.endFill();

        // status text
        _status = new TextField();
        setStatusText("LoopbackTest");
        addChild(_status);

        // buttons
        var sendMsg :SimpleTextButton = new SimpleTextButton("Send message");
        sendMsg.x = 10;
        sendMsg.y = 10;
        addChild(sendMsg);
        sendMsg.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                _gameCtrl.net.sendMessage("Hello!", null);
            });
    }

    protected function onMsgReceived (e :MessageReceivedEvent) :void
    {
        setStatusText("Message received: " + e.name);
    }

    protected function setStatusText (text :String) :void
    {
        TextBits.initTextField(_status, text, 1.5, 0, 0, "left");
        _status.x = 10;
        _status.y = this.height - 40;
    }

    protected var _gameCtrl :GameControl;
    protected var _status :TextField;
}

}
