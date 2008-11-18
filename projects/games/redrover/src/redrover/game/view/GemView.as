package redrover.game.view {

import com.whirled.contrib.ColorMatrix;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.ImageResource;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;

import redrover.*;
import redrover.game.BoardCell;
import redrover.util.SpriteUtil;

public class GemView extends SceneObject
{
    public function GemView (teamId :int, boardCell :BoardCell)
    {
        _boardCell = boardCell;

        _sprite = SpriteUtil.createSprite();
        var bm :Bitmap = ImageResource.instantiateBitmap("gem");
        bm.filters = [ new ColorMatrix().colorize(TEAM_COLORS[teamId]).createFilter() ];
        bm.x = -bm.width * 0.5;
        bm.y = -bm.height;
        _sprite.addChild(bm);

        // center the GemView in its cell
        this.x = (_boardCell.gridX + 0.5) * Constants.BOARD_CELL_SIZE;
        this.y = (_boardCell.gridY + 0.5) * Constants.BOARD_CELL_SIZE;
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

    protected static const TEAM_COLORS :Array = [ 0x78bdff, 0xff9898 ];
}

}
