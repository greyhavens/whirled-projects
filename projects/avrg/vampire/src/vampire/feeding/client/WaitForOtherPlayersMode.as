package vampire.feeding.client {

import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.objects.SimpleTimer;

import flash.display.Graphics;
import flash.display.Sprite;
import flash.text.TextField;

public class WaitForOtherPlayersMode extends AppMode
{
    override protected function setup () :void
    {
        // If several seconds have elapsed, and other players still haven't checked in,
        // they're probably reading the directions. Let the player know what's going on.
        addObject(new SimpleTimer(DELAY, displayAlert));
    }

    protected function displayAlert () :void
    {
        var tf :TextField =
            TextBits.createText("Waiting for new players to read the directions", 2, 0, 0xffffff);

        var bg :Sprite = new Sprite();
        var g :Graphics = bg.graphics;
        g.beginFill(0);
        g.drawRect(0, 0, tf.width + 50, tf.height + 50);
        g.endFill();

        tf.x = (bg.width - tf.width) * 0.5;
        tf.y = (bg.height - tf.height) * 0.5;
        bg.addChild(tf);

        _modeSprite.addChild(bg);
    }

    protected static const DELAY :Number = 1.5;
}

}
