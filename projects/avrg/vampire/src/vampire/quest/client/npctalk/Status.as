package vampire.quest.client.npctalk {

public class Status
{
    public static const Incomplete :Number = -1;
    public static const CompletedInstantly :Number = 0;

    public static function CompletedAfter (time :Number) :Number
    {
        return time;
    }

    public static function isComplete (status :Number) :Boolean
    {
        return status >= 0;
    }

}
}
