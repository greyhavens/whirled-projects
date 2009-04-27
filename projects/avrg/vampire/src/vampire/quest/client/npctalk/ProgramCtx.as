package vampire.quest.client.npctalk {

import vampire.quest.client.NpcTalkPanel;

public class ProgramCtx
{
    public static var program :Program;
    public static var view :NpcTalkPanel;
    public static var lastResponseId :String;

    public static function init () :void
    {
        program = null;
        view = null;
        lastResponseId = null;
    }
}

}
