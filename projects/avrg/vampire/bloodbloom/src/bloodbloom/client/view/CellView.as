package bloodbloom.client.view {

import bloodbloom.client.*;

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.Sprite;

public class CellView extends SceneObject
{
    public function CellView (cell :Cell)
    {
        _cell = cell;
        _sprite = new Sprite();
        _sprite.addChild(ClientCtx.createCellBitmap(cell.type));

        if (cell.state == Cell.STATE_BIRTH) {
            // fade in
            this.alpha = 0;
            addTask(new AlphaTask(1, 0.4));
        }
    }

    override protected function update (dt :Number) :void
    {
        if (!_cell.isLiveObject) {
            destroySelf();
            return;
        }

        this.x = _cell.loc.x;
        this.y = _cell.loc.y;
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _cell :Cell;
    protected var _sprite :Sprite;
}

}
