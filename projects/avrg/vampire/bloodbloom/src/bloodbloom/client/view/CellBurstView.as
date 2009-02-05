package bloodbloom.client.view {

import bloodbloom.client.*;

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;

public class CellBurstView extends SceneObject
{
    public function CellBurstView (cellBurst :CellBurst)
    {
        _cellBurst = cellBurst;
        _sprite = SpriteUtil.createSprite();
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override protected function update (dt :Number) :void
    {
        if (!_cellBurst.isLiveObject) {
            destroySelf();
            return;
        }

        var state :int = _cellBurst.state;
        if (state != _lastState) {
            var g :Graphics = _sprite.graphics;
            g.clear();
            g.lineStyle(2, state == CellBurst.STATE_BURST ? 0xff0000 : 0xff00ff);
            g.drawCircle(0, 0, Constants.BURST_RADIUS_MIN);

            removeAllTasks();
            if (state == CellBurst.STATE_BURST) {
                addTask(After(Constants.BURST_COMPLETE_TIME - 0.25, new AlphaTask(0, 0.25)));
            }

            _lastState = state;
        }

        this.x = _cellBurst.loc.x;
        this.y = _cellBurst.loc.y;
        this.scaleX = this.scaleY = _cellBurst.scale;
    }

    protected var _cellBurst :CellBurst;
    protected var _sprite :Sprite;
    protected var _lastState :int = -1;
}

}
