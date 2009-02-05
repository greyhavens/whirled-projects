package bloodbloom.client {

import bloodbloom.client.view.*;

public class GameObjects
{
    public static function createCell (type :int, beingBorn :Boolean) :Cell
    {
        var obj :Cell = new Cell(type, beingBorn);
        GameCtx.heartbeatDb.addObject(obj);

        var view :CellView = new CellView(obj);
        GameCtx.gameMode.addObject(view, GameCtx.cellLayer);

        return obj;
    }

    public static function createCellBurst (fromCell :Cell, sequence :BurstSequence = null)
        :CellBurst
    {
        var obj :CellBurst = new CellBurst(fromCell.x, fromCell.y, sequence);
        GameCtx.heartbeatDb.addObject(obj);

        var view :CellBurstView = new CellBurstView(obj);
        GameCtx.gameMode.addObject(view, GameCtx.cellLayer);

        fromCell.destroySelf();

        return obj;
    }
}

}
