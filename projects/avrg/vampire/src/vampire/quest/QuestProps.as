package vampire.quest {

public class QuestProps
{
    public static function makePermanent (propName :String) :String
    {
        return (isPermanent(propName) ? propName : PERMANENT + propName);
    }

    public static function makeTransient (propName :String) :String
    {
        return (isPermanent(propName) ? propName.substr(PERMANENT.length) : propName);
    }

    public static function isPermanent (propName :String) :Boolean
    {
        return (PERMANENT == propName.substr(0, PERMANENT.length));
    }

    public static const LILITH_VISITS :String = "lilith_visits";
    public static const NORMAL_FEEDINGS :String = "feedings";
    public static const PANDORA_FEEDINGS :String = "pandora_feedings";
    public static const REBEKAH_FEEDINGS :String = "rebekah_feedings";

    protected static const PERMANENT :String = "#";
}

}
