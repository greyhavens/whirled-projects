//
// $Id$

package popcraft.game.endless {

import com.threerings.util.ArrayUtil;

import flash.utils.ByteArray;

import popcraft.*;

public class EndlessMultiplayerConfig
{
    public static const PROP_INITED :String = "emc_Inited";
    public static const PROP_GAMESTARTING :String = "emc_Starting";
    public static const PROP_SELECTEDMAPIDX :String = "emc_SelectedMap";
    public static const PROP_SAVEDGAMES :String = "emc_Saves";

    public static function init (numPlayers :int) :void
    {
        ClientCtx.gameCtrl.net.doBatch(function () :void {
            EndlessMultiplayerConfig.gameStarting = false;
            EndlessMultiplayerConfig.selectedMapIdx = 0;
            EndlessMultiplayerConfig.savedGames = ArrayUtil.create(2, null);
            EndlessMultiplayerConfig.inited = true;
        });
    }

    public static function set inited (val :Boolean) :void
    {
        ClientCtx.gameCtrl.net.set(PROP_INITED, val);
    }

    public static function get inited () :Boolean
    {
        return ClientCtx.gameCtrl.net.get(PROP_INITED) as Boolean;
    }

    public static function set gameStarting (val :Boolean) :void
    {
        ClientCtx.gameCtrl.net.set(PROP_GAMESTARTING, val);
    }

    public static function get gameStarting () :Boolean
    {
        return ClientCtx.gameCtrl.net.get(PROP_GAMESTARTING) as Boolean;
    }

    public static function set selectedMapIdx (val :int) :void
    {
        ClientCtx.gameCtrl.net.set(PROP_SELECTEDMAPIDX, val);
    }

    public static function get selectedMapIdx () :int
    {
        return ClientCtx.gameCtrl.net.get(PROP_SELECTEDMAPIDX) as int;
    }

    public static function set savedGames (val :Array) :void
    {
        ClientCtx.gameCtrl.net.set(PROP_SAVEDGAMES, val);
    }

    public static function get savedGames () :Array
    {
        var saves :Array = ClientCtx.gameCtrl.net.get(PROP_SAVEDGAMES) as Array;
        if (saves == null) {
            return null;
        }

        return saves.map(
            function (saveBytes :ByteArray, index :int, inArray :Array) :SavedEndlessGameList {
                if (saveBytes == null) {
                    return null;
                } else {
                    saveBytes.position = 0;
                    var saveList :SavedEndlessGameList = new SavedEndlessGameList();
                    saveList.fromBytes(saveBytes);
                    return saveList;
                }
            });
    }

    public static function get areSavedGamesValid () :Boolean
    {
        var saves :Array = EndlessMultiplayerConfig.savedGames;
        if (saves == null) {
            return false;
        }

        for each (var saveList :SavedEndlessGameList in saves) {
            if (saveList == null) {
                return false;
            }
        }

        return true;
    }

    public static function setPlayerSavedGames (playerSeat :int, val :SavedEndlessGameList) :void
    {
        ClientCtx.gameCtrl.net.setAt(PROP_SAVEDGAMES, playerSeat, val.toBytes());
    }

}

}
