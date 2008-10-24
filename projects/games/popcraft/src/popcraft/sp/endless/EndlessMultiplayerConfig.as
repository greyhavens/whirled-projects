package popcraft.sp.endless {

import popcraft.*;

public class EndlessMultiplayerConfig
{
    public static const PROP_INITED :String = "emc_Inited";
    public static const PROP_GAMESTARTING :String = "emc_Starting";
    public static const PROP_SELECTEDLEVELIDX :String = "emc_SelectedLevel";
    public static const PROP_SAVEDGAMES :String = "emc_Saves";

    public static function init (numPlayers :int) :void
    {
        AppContext.gameCtrl.net.doBatch(function () :void {
            EndlessMultiplayerConfig.gameStarting = false;
            EndlessMultiplayerConfig.selectedLevelIndex = 0;
            EndlessMultiplayerConfig.savedGames = null;
            EndlessMultiplayerConfig.inited = true;
        });
    }

    public static function set inited (val :Boolean) :void
    {
        AppContext.gameCtrl.net.set(PROP_INITED, val);
    }

    public static function get inited () :Boolean
    {
        return AppContext.gameCtrl.net.get(PROP_INITED) as Boolean;
    }

    public static function set gameStarting (val :Boolean) :void
    {
        AppContext.gameCtrl.net.set(PROP_GAMESTARTING, val);
    }

    public static function get gameStarting () :Boolean
    {
        return AppContext.gameCtrl.net.get(PROP_GAMESTARTING) as Boolean;
    }

    public static function set selectedLevelIndex (val :int) :void
    {
        AppContext.gameCtrl.net.set(PROP_SELECTEDLEVELIDX, val);
    }

    public static function get selectedLevelIndex () :int
    {
        return AppContext.gameCtrl.net.get(PROP_SELECTEDLEVELIDX) as int;
    }

    public static function set savedGames (val :Array) :void
    {
        AppContext.gameCtrl.net.set(PROP_SAVEDGAMES, val);
    }

    public static function get savedGames (val :Array) :void
    {
        return AppContext.gameCtrl.net.get(PROP_SAVEDGAMES) as Array;
    }

    public function setLocalPlayerSavedGames (val :Array) :void
    {
        // TODO
    }

}

}
