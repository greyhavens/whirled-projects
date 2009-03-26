package vampire.feeding.client {

import com.whirled.contrib.avrg.RoomDragger;
import com.whirled.contrib.simplegame.AppMode;

import flash.display.Graphics;
import flash.display.Sprite;
import flash.text.TextField;

public class WaitingForNextRoundMode extends AppMode
{
    override protected function setup () :void
    {
        super.setup();

        var parent :Sprite = new Sprite();
        _modeSprite.addChild(parent);

        var tf :TextField =
            TextBits.createText("Waiting for the next round to start", 2, 0, 0xffffff);

        var g :Graphics = parent.graphics;
        g.beginFill(0);
        g.drawRect(0, 0, tf.width + 10, tf.height + 10);
        g.endFill();

        tf.x = 5;
        tf.y = 5;
        parent.addChild(tf);

        ClientCtx.centerInRoom(parent);

        addObject(new RoomDragger(ClientCtx.gameCtrl, parent));
    }
}

}
