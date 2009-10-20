package equip
{
public class Item
{
    public function Item(id :int, name :String, type :int, rsrc :String)
    {
        this.id = id;
        this.name = name;
        this.type = type;
        this.rsrc = rsrc;
    }

    public var id :int;
    public var name :String;
    public var rsrc :String;
    public var type :int;

}
}
