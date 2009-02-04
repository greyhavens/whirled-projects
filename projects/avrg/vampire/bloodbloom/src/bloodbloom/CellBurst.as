package bloodbloom {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.SimObjectRef;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.*;
import com.whirled.contrib.simplegame.util.Collision;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;

public class CellBurst extends SceneObject
{
    public static function createFromCell (cell :Cell, sequence :BurstSequence = null) :CellBurst
    {
        var newBurst :CellBurst = new CellBurst(cell.x, cell.y, sequence);
        cell.db.addObject(newBurst, cell.displayObject.parent);
        cell.destroySelf();
        return newBurst;
    }

    public function CellBurst (x :Number, y :Number, sequence :BurstSequence = null)
    {
        _sprite = new Sprite();

        _sequence = sequence;
        if (_sequence == null) {
            _sequence = new BurstSequence();
            _sequence.x = x;
            _sequence.y = y;
            ClientCtx.gameMode.addObject(_sequence, ClientCtx.effectLayer);
        }

        this.x = x;
        this.y = y;
    }

    override protected function addedToDB () :void
    {
        beginBurst();
    }

    protected function beginBurst () :void
    {
        removeAllTasks();

        var g :Graphics = _sprite.graphics;
        g.clear();
        g.lineStyle(2, 0xff0000);
        g.drawCircle(0, 0, Constants.BURST_RADIUS_MIN);

        this.alpha = 1;

        var thisBurst :CellBurst = this;

        var targetScale :Number = Constants.BURST_RADIUS_MAX / Constants.BURST_RADIUS_MIN;
        addTask(ScaleTask.CreateEaseOut(targetScale, targetScale, Constants.BURST_EXPAND_TIME));
        addTask(new SerialTask(
            new TimedTask(Constants.BURST_COMPLETE_TIME - 0.25),
            new AlphaTask(0, 0.25),
            new SelfDestructTask()));

        _sequence.addCellBurst(this);
        _mode = BURST;
    }

    protected function beginUnburst () :void
    {
        removeAllTasks();

        var g :Graphics = _sprite.graphics;
        g.clear();
        g.lineStyle(2, 0xff00ff);
        g.drawCircle(0, 0, Constants.BURST_RADIUS_MIN);

        this.alpha = 1;

        var thisBurst :CellBurst = this;

        addTask(new SerialTask(
            ScaleTask.CreateEaseIn(1, 1, Constants.BURST_CONTRACT_TIME),
            new FunctionTask(
                function () :void {
                    var newCell :Cell = new Cell(Constants.CELL_RED, false);
                    newCell.x = thisBurst.x;
                    newCell.y = thisBurst.y;
                    thisBurst.db.addObject(newCell, thisBurst.displayObject.parent);
                }),
            new SelfDestructTask()));

        _sequence.removeCellBurst(this);
        _mode = UNBURST;
    }

    override protected function update (dt :Number) :void
    {
        var thisLoc :Vector2 = new Vector2(this.x, this.y);

        if (_mode == BURST) {
            // We're bursting. When we collide with red cells, we create new CellBursts;
            // When we collide with white cells, we unburst.
            var cell :Cell = Cell.getCellCollision(thisLoc, this.radius);
            if (cell != null) {
                if (cell.isRedCell) {
                    CellBurst.createFromCell(cell, _sequence);
                } else {
                    beginUnburst();
                }
            }

            var preyLoc :Vector2 = new Vector2(ClientCtx.prey.x, ClientCtx.prey.y);
            if (Collision.circlesIntersect(thisLoc, this.radius, preyLoc, Constants.CURSOR_RADIUS)) {
                ClientCtx.gameMode.gameOver("Prey hit a blood burst!");
            }

        } else if (_mode == UNBURST) {
            // We're unbursting. Collide with other CellBursts and contract them back into cells.
            var otherLoc :Vector2 = new Vector2();
            var bursts :Array = ClientCtx.mainLoop.topMode.getObjectRefsInGroup("CellBurst");
            for each (var burstRef :SimObjectRef in bursts) {
                var burst :CellBurst = burstRef.object as CellBurst;
                if (burst != null && burst != this && burst._mode == BURST) {
                    otherLoc.x = burst.x;
                    otherLoc.y = burst.y;
                    if (Collision.circlesIntersect(thisLoc, this.radius, otherLoc, burst.radius)) {
                        burst.beginUnburst();
                        break;
                    }
                }
            }
        }
    }

    override public function getObjectGroup (groupNum :int) :String
    {
        if (groupNum == 0) {
            return "CellBurst";
        } else {
            return super.getObjectGroup(groupNum - 1);
        }
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected function get radius () :Number
    {
        return (this.scaleX * Constants.BURST_RADIUS_MIN);
    }

    protected var _sprite :Sprite;
    protected var _mode :int;
    protected var _sequence :BurstSequence;

    protected static const BURST :int = 0;
    protected static const UNBURST :int = 1;
}

}
