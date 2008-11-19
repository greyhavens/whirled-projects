package redrover.game.view {

import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.DisplayObject;
import flash.display.Sprite;

import redrover.*;
import redrover.game.BoardCell;
import redrover.util.SpriteUtil;

public class GemView extends SceneObject
{
    public function GemView (gemType :int, boardCell :BoardCell)
    {
        _boardCell = boardCell;

        var gem :DisplayObject = GemViewFactory.createGem(gemType);
        gem.x = -gem.width * 0.5;
        gem.y = -gem.height;

        _sprite = SpriteUtil.createSprite();
        _sprite.addChild(gem);

        // center the GemView in its cell
        this.x = (_boardCell.gridX + 0.5) * Constants.BOARD_CELL_SIZE;
        this.y = (_boardCell.gridY + 0.75) * Constants.BOARD_CELL_SIZE;
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
