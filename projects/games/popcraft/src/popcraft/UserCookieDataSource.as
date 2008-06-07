package popcraft {

import flash.utils.ByteArray;

public interface UserCookieDataSource
{
    function writeCookieData (cookie :ByteArray) :void;
    function readCookieData (cookie :ByteArray) :void;
}

}
