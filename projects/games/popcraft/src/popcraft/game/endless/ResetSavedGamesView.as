package popcraft.game.endless {

import com.threerings.flash.DisplayUtil;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.*;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFormatAlign;

import popcraft.*;
import popcraft.data.*;
import popcraft.game.*;
import popcraft.ui.*;
import popcraft.util.SpriteUtil;

public class ResetSavedGamesView extends SceneObject
{
    public function ResetSavedGamesView (text :String, resetCallback :Function,
        dontResetCallback :Function)
    {
        _sprite = SpriteUtil.createSprite(true);

        var g :Graphics = _sprite.graphics;
        g.beginFill(1, 0.7);
        g.drawRect(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);
        g.endFill();

        var tf :TextField = UIBits.createText(text, 1.1, 250, 0, TextFormatAlign.LEFT);
        var panel :Sprite = UIBits.createFrame(tf.width + 40, tf.height + 130);
        DisplayUtil.positionBounds(tf, (panel.width - tf.width) * 0.5, 20);
        panel.addChild(tf);

        var noResetButton :SimpleButton = UIBits.createButton("Don't Reset", 1.5, 150);
        DisplayUtil.positionBounds(noResetButton,
                                   (panel.width - noResetButton.width) * 0.5,
                                   tf.y + tf.height + 10);
        panel.addChild(noResetButton);

        registerOneShotCallback(noResetButton, MouseEvent.CLICK,
            function (...ignored) :void {
                dontResetCallback();
            });

        var resetButton :SimpleButton = UIBits.createButton("Reset", 1.2, 150);
        DisplayUtil.positionBounds(resetButton,
                                   (panel.width - resetButton.width)  * 0.5,
                                   noResetButton.y + noResetButton.height + 5);
        panel.addChild(resetButton);

        registerOneShotCallback(resetButton, MouseEvent.CLICK,
            function (...ignored) :void {
               resetCallback();
            });

        DisplayUtil.positionBounds(panel,
                                   (_sprite.width - panel.width) * 0.5,
                                   (_sprite.height - panel.height) * 0.5);
        _sprite.addChild(panel);
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _sprite :Sprite;
}

}
