package popcraft.battle.view {

import com.threerings.flash.DisplayUtil;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.text.TextField;

import popcraft.*;
import popcraft.ui.UIBits;
import popcraft.util.SpriteUtil;

public class ShoutView extends SceneObject
{
    public function ShoutView ()
    {
        _topSprite = SpriteUtil.createSprite();
    }

    override public function get displayObject () :DisplayObject
    {
        return _topSprite;
    }

    public function showShout (val :int) :void
    {
        if (val >= 0) {
            if (val == _shoutType) {
                _emphasis += 1;
            } else {
                _shoutType = val;
                _emphasis = 0;
            }
        }

        resetDisplay();
    }

    protected function resetDisplay () :void
    {
        if (_shoutSprite != null) {
            _shoutSprite.parent.removeChild(_shoutSprite);
            _shoutSprite = null;
        }

        removeAllTasks();

        if (_shoutType >= 0) {
            var shoutText :String = Constants.SHOUT_STRINGS[_shoutType];
            if (_emphasis >= 1) {
                shoutText = shoutText.toUpperCase();
            }
            var numExclamations :int = Math.min(MAX_EXCLAMATIONS, _emphasis);
            for (var ii :int = 0; ii < numExclamations; ++ii) {
                shoutText += "!";
            }

            var textSize :Number = Math.min(
                MAX_TEXT_SIZE,
                DEFAULT_TEXT_SIZE + (_emphasis * EMPHASIS_TEXT_INCREASE));
            var tf :TextField = UIBits.createText(shoutText, textSize);

            _shoutSprite = SpriteUtil.createSprite();
            _shoutSprite.graphics.beginFill(0xFFFFFF);
            _shoutSprite.graphics.drawRoundRect(
                0, 0,
                tf.width + (TEXT_H_MARGIN * 2),
                tf.height + (TEXT_V_MARGIN * 2), 120, 100);

            _shoutSprite.graphics.endFill();

            DisplayUtil.positionBounds(tf,
                (_shoutSprite.width - tf.width) * 0.5,
                (_shoutSprite.height - tf.height) * 0.5);
            _shoutSprite.addChild(tf);

            DisplayUtil.positionBounds(_shoutSprite,
                -_shoutSprite.width * 0.5, -_shoutSprite.height * 0.5);
            _topSprite.addChild(_shoutSprite);

            // display, then fade out
            this.alpha = 1;
            addTask(new SerialTask(
                new TimedTask(SCREEN_TIME),
                new AlphaTask(0, FADE_TIME),
                new FunctionTask(
                    function () :void {
                        _emphasis = 0;
                    })));
        }
    }

    protected var _topSprite :Sprite;
    protected var _shoutSprite :Sprite;
    protected var _shoutType :int = -1;
    protected var _emphasis :int;

    protected static const SCREEN_TIME :Number = 1;
    protected static const FADE_TIME :Number = 0.25;
    protected static const DEFAULT_TEXT_SIZE :Number = 1.2;
    protected static const EMPHASIS_TEXT_INCREASE :Number = 0.4;
    protected static const MAX_TEXT_SIZE :Number = 2.0;
    protected static const MAX_EXCLAMATIONS :int = 2;

    protected static const TEXT_H_MARGIN :Number = 5;
    protected static const TEXT_V_MARGIN :Number = 4;
}

}
