package vampire
{
    import com.whirled.contrib.simplegame.net.MessageManager;

    import vampire.data.VConstants;
    import vampire.net.messages.BloodBondRequestMsg;
    import vampire.net.messages.FeedConfirmMsg;
    import vampire.net.messages.FeedRequestMsg;
    import vampire.net.messages.NonPlayerIdsInRoomMsg;
    import vampire.net.messages.RequestStateChangeMsg;
    import vampire.net.messages.ShareTokenMsg;
    import vampire.net.messages.SuccessfulFeedMsg;


public class Util
{
    /**
    * If n >= 1, just use the integer for the string.  Otherwise, show to 2 decimal places.
    *
    *
    */
    public static function formatNumberForFeedback( n :Number ) :String
    {
        if( n >= 1) {
            return "" + int( Math.floor( n ));
        }
        else {
            var nString :String = "" + n;
            return nString.substring( 0, Math.min( nString.indexOf(".") + 3, nString.length));
        }
    }


    /**
    * You cannot be a sire from feeding unless you are a connected to the official Lineage,
    * meaning that your great-great-great sire is the Übervamp.
    *
    */
    public static function isProgenitor (playerId :int) :Boolean
    {
        return playerId == VConstants.UBER_VAMP_ID;
    }


    public static function initMessageManager (mgr :MessageManager) :void
    {
        mgr.addMessageType(BloodBondRequestMsg);
        mgr.addMessageType(FeedConfirmMsg);
        mgr.addMessageType(FeedRequestMsg);
        mgr.addMessageType(NonPlayerIdsInRoomMsg);
        mgr.addMessageType(RequestStateChangeMsg);
        mgr.addMessageType(ShareTokenMsg);
        mgr.addMessageType(SuccessfulFeedMsg);
    }




}
}