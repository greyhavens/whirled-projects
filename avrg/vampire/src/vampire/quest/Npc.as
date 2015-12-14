package vampire.quest {

public class Npc
{
    public static const LILITH :int = 0;

    public static function getName (npc :int) :String
    {
        return NAMES[npc];
    }

    public static function getPortraitName (npc :int) :String
    {
        return PORTRAITS[npc];
    }

    protected static const NAMES :Array = [
        "Lilith",
    ];

    protected static const PORTRAITS :Array = [
        "portrait_lilith",
    ];
}

}
