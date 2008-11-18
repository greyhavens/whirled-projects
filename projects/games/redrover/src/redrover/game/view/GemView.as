package redrover.game.view {

import com.whirled.contrib.ColorMatrix;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.ImageResource;

import flash.display.Bitmap;
import flash.display.DisplayObject;

import redrover.*;
import redrover.game.BoardCell;

public class GemView extends SceneObject
{
    public function GemView (teamId :int, boardCell :BoardCell)
    {
        _boardCell = boardCell;
        _bitmap = ImageResource.instantiateBitmap("gem");
        _bitmap.filters = [ ColorMatrix.create().colorize(TEAM_COLORS[teamId]).createFilter() ];

        this.x = _boardCell.pixelX + (Constants.BOARD_CELL_SIZE - _bitmap.width) * 0.5;
        this.y = _boardCell.pixelY + (Constants.BOARD_CELL_SIZE * 0.5) - _bitmap.height;
    }

    override public function get displayObject () :DisplayObject
    {
        return _bitmap;
    }

    override protected function update (dt :Number) :void
    {
        if (!_boardCell.hasGem) {
            destroySelf();
        }
    }

    protected var _boardCell :BoardCell;
    protected var _bitmap :Bitmap;

    protected static const TEAM_COLORS :Array = [ 0x78bdff, 0xff9898 ];
}

}
