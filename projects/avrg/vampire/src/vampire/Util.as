package vampire
{
import com.threerings.util.HashMap;
import com.threerings.util.StringBuilder;
import com.whirled.contrib.simplegame.net.MessageManager;

import vampire.net.messages.AvatarChosenMsg;
import vampire.net.messages.BloodBondRequestMsg;
import vampire.net.messages.DebugMsg;
import vampire.net.messages.FeedConfirmMsg;
import vampire.net.messages.FeedRequestMsg;
import vampire.net.messages.FeedingDataMsg;
import vampire.net.messages.GameStartedMsg;
import vampire.net.messages.LineageMsg;
import vampire.net.messages.LoadBalancingMsg;
import vampire.net.messages.MovePredAfterFeedingMsg;
import vampire.net.messages.MovePredIntoPositionMsg;
import vampire.net.messages.NonPlayerIdsInRoomMsg;
import vampire.net.messages.RequestStateChangeMsg;
import vampire.net.messages.RoomNameMsg;
import vampire.net.messages.SendGlobalMsg;
import vampire.net.messages.ShareTokenMsg;
import vampire.net.messages.StartFeedingClientMsg;
import vampire.net.messages.StatsMsg;
import vampire.net.messages.SuccessfulFeedMsg;


public class Util
{
    /**
    * If n >= 1, just use the integer for the string.  Otherwise, show to 2 decimal places.
    *
    *
    */
    public static function formatNumberForFeedback (n :Number) :String
    {
        if(n >= 1) {
            return "" + int(Math.floor(n));
        }
        else {
            var nString :String = "" + n;
            return nString.substring(0, Math.min(nString.indexOf(".") + 3, nString.length));
        }
    }

    public static function getStringHash (val :String) :int
    {
        // examine at most 32 characters of the val
        var hash :int;
        var inc :int = int(Math.max(1, Math.ceil(val.length / 32)));
        for (var ii :int = 0; ii < val.length; ii += inc) {
            // hash(i) = (hash(i-1) * 33) ^ str[i]
            hash = ((hash << 5) + hash) ^ int(val.charCodeAt(ii));
        }

        return hash;
    }

    public static function initMessageManager (mgr :MessageManager) :void
    {
        mgr.addMessageType(AvatarChosenMsg);
        mgr.addMessageType(BloodBondRequestMsg);
        mgr.addMessageType(DebugMsg);
        mgr.addMessageType(FeedConfirmMsg);
        mgr.addMessageType(FeedingDataMsg);
        mgr.addMessageType(FeedRequestMsg);
        mgr.addMessageType(GameStartedMsg);
        mgr.addMessageType(LineageMsg);
        mgr.addMessageType(LoadBalancingMsg);
        mgr.addMessageType(MovePredIntoPositionMsg);
        mgr.addMessageType(MovePredAfterFeedingMsg);
        mgr.addMessageType(NonPlayerIdsInRoomMsg);
        mgr.addMessageType(RequestStateChangeMsg);
        mgr.addMessageType(RoomNameMsg);
        mgr.addMessageType(SendGlobalMsg);
        mgr.addMessageType(ShareTokenMsg);
        mgr.addMessageType(StartFeedingClientMsg);
        mgr.addMessageType(StatsMsg);
        mgr.addMessageType(SuccessfulFeedMsg);
    }

    public static function hashmapToString (h :HashMap) :String
    {
        var sb :StringBuilder = new StringBuilder();
        for each (var key :String in h.keys()) {
            sb.append("\n" + key + "=" + h.get(key));
        }
        return sb.toString();
    }
}
}
