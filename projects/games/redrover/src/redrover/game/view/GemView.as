package redrover.game.view {

import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.DisplayObject;
import flash.display.Sprite;

import redrover.*;
import redrover.game.*;
import redrover.util.SpriteUtil;

public class GemView extends SceneObject
{
    public function GemView (gemType :int, boardCell :BoardCell)
    {
        _boardCell = boardCell;

        var gem :DisplayObject = GemViewFactory.createGem(GameContext.levelData.cellSize - 12,
                                                          gemType);
        gem.x = -gem.width * 0.5;
        gem.y = -gem.height * 0.5;

        _sprite = SpriteUtil.createSprite();
        _sprite.addChild(gem);

        // center the GemView in its cell
        this.x = _boardCell.ctrPixelX;
        this.y = _boardCell.ctrPixelY;
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override protected function update (dt :Number) :void
    {
        if (!_boardCell.hasGem) {
            destroySelf();
        }
    }

    protected var _boardCell :BoardCell;
    protected var _sprite :Sprite;
}

}
