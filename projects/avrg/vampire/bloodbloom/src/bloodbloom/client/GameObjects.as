package bloodbloom.client {

import bloodbloom.*;
import bloodbloom.client.view.*;

public class GameObjects
{
    public static function createCell (type :int, beingBorn :Boolean, multiplier :int = 0) :Cell
    {
        var obj :Cell = new Cell(type, beingBorn, multiplier);
        GameCtx.gameMode.addObject(obj);

        var view :CellView = new CellView(obj);
        GameCtx.gameMode.addObject(view, GameCtx.cellLayer);

        return obj;
    }

    public static function createRedBurst (fromCell :Cell, sequence :BurstSequence = null)
        :RedBurst
    {
        var obj :RedBurst = new RedBurst(fromCell, sequence);
        obj.x = fromCell.x;
        obj.y = fromCell.y;
        GameCtx.gameMode.addObject(obj);

        fromCell.destroySelf();

        var view :CellBurstView = new CellBurstView(obj);
        GameCtx.gameMode.addObject(view, GameCtx.cellLayer);

        return obj;
    }

    public static function createWhiteBurst (fromObj :CollidableObj) :WhiteBurst
    {
        var obj :WhiteBurst = new WhiteBurst();
        obj.x = fromObj.x;
        obj.y = fromObj.y;
        GameCtx.gameMode.addObject(obj);

        fromObj.destroySelf();

        var view :CellBurstView = new CellBurstView(obj);
        GameCtx.gameMode.addObject(view, GameCtx.cellLayer);

        return obj;
    }

    public static function createPlayerCursor (playerType :int) :PlayerCursor
    {
        var obj :PlayerCursor = new PlayerCursor(playerType);
        GameCtx.gameMode.addObject(obj);

        var view :PlayerCursorView = new PlayerCursorView(obj);
        GameCtx.gameMode.addObject(view, GameCtx.cursorLayer);

        return obj;
    }
}

}
