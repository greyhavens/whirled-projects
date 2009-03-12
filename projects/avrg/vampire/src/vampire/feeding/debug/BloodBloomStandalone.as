package vampire.feeding.debug {

import com.whirled.avrg.AVRGameControl;
import com.whirled.contrib.simplegame.util.Rand;

import flash.display.Sprite;

import vampire.avatar.VampireBody;
import vampire.data.VConstants;
import vampire.feeding.*;
import vampire.feeding.client.*;
import vampire.feeding.server.*;

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

    public function BloodBloomStandalone ()
    {
        DEBUG_REMOVE_ME();

        BloodBloom.init(this, new DisconnectedControl(this));
        addChild(new BloodBloom(0, new PlayerFeedingData(), function () :void {}));
        if (Constants.DEBUG_FORCE_SPECIAL_BLOOD_STRAIN) {
            ClientCtx.preyBloodType =
                Rand.nextIntRange(0, VConstants.UNIQUE_BLOOD_STRAINS, Rand.STREAM_COSMETIC);
        }
    }
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
