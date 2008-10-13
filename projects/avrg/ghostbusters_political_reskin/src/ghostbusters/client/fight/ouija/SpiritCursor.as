package ghostbusters.client.fight.ouija {

import flash.geom.Matrix;
import flash.geom.Point;

public class SpiritCursor extends Cursor
{
    public function SpiritCursor (board :Board, locTransform :Matrix)
    {
        super(board);
        _locTransform = locTransform;
    }

    override protected function updateLocation (localX :Number, localY :Number) :void
    {
        // distance from center of screen
        var d :Point = new Point(localX - BOARD_CENTER.x, localY - BOARD_CENTER.y);

        // transform
        var dTrans :Point = _locTransform.transformPoint(d);

        // apply
        super.updateLocation(BOARD_CENTER.x + dTrans.x, BOARD_CENTER.y + dTrans.y);
    }

    protected var _locTransform :Matrix;
    
    protected static const BOARD_CENTER :Point = new Point(148, 111);

}

}
