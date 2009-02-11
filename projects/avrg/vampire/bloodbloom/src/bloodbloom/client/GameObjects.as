package bloodbloom.client {

import bloodbloom.*;
import bloodbloom.client.view.*;

public class GameObjects
{
    public static function createCell (type :int, beingBorn :Boolean) :Cell
    {
        var obj :Cell = new Cell(type, beingBorn);
        GameCtx.gameMode.addObject(obj);

        var view :CellView = new CellView(obj);
        GameCtx.gameMode.addObject(view, GameCtx.cellLayer);

        return obj;
    }

    public static function createCellBurst (fromCell :Cell, sequence :BurstSequence = null)
        :CellBurst
    {
        var obj :CellBurst = new CellBurst(fromCell.x, fromCell.y, sequence);
        GameCtx.gameMode.addObject(obj);

        var view :CellBurstView = new CellBurstView(obj);
        GameCtx.gameMode.addObject(view, GameCtx.cellLayer);

        fromCell.destroySelf();

        return obj;
    }

    public static function createPlayerCursor (playerType :int) :PlayerCursor
    {
        var obj :PlayerCursor = (playerType == Constants.PLAYER_PREDATOR ?
            new PredatorCursor() :
            new PreyCursor());
        GameCtx.gameMode.addObject(obj);

        var view :PlayerCursorView = new PlayerCursorView(obj, playerType);
        GameCtx.gameMode.addObject(view, GameCtx.cursorLayer);

        return obj;
    }
}

}
