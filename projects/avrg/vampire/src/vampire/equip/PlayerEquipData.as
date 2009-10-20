package equip
{
public class PlayerEquipData
{
    public function PlayerEquipData()
    {
    }

    public function set arms (item :int) :void
    {
        _arms = item;
    }

    public function get arms () :int
    {
        return _arms;
    }

    public function get allItems () :Array
    {
        return [1,2];
    }


    protected var _arms :int;
}
}
