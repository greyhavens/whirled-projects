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

}
}