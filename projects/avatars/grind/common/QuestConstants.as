package {

public class QuestConstants
{
    public static const SERVICE :String = "quest:svc";

    public static const TYPE_PLAYER :String = "player";
    public static const TYPE_MONSTER :String = "monster";

    public static const STATE_ATTACK :String = "attack";
    public static const STATE_COUNTER :String = "counter";
    public static const STATE_HEAL :String = "heal";
    public static const STATE_DEAD :String = "dead";

    // "Events" piggybacked on effects messages
    // Eventually maybe QuestSprite could listen for these and dispatch an AS3 Event, but for
    // now, just have listeners scoop the effects messages directly
    public static const EVENT_ATTACK :int = 0;
    public static const EVENT_COUNTER :int = 1;
    public static const EVENT_HEAL :int = 2;
    public static const EVENT_DIE :int = 3;
}

}
