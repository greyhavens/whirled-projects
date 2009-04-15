package vampire.quest {

public class ActivityDesc
{
    public static const TYPE_CORRUPTION :int = 0;

    public var type :int;
    public var params :Object;

    public var displayName :String;

    public function ActivityDesc (type :int, displayName :String, params :Object)
    {
        this.type = type;
        this.displayName = displayName;
        this.params = params;
    }
}

}
