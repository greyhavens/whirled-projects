package popcraft {

import com.threerings.util.Log;

import flash.utils.ByteArray;

public class UserCookieManager
{
    public function addDataSource (dataSource :UserCookieDataSource) :void
    {
        _dataSources.push(dataSource);
    }

    public function setNeedsUpdate () :void
    {
        // update immediately. is this wise?
        this.writeCookie();
    }

    public function readCookie () :void
    {
        if (AppContext.gameCtrl.isConnected()) {
            AppContext.gameCtrl.player.getUserCookie(AppContext.gameCtrl.game.getMyId(), completeLoadData);
        } else {
            this.completeLoadData(null);
        }
    }

    protected function writeCookie () :void
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

                success = AppContext.gameCtrl.player.setUserCookie(ba);
                if (!success) {
                    errString = "PlayerSubControl.setUserCookie() failed (" + ba.length + "-byte cookie too large?)";
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

    protected function completeLoadData (cookie :Object) :void
    {
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
                    success = true;
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
                this.writeCookie();
            }
        }
    }

    protected var _dataSources :Array = [];

    protected static const VERSION :int = 0;
    protected static const log :Log = Log.getLog(UserCookieManager);
}

}
