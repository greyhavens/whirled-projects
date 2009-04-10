package vampire.feeding.debug {

import com.whirled.avrg.AVRGameControl;
import com.whirled.contrib.TimerManager;
import com.whirled.contrib.namespc.*;
import com.whirled.contrib.simplegame.util.Rand;

import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.utils.Dictionary;

import vampire.avatar.VampireBody;
import vampire.data.VConstants;
import vampire.debug.LocalPropertySubControl;
import vampire.feeding.*;
import vampire.feeding.client.*;
import vampire.feeding.net.Props;
import vampire.feeding.server.*;
import vampire.feeding.variant.Variant;

[SWF(width="1000", height="500", frameRate="30")]
public class BloodBloomStandalone extends Sprite
{
    public static function DEBUG_REMOVE_ME () :void
    {
        var c :Class;
        c = vampire.feeding.server.Server;
        c = vampire.feeding.debug.TestClient;
        c = vampire.feeding.debug.TestServer;
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
        var dummyProps :NamespacePropControl =
            new NamespacePropControl(String(0), new LocalPropertySubControl());
        dummyProps.set(Props.AI_PREY_NAME, "AI Prey");
        dummyProps.set(
            Props.PREY_BLOOD_TYPE,
            Rand.nextIntRange(0, VConstants.UNIQUE_BLOOD_STRAINS, Rand.STREAM_COSMETIC));
        dummyProps.set(Props.PREY_IS_AI, true);
        dummyProps.set(Props.VARIANT, VARIANT);
        dummyProps.set(Props.MODE_NAME, Constants.MODE_PLAYING);

        var dict :Dictionary = new Dictionary;
        dict[1] = true;
        dummyProps.set(Props.GAME_PLAYERS, dict);

        addChild(new BloodBloom(0, new PlayerFeedingData(), function () :void {}, dummyProps));
    }

    protected var _timerMgr :TimerManager = new TimerManager();

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
