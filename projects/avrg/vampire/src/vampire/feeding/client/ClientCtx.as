package vampire.feeding.client {

import com.threerings.util.ArrayUtil;
import com.threerings.util.HashSet;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGameControl;
import com.whirled.contrib.simplegame.MainLoop;
import com.whirled.contrib.simplegame.audio.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.namespc.*;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.geom.Rectangle;
import flash.utils.getTimer;

import vampire.feeding.*;
import vampire.feeding.net.*;
import vampire.feeding.variant.Settings;

public class ClientCtx
{
    // Initialized just once
    public static var gameCtrl :AVRGameControl;
    public static var mainLoop :MainLoop;
    public static var rsrcs :ResourceManager;
    public static var audio :AudioManager;

    // Initialized every time a new feeding takes place
    public static var props :NamespacePropGetControl;
    public static var msgMgr :ClientMsgMgr;
    public static var gameCompleteCallback :Function;
    public static var playerData :PlayerFeedingData;
    public static var allPlayerIds :Array;  // includes people waiting in the lobby for next round
    public static var gamePlayerIds :Array;
    public static var awardedTrophies :HashSet;
    public static var lastRoundResults :RoundOverMsg;
    public static var settings :Settings;

    public static function get isCorruption () :Boolean
    {
        return settings.scoreCorruption;
    }

    public static function init () :void
    {
        props = null;
        msgMgr = null;
        gameCompleteCallback = null;
        playerData = null;
        allPlayerIds = null;
        gamePlayerIds = null;
        awardedTrophies = new HashSet();
        lastRoundResults = null;
        settings = null;
    }

    public static function centerInRoom (disp :DisplayObject) :void
    {
        if (isConnected) {
            var roomBounds :Rectangle = gameCtrl.local.getPaintableArea(false);
            if (roomBounds != null) {
                var objBounds :Rectangle = disp.getBounds(disp);
                disp.x = ((roomBounds.width - objBounds.width) * 0.5) - objBounds.x;
                disp.y = ((roomBounds.height - objBounds.height) * 0.5) - objBounds.y;
            }
        }
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

            log.info("Awarded trophy '" + trophyName + "'");
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

    public static function get preyId () :int
    {
        return (props.get(Props.PREY_ID) as int);
    }

    public static function get aiPreyName () :String
    {
        return (props.get(Props.AI_PREY_NAME) as String);
    }

    public static function get preyBloodType () :int
    {
        if (Constants.DEBUG_FORCE_SPECIAL_BLOOD_STRAIN) {
            return 0;
        } else {
            return (props.get(Props.PREY_BLOOD_TYPE) as int);
        }
    }

    public static function get preyIsAi () :Boolean
    {
        return (props.get(Props.PREY_IS_AI) as Boolean);
    }

    public static function get lobbyLeaderId () :int
    {
        return (props.get(Props.LOBBY_LEADER) as int);
    }

    public static function get bloodBondProgress () :int
    {
        return (props.get(Props.BLOOD_BOND_PROGRESS) as int);
    }

    public static function get isLobbyLeader () :Boolean
    {
        return (lobbyLeaderId == localPlayerId);
    }

    public static function get isPrey () :Boolean
    {
        return (localPlayerId == preyId);
    }

    public static function get isPredator () :Boolean
    {
        return (!isPrey);
    }

    public static function isPlayer (playerId :int) :Boolean
    {
        return ArrayUtil.contains(allPlayerIds, playerId);
    }

    public static function get playerCanCollectPreyStrain () :Boolean
    {
        return (isPredator &&
                !preyIsAi &&
                playerData.canCollectStrainFromPlayer(preyBloodType, preyId));
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
            var name :String = gameCtrl.game.getOccupantName(playerId);
            if (name != null) {
                return name;
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

    protected static const log :Log = Log.getLog(ClientCtx);
}

}
