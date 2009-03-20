package vampire.feeding.client {

import com.threerings.util.HashSet;
import com.whirled.avrg.AVRGameAvatar;
import com.whirled.avrg.AVRGameControl;
import com.whirled.contrib.simplegame.MainLoop;
import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.resource.*;

import flash.display.Bitmap;
import flash.display.MovieClip;
import flash.utils.getTimer;

import vampire.feeding.*;
import vampire.feeding.net.*;

public class ClientCtx
{
    // Initialized just once
    public static var gameCtrl :AVRGameControl;
    public static var mainLoop :MainLoop;
    public static var rsrcs :ResourceManager;
    public static var audio :AudioManager;

    // Initialized every time a new feeding takes place
    public static var props :GamePropGetControl;
    public static var msgMgr :ClientMsgMgr;
    public static var gameCompleteCallback :Function;
    public static var playerData :PlayerFeedingData;
    public static var playerIds :Array;
    public static var preyId :int;
    public static var preyBloodType :int;
    public static var preyIsAi :Boolean;
    public static var awardedTrophies :HashSet;
    public static var lastRoundResults :RoundOverMsg;

    public static function init () :void
    {
        props = null;
        msgMgr = null;
        gameCompleteCallback = null;
        playerData = null;
        playerIds = null;
        preyId = 0;
        preyBloodType = -1;
        preyIsAi = false;
        awardedTrophies = new HashSet();
        lastRoundResults = null;
    }

    public static function awardTrophySequence (trophyNames :Array, valueRequirements :Array,
                                                value :Number) :void
    {
        for (var ii :int = 0; ii < trophyNames.length; ++ii) {
            if (value >= valueRequirements[ii]) {
                awardTrophy(trophyNames[ii]);
            }
        }
    }

    public static function awardTrophy (trophyName :String) :void
    {
        // Track the trophies we've awarded this feeding session, and don't try
        // to award them again (this isn't tracked across feeding sessions - should it be?)
        if (!awardedTrophies.contains(trophyName)) {
            msgMgr.sendMessage(AwardTrophyMsg.create(trophyName));
            awardedTrophies.add(trophyName);
        }
    }

    public static function hasAwardedTrophies (trophies :Array) :Boolean
    {
        for each (var trophy :String in trophies) {
            if (!awardedTrophies.contains(trophy)) {
                return false;
            }
        }

        return true;
    }

    public static function get isLobbyLeader () :Boolean
    {
        return ((props.get(Props.LOBBY_LEADER) as int) == localPlayerId);
    }

    public static function get isPrey () :Boolean
    {
        return (localPlayerId == preyId);
    }

    public static function get isPredator () :Boolean
    {
        return (!isPrey);
    }

    public static function get isSinglePlayer () :Boolean
    {
        return (!isConnected || playerIds.length <= 1);
    }

    public static function get isMultiplayer () :Boolean
    {
        return !isSinglePlayer;
    }

    public static function quit (playerInitiated :Boolean) :void
    {
        if (playerInitiated) {
            msgMgr.sendMessage(ClientQuitMsg.create());
        }

        gameCompleteCallback();

        // TODO: if the player didn't initiate the quit, show a screen explaining what happened
    }

    public static function get localPlayerId () :int
    {
        return (!isConnected ? 1 : gameCtrl.player.getPlayerId());
    }

    public static function get timeNow () :Number
    {
        return flash.utils.getTimer() * 0.001; // returns seconds
    }

    public static function get isConnected () :Boolean
    {
        return gameCtrl.isConnected();
    }

    public static function getPlayerName (playerId :int) :String
    {
        if (gameCtrl.isConnected()) {
            var avatar :AVRGameAvatar = gameCtrl.room.getAvatarInfo(playerId);
            if (null != avatar) {
                return avatar.name;
            }
        }

        return "[Unrecognized player " + playerId + "]";
    }

    public static function instantiateBitmap (name :String) :Bitmap
    {
        return ImageResource.instantiateBitmap(rsrcs, name);
    }

    public static function instantiateMovieClip (rsrcName :String, className :String,
        disableMouseInteraction :Boolean = false, fromCache :Boolean = false) :MovieClip
    {
        return SwfResource.instantiateMovieClip(
            rsrcs,
            rsrcName,
            className,
            disableMouseInteraction,
            fromCache);
    }

    public static function createSpecialStrainMovie (strain :int,
        disableMouseInteraction :Boolean = false, fromCache :Boolean = false) :MovieClip
    {
        var movie :MovieClip =
            instantiateMovieClip("blood", "cell_strain", disableMouseInteraction, fromCache);
        movie.gotoAndStop(1);

        var typeMovie :MovieClip = movie["type"];
        typeMovie = typeMovie["type"];
        typeMovie.gotoAndStop(strain + 1);

        return movie;
    }
}

}
