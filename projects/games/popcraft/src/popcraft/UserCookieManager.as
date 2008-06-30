package popcraft {

import com.threerings.util.Log;

import flash.utils.ByteArray;

public class UserCookieManager
{
    public static function addDataSource (dataSource :UserCookieDataSource) :void
    {
        _dataSources.push(dataSource);
    }

    public static function setNeedsUpdate () :void
    {
        // update immediately. is this wise?
        writeCookie();
    }

    public static function get isLoadingCookie () :Boolean
    {
        return _loadingCookie;
    }

    public static function readCookie () :void
    {
        if (!_loadingCookie) {
            if (AppContext.gameCtrl.isConnected()) {
                AppContext.gameCtrl.player.getCookie(completeLoadData);
                _loadingCookie = true;
            } else {
                completeLoadData(null);
            }
        }
    }

    protected static function writeCookie () :void
    {
        if (AppContext.gameCtrl.isConnected()) {
            var ba :ByteArray = new ByteArray();
            var success :Boolean;
            var errString :String;
            try {
                // future-proof ourselves with a version number
                ba.writeShort(VERSION);

                for each (var dataSource :UserCookieDataSource in _dataSources) {
                    dataSource.writeCookieData(ba);
                }
                ba.compress();

                success = AppContext.gameCtrl.player.setCookie(ba);
                if (!success) {
                    errString = "PlayerSubControl.setCookie() failed (" + ba.length + "-byte cookie too large?)";
                }

            } catch (e :Error) {
                success = false;
                errString = e.message;
            }

            if (success) {
                log.info("successfully saved user cookie");
            } else {
                log.warning("failed to save user cookie: " + errString);
            }
        }
    }

    protected static function completeLoadData (cookie :Object, ...unused) :void
    {
        _loadingCookie = false;

        var success :Boolean;
        var errString :String;
        var ba :ByteArray = cookie as ByteArray;
        if (null == ba) {
            errString = "cookie does not exist";
        } else {
            try {
                ba.uncompress();
                var version :int = ba.readShort();
                if (version != VERSION) {
                    errString = "bad cookie version (expected '" + VERSION + "', saw '" + version + "')";
                } else {
                    for each (var dataSource :UserCookieDataSource in _dataSources) {
                        dataSource.readCookieData(ba);
                    }

                    if (ba.bytesAvailable != 0) {
                        var totalSize :uint = ba.length;
                        var expectedSize :uint = ba.position;
                        errString = "cookie was too large (expected " + expectedSize + "b, got " + totalSize + "b)";
                    } else {
                        success = true;
                    }
                }
            } catch (e :Error) {
                errString = e.message;
            }
        }

        if (success) {
            log.info("successfully loaded user cookie");
        } else {
            log.warning("failed to load user cookie: " + errString);
            var resave :Boolean;
            for each (dataSource in _dataSources) {
                resave = (resave || dataSource.readFailed());
            }

            if (resave) {
                writeCookie();
            }
        }
    }

    protected static var _dataSources :Array = [];
    protected static var _loadingCookie :Boolean;

    protected static const VERSION :int = 0;
    protected static const log :Log = Log.getLog(UserCookieManager);
}

}
