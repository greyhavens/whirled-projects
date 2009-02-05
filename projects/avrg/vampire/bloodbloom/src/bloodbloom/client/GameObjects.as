package bloodbloom.client {

import bloodbloom.client.view.*;

public class GameObjects
{
    public static function createCell (type :int, beingBorn :Boolean) :Cell
    {
        var obj :Cell = new Cell(type, beingBorn);
        ClientCtx.heartbeatDb.addObject(obj);

        var view :CellView = new CellView(obj);
        ClientCtx.gameMode.addObject(view, ClientCtx.cellLayer);

        return obj;
    }

    public static function createCellBurst (fromCell :Cell, sequence :BurstSequence = null)
        :CellBurst
    {
        var obj :CellBurst = new CellBurst(fromCell.x, fromCell.y, sequence);
        ClientCtx.heartbeatDb.addObject(obj);

        var view :CellBurstView = new CellBurstView(obj);
        ClientCtx.gameMode.addObject(view, ClientCtx.cellLayer);

        fromCell.destroySelf();

        return obj;
    }
}

}
