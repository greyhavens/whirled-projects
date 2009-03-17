package vampire
{
    import com.whirled.contrib.simplegame.net.MessageManager;

    import vampire.data.VConstants;
    import vampire.net.messages.BloodBondRequestMsg;
    import vampire.net.messages.FeedConfirmMsg;
    import vampire.net.messages.FeedRequestMsg;
    import vampire.net.messages.NonPlayerIdsInRoomMsg;
    import vampire.net.messages.RequestActionChangeMsg;
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
    * You cannot be a sire from feeding unless you are a progenitor vampire. So far, that
    * means us developers.
    *
    */
    public static function isProgenitor( playerId :int ) :Boolean
    {
        return playerId == VConstants.UBER_VAMP_ID;
        //1877 == ubervamp on dev
//         || //Ragbeard
//               playerId == 1769  || //Capital-T-Tim
//               playerId == 12     ;  //Nemo
//               playerId == 1   ;   //debugging
    }


    public static function initMessageManager (mgr :MessageManager) :void
    {
        mgr.addMessageType(BloodBondRequestMsg);
        mgr.addMessageType(FeedConfirmMsg);
        mgr.addMessageType(FeedRequestMsg);
        mgr.addMessageType(NonPlayerIdsInRoomMsg);
        mgr.addMessageType(RequestActionChangeMsg);
        mgr.addMessageType(ShareTokenMsg);
        mgr.addMessageType(SuccessfulFeedMsg);

    }




}
}