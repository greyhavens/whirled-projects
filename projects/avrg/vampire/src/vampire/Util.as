package vampire
{
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
        return playerId == 23340 || //Ragbeard
               playerId == 1769  || //Capital-T-Tim
               playerId == 12   ||   //Nemo
               playerId == 1   ;   //debugging
    }

}
}