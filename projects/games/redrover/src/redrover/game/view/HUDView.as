package redrover.game.view {

import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.text.TextField;

import redrover.*;
import redrover.game.*;
import redrover.ui.UIBits;
import redrover.util.SpriteUtil;

public class HUDView extends SceneObject
{
    public function HUDView ()
    {
        _sprite = SpriteUtil.createSprite();
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        var newGems :int = GameContext.localPlayer.numGems;
        var newScore :int = GameContext.localPlayer.score;
        if (newGems != _lastGems || newScore != _lastScore) {
            updateDisplay();
        }
    }

    protected function updateDisplay () :void
    {
        var newGems :int = GameContext.localPlayer.numGems;
        var newScore :int = GameContext.localPlayer.score;

        var gemSprite :Sprite = SpriteUtil.createSprite();
        for each (var gemType :int in GameContext.localPlayer.gems) {
            var gem :DisplayObject = GemViewFactory.createGem(15, gemType);
            gem.x = gemSprite.width;
            gemSprite.addChild(gem);
        }

        var tf :TextField = UIBits.createText("Score: " + newScore, 1.5, 0, 0xFFFFFF);

        // remove old display objects
        while (_sprite.numChildren > 0) {
            _sprite.removeChildAt(_sprite.numChildren - 1);
        }

        // add new display objects
        var bg :Shape = new Shape();
        var g :Graphics = bg.graphics;
        g.beginFill(0);
        g.drawRect(0, 0, Math.max(gemSprite.width, tf.width) + 10, gemSprite.height + tf.height + 6);
        g.endFill();
        _sprite.addChild(bg);

        gemSprite.x = 5;
        gemSprite.y = 3;
        _sprite.addChild(gemSprite);

        tf.x = 5;
        tf.y = gemSprite.y + gemSprite.height;
        _sprite.addChild(tf);

        _lastGems = newGems;
        _lastScore = newScore;
    }

    protected var _sprite :Sprite;
    protected var _lastGems :int = -1;
    protected var _lastScore :int = -1;
}

}
