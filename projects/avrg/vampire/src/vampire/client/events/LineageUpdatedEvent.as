package vampire.client.events
{
import com.threerings.util.ClassUtil;

import flash.events.Event;

import vampire.data.Lineage;

public class LineageUpdatedEvent extends Event
{
    public function LineageUpdatedEvent(h:Lineage, playerId :int = 0)
    {
        super(LINEAGE_UPDATED, false, false);
        _lineage = h;
        _playerId = playerId;
    }

    public function get lineage() :Lineage
    {
        return _lineage;
    }

    public function get playerId() :int
    {
        return _playerId;
    }

    override public function toString () :String
    {
        return ClassUtil.tinyClassName(this) + ", lineage=" + lineage;
    }

    protected var _lineage :Lineage;
    protected var _playerId :int;

    public static const LINEAGE_UPDATED :String = "Lineage Updated";

}
}