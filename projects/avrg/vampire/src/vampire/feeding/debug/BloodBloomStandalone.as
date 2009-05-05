package vampire.feeding.debug {

import com.threerings.util.Log;
import com.whirled.avrg.AVRGameControl;
import com.whirled.contrib.TimerManager;
import com.whirled.contrib.namespc.*;
import com.whirled.contrib.simplegame.util.Rand;

import flash.display.DisplayObjectContainer;
import flash.display.Sprite;

import vampire.avatar.VampireBody;
import vampire.data.VConstants;
import vampire.feeding.*;
import vampire.feeding.client.*;
import vampire.feeding.server.*;
import vampire.feeding.variant.Variant;

[SWF(width="1000", height="500", frameRate="30")]
public class BloodBloomStandalone extends Sprite
{
    public static function DEBUG_REMOVE_ME () :void
    {
        var c :Class;
        c = vampire.feeding.server.Server;
        c = vampire.feeding.debug.FeedingTestClient;
        c = vampire.feeding.debug.FeedingTestServer;
        c = vampire.avatar.VampireBody;
    }

    public function BloodBloomStandalone (parent :DisplayObjectContainer = null)
    {
        DEBUG_REMOVE_ME();

        BloodBloom.init(this, new DisconnectedControl(parent == null ? this : parent));
        loadLevelPackResources();
    }

    protected function loadLevelPackResources () :void
    {
        ClientCtx.rsrcs.queueResourceLoad(
                        "sound",
                        "mus_main_theme",
                        { embeddedClass: MUS_MAIN_THEME, type: "music" });
        ClientCtx.rsrcs.loadQueuedResources(
            startGame,
            function (err :String) :void {
                BloodBloom.log.error(err);
            });
    }

    protected function startGame () :void
    {
        var game :FeedingClient = FeedingClient.create(FeedingClientSettings.spSettings(
            "Standalone Prey",
            Rand.nextIntRange(0, VConstants.UNIQUE_BLOOD_STRAINS, Rand.STREAM_COSMETIC),
            VARIANT,
            new PlayerFeedingData(),
            function () :void {
                game.shutdown();
                game.parent.removeChild(game);
            },
            null));
    }

    protected var _timerMgr :TimerManager = new TimerManager();

    protected static var log :Log = Log.getLog(BloodBloomStandalone);

    [Embed(source="../../../../rsrc/feeding/music.mp3")]
    protected static const MUS_MAIN_THEME :Class;

    protected static const VARIANT :int = Variant.CORRUPTION;
}

}

import com.whirled.avrg.AVRGameControl;
import flash.display.DisplayObject;

class DisconnectedControl extends AVRGameControl
{
    public function DisconnectedControl (disp :DisplayObject)
    {
        super(disp);
    }

    override public function isConnected () :Boolean
    {
        return false;
    }
}
