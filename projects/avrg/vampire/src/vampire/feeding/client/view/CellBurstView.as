package vampire.feeding.client.view {

import vampire.feeding.*;
import vampire.feeding.client.*;

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

        var color :uint;
        switch (cellBurst.cellType) {
        case Constants.CELL_RED:
            color = 0xff0000;
            break;

        case Constants.CELL_BONUS:
            color = 0x0000ff;
            break;

        case Constants.CELL_WHITE:
            color = 0xffffff;
            break;
        }

        var g :Graphics = _sprite.graphics;
        g.clear();
        g.lineStyle(2, color);
        g.drawCircle(0, 0, cellBurst.radiusMin);

        addTask(After(Constants.BURST_COMPLETE_TIME - 0.25, new AlphaTask(0, 0.25)));
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override protected function addedToDB () :void
    {
        ClientCtx.audio.playSoundNamed("sfx_red_burst");
    }

    override protected function update (dt :Number) :void
    {
        if (!_cellBurst.isLiveObject) {
            destroySelf();
            return;
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
