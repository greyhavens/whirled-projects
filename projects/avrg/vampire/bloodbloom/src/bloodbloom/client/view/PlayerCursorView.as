package bloodbloom.client.view {

import bloodbloom.*;
import bloodbloom.client.*;

import com.threerings.flash.Vector2;
import com.threerings.util.Log;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Point;

public class PlayerCursorView extends SceneObject
{
    public function PlayerCursorView (cursor :PlayerCursor, playerType :int)
    {
        _cursor = cursor;

        var bm :Bitmap = ClientCtx.instantiateBitmap(
            playerType == Constants.PLAYER_PREY ? "prey_cursor" : "predator_cursor");
        bm.x = -bm.width * 0.5;
        bm.y = -bm.height * 0.5;
        _sprite = SpriteUtil.createSprite();
        _sprite.addChild(bm);

        registerListener(cursor, GameEvent.ATTACHED_CELL, onCellAttached);
        registerListener(cursor, GameEvent.DETACHED_ALL_CELLS, onDetachedCells);
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected function onCellAttached (e :GameEvent) :void
    {
        var cell :Cell = e.data as Cell;
        attachCellBitmap(cell.type, new Point(cell.x, cell.y));
    }

    protected function onDetachedCells (e :GameEvent) :void
    {
        for each (var bm :Bitmap in _attachedCellBitmaps) {
            bm.parent.removeChild(bm);
        }

        _attachedCellBitmaps = [];
    }

    override protected function update (dt :Number) :void
    {
        if (!_cursor.isLiveObject) {
            destroySelf();
            return;
        }

        // estimate the object's current location
        var newLoc :Vector2;
        if (GameCtx.clientFutureDelta > 0) {
            _cursorClone = PlayerCursor(_cursor.clone(_cursorClone));
            _cursorClone.updateLoc(GameCtx.clientFutureDelta);
            newLoc = _cursorClone.loc;

        } else {
            newLoc = _cursor.loc.clone();
        }

        this.x = newLoc.x;
        this.y = newLoc.y;

        if (!newLoc.similar(_lastLoc, 0.5)) {
            // rotate towards our move direction. 0 degrees == straight up
            var targetRotation :Number =
                90 + ((newLoc.subtract(_lastLoc).angle) * (180 / Math.PI));

            var curRotation :Number = this.rotation;
            if (targetRotation - curRotation > 180) {
                targetRotation -= 360;
            } else if (targetRotation - curRotation < -180) {
                targetRotation += 360;
            }

            addNamedTask(
                "Rotate",
                RotationTask.CreateEaseOut(
                    targetRotation,
                    Math.abs((targetRotation % 360) - curRotation) / ROTATE_SPEED),
                true);

        }

        _lastLoc = newLoc;
    }

    protected function attachCellBitmap (cellType :int, loc :Point) :void
    {
        var bm :Bitmap = ClientCtx.createCellBitmap(cellType);
        loc = GameCtx.cellLayer.localToGlobal(loc);
        loc = this.displayObject.globalToLocal(loc);
        loc.x -= bm.width * 0.5;
        loc.y -= bm.height * 0.5;
        bm.x = loc.x;
        bm.y = loc.y;
        _sprite.addChild(bm);
        _attachedCellBitmaps.push(bm);
    }

    protected var _cursor :PlayerCursor;
    protected var _cursorClone :PlayerCursor;
    protected var _sprite :Sprite;
    protected var _attachedCellBitmaps :Array = [];
    protected var _lastLoc :Vector2 = new Vector2();

    protected static var log :Log = Log.getLog(PlayerCursorView);

    protected static const ROTATE_SPEED :Number = 180; // degrees/second
}

}
