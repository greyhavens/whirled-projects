package popcraft {

import flash.utils.ByteArray;

public interface UserCookieDataSource
{
    function writeCookieData (cookie :ByteArray) :void;
    function readCookieData (cookie :ByteArray) :void;

    // Called after a read has failed. Implementations can return
    // true from this function to indicate that UserCookieManager should
    // immediately attempt to re-save data.
    function readFailed () :Boolean;
}

}
