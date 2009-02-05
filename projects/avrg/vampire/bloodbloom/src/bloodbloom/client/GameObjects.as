package bloodbloom.client {

import bloodbloom.client.view.*;

public class GameObjects
{
    public static function createCell (type :int, beingBorn :Boolean) :Cell
    {
        var cell :Cell = new Cell(type, beingBorn);
        ClientCtx.heartbeatDb.addObject(cell);

        var view :CellView = new CellView(cell);
        ClientCtx.gameMode.addObject(view, ClientCtx.cellLayer);

        return cell;
    }
}

}
