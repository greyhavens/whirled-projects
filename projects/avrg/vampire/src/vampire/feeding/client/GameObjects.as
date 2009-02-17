package vampire.feeding.client {

import com.whirled.contrib.simplegame.SimObject;

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
        obj.x = fromCell.x;
        obj.y = fromCell.y;
        GameCtx.gameMode.addObject(obj, GameCtx.cellLayer);

        fromCell.destroySelf();

        return obj;
    }

    public static function createWhiteBurst (fromObj :CollidableObj) :WhiteBurst
    {
        var obj :WhiteBurst = new WhiteBurst();
        obj.x = fromObj.loc.x;
        obj.y = fromObj.loc.y;
        GameCtx.gameMode.addObject(obj, GameCtx.cellLayer);

        fromObj.destroySelf();

        return obj;
    }

    public static function createPlayerCursor (playerType :int) :PlayerCursor
    {
        var obj :PlayerCursor = new PlayerCursor(playerType);
        GameCtx.gameMode.addObject(obj, GameCtx.cursorLayer);

        return obj;
    }
}

}
