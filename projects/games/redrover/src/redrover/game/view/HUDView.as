package redrover.game.view {

import com.threerings.util.StringUtil;
import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Point;
import flash.text.TextField;

import redrover.*;
import redrover.game.*;
import redrover.ui.UIBits;
import redrover.util.SpriteUtil;

public class HUDView extends SceneObject
{
    public function HUDView (size :Point)
    {
        _sprite = SpriteUtil.createSprite(true);
        var g :Graphics = _sprite.graphics;
        g.beginFill(0);
        g.drawRect(0, 0, size.x, size.y);
        g.endFill();

        _gemSprite = SpriteUtil.createSprite();
        _gemSprite.x = 150;
        _gemSprite.y = size.y * 0.5;
        _sprite.addChild(_gemSprite);

        var switchBoardsButton :SwitchBoardsButton = new SwitchBoardsButton();
        switchBoardsButton.x = size.x - 10;
        switchBoardsButton.y = (size.y - switchBoardsButton.height) * 0.5;
        GameContext.gameMode.addObject(switchBoardsButton, _sprite);
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        var newScore :int = GameContext.localPlayer.score;
        if (newScore != _lastScore) {
            if (_scoreText != null) {
                _scoreText.parent.removeChild(_scoreText);
            }

            _scoreText = UIBits.createText("Score: " + StringUtil.formatNumber(newScore),
                1.5, 0, 0xFFFFFF);
            _scoreText.x = 10;
            _scoreText.y = (_sprite.height - _scoreText.height) * 0.5;
            _sprite.addChild(_scoreText);
            _lastScore = newScore;
        }

        var newGems :int = GameContext.localPlayer.numGems;
        if (newGems != _lastGems) {
            while (_gemSprite.numChildren > 0) {
                _gemSprite.removeChildAt(_gemSprite.numChildren - 1);
            }

            for each (var gemType :int in GameContext.localPlayer.gems) {
                var gem :DisplayObject = GemViewFactory.createGem(30, gemType);
                gem.x = _gemSprite.width;
                gem.y = -gem.height * 0.5;
                _gemSprite.addChild(gem);
            }

            _lastGems = newGems;
        }
    }

    protected var _sprite :Sprite;
    protected var _scoreText :TextField;
    protected var _teamTexts :Array = [ null, null ];
    protected var _gemSprite :Sprite;
    protected var _lastGems :int = -1;
    protected var _lastScore :int = -1;
    protected var _lastTeamSizes :Array = [ -1, -1 ];
}

}
