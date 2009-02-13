package bloodbloom.client.view {

import bloodbloom.*;
import bloodbloom.client.*;

import com.whirled.contrib.simplegame.ObjectTask;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.text.TextField;

public class CellView extends SceneObject
{
    public function CellView (cell :Cell)
    {
        _cell = cell;
        _sprite = new Sprite();
        _sprite.addChild(ClientCtx.createCellBitmap(cell.type));

        if (cell.type == Constants.CELL_BONUS) {
            var text :String = "x" + cell.multiplier;
            var tf :TextField = UIBits.createText(text, 1, 0, 0xffffff);
            tf.x = -tf.width * 0.5;
            tf.y = -tf.height * 0.5;
            _sprite.addChild(tf);
        }

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

        var newState :int = _cell.state;
        if (_cell.isWhiteCell &&
            newState != _lastState &&
            newState == Cell.STATE_PREPARING_TO_EXPLODE) {
            var colorTask :ObjectTask = ColorMatrixBlendTask.colorize(
                0xffffff,
                0x444444,
                Constants.WHITE_CELL_EXPLODE_TIME);

            addTask(colorTask);
        }

        _lastState = newState;
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _cell :Cell;
    protected var _sprite :Sprite;
    protected var _lastState :int = -1;
}

}
