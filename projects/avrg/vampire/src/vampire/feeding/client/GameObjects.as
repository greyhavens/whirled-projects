package vampire.feeding.client {

import flash.geom.Point;

import vampire.feeding.*;

public class GameObjects
{
    public static function createCell (type :int, beingBorn :Boolean,
                                       multiplierOrStrain :int = 1) :Cell
    {
        var obj :Cell = new Cell(type, beingBorn, multiplierOrStrain);
        GameCtx.gameMode.addSceneObject(obj, GameCtx.cellLayer);

        return obj;
    }

    public static function createSpecialBloodAnim (fromCell :Cell) :void
    {
        GameCtx.strainTallyView.playGotStrainAnim(fromCell.x, fromCell.y);
        fromCell.destroySelf();
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
        GameCtx.gameMode.addSceneObject(obj, GameCtx.burstLayer);

        fromCell.destroySelf();

        return obj;
    }

    public static function createCorruptionBurst (fromObj :CollidableObj) :CorruptionBurst
    {
        var isBlackBurst :Boolean = true;
        if (fromObj is Cell) {
            isBlackBurst = !((fromObj as Cell).isWhiteCell);
        }

        var obj :CorruptionBurst = new CorruptionBurst(isBlackBurst);

        var loc :Point =
            fromObj.displayObject.parent.localToGlobal(new Point(fromObj.x, fromObj.y));
        loc = GameCtx.cellLayer.globalToLocal(loc);
        obj.x = loc.x;
        obj.y = loc.y;
        GameCtx.gameMode.addSceneObject(obj, GameCtx.burstLayer);

        fromObj.destroySelf();

        return obj;
    }

    public static function createPlayerCursor () :PlayerCursor
    {
        var obj :PlayerCursor = new PlayerCursor();
        GameCtx.gameMode.addSceneObject(obj, GameCtx.cursorLayer);

        return obj;
    }
}

}
