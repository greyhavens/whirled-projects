package popcraft.battle {

/** Encapsulates immutable data about a particular type of Creature. */
public class UnitData
{
    public function UnitData (name :String, costs :Array)
    {
        _name = name;
        _costs = costs;
    }

    public function get resourceCosts () :Array
    {
        return _costs;
    }

    public function get name () :String
    {
        return _name;
    }

    public function getResourceCost (resourceType :uint) :int
    {
        return _costs[resourceType];
    }

    protected var _name :String;
    protected var _costs :Array;
}

}
