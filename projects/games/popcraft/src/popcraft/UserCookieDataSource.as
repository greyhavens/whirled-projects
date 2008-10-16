package popcraft {

import flash.utils.ByteArray;

public interface UserCookieDataSource
{
    function writeCookieData (cookie :ByteArray) :void;

    function readCookieData (version :int, cookie :ByteArray) :void;

    /**
     * @return the minimum cookie version this data source supports.
     */
    function get minCookieVersion () :int;

    /**
     *  Called after a read has failed. Implementations can return
     * true from this function to indicate that UserCookieManager should
     * immediately attempt to re-save data.
     */
    function cookieReadFailed () :Boolean;
}

}
