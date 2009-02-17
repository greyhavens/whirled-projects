package vampire.feeding.client {

import flash.geom.Point;

import vampire.feeding.*;
import vampire.feeding.client.view.*;

public class GameObjects
{
    public static function createCell (type :int, beingBorn :Boolean, multiplier :int = 1) :Cell
    {
        var obj :Cell = new Cell(type, beingBorn, multiplier);
        GameCtx.gameMode.addObject(obj, GameCtx.cellLayer);

        return obj;
    }

    public static function createRedBurst (fromCell :Cell, sequence :BurstSequence = null)
        :RedBurst
    {
        var obj :RedBurst = new RedBurst(fromCell, sequence);
        var loc :Point =
            fromCell.displayObject.parent.localToGlobal(new Point(fromCell.x, fromCell.y));
        loc = GameCtx.cellLayer.globalToLocal(loc);
        obj.x = loc.x;
        obj.y = loc.y;
        GameCtx.gameMode.addObject(obj, GameCtx.cellLayer);

        fromCell.destroySelf();

        return obj;
    }

    public static function createWhiteBurst (fromObj :CollidableObj) :WhiteBurst
    {
        var isBlackBurst :Boolean = true;
        if (fromObj is Cell) {
            isBlackBurst = !((fromObj as Cell).isWhiteCell);
        }

        var obj :WhiteBurst = new WhiteBurst(isBlackBurst);

        var loc :Point =
            fromObj.displayObject.parent.localToGlobal(new Point(fromObj.x, fromObj.y));
        loc = GameCtx.cellLayer.globalToLocal(loc);
        obj.x = loc.x;
        obj.y = loc.y;
        GameCtx.gameMode.addObject(obj, GameCtx.cellLayer);

        fromObj.destroySelf();

        return obj;
    }

    public static function createPlayerCursor () :PlayerCursor
    {
        var obj :PlayerCursor = new PlayerCursor();
        GameCtx.gameMode.addObject(obj, GameCtx.cursorLayer);

        return obj;
    }
}

}
