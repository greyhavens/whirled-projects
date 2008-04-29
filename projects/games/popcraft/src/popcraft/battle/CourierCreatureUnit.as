package popcraft.battle {

import com.whirled.contrib.simplegame.*;

import popcraft.*;
import popcraft.battle.ai.*;

/**
 * Couriers retrieve spell pickups from the battlefield and bring them back to their
 * owning player's base.
 *
 * Couriers move faster when there are more of them on the playfield.
 */
public class CourierCreatureUnit extends CreatureUnit
{
    public function CourierCreatureUnit (owningPlayerId :uint)
    {
        super(Constants.UNIT_TYPE_COURIER, owningPlayerId);

        _courierAI = new CourierAI(this);
    }

    override protected function get aiRoot () :AITask
    {
        return _courierAI;
    }

    protected var _courierAI :CourierAI;
}

}

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.util.*;
import flash.geom.Point;

import popcraft.*;
import popcraft.battle.*;
import popcraft.battle.ai.*;
import flash.display.Loader;
import com.threerings.util.Log;

class CourierAI extends AITaskTree
{
    public function CourierAI (unit :CourierCreatureUnit)
    {
        _unit = unit;
    }

    override protected function receiveSubtaskMessage (task :AITask, messageName :String, data :Object) :void
    {

    }

    override public function get name () :String
    {
        return "CourierAI";
    }

    protected var _unit :CourierCreatureUnit;

    protected static const log :Log = Log.getLog(CourierAI);
}
