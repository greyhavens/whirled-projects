package popcraft.battle {

/** Encapsulates immutable data about a particular type of Creature. */
public class UnitData
{
    public function UnitData (name :String, costs :Array, imageClass :Class)
    {
        _name = name;
        _costs = costs;
        _imageClass = imageClass;
    }

    public function get resourceCosts () :Array
    {
        return _costs;
    }

    public function get name () :String
    {
        return _name;
    }

    public function get imageClass () :Class
    {
        return _imageClass;
    }

    public function getResourceCost (resourceType :uint) :int
    {
        return _costs[resourceType];
    }

    protected var _name :String;
    protected var _costs :Array;
    protected var _imageClass :Class;
}

}
