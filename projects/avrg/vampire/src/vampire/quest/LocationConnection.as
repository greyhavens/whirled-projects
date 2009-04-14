package vampire.quest {

public class LocationConnection
{
    public var loc :LocationDesc;
    public var cost :uint; // how much juice does it take to get to this Location?

    public function LocationConnection (loc :LocationDesc, cost :uint)
    {
        this.loc = loc;
        this.cost = cost;
    }
}

}
