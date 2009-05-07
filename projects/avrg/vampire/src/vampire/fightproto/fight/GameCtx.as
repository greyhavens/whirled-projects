package vampire.fightproto.fight {

import flash.display.Sprite;

public class GameCtx
{
    public static var mode :FightMode;

    public static var bgLayer :Sprite;
    public static var characterLayer :Sprite;
    public static var uiLayer :Sprite;

    public static function init () :void
    {
        mode = null;

        bgLayer = null;
        characterLayer = null;
        uiLayer = null;
    }
}

}
