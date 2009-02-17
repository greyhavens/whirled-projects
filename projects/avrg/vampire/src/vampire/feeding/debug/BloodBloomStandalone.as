package vampire.feeding.debug {

import com.whirled.avrg.AVRGameControl;

import flash.display.Sprite;

import vampire.feeding.client.BloodBloom;
import vampire.feeding.server.*;

[SWF(width="700", height="500", frameRate="30")]
public class BloodBloomStandalone extends Sprite
{
    public static function DEBUG_REMOVE_ME () :void
    {
        var c :Class;
        c = vampire.feeding.server.Server;
        c = vampire.feeding.debug.TestClient;
        c = vampire.feeding.debug.TestServer;
    }

    public function BloodBloomStandalone ()
    {
        DEBUG_REMOVE_ME();

        BloodBloom.init(this, new DisconnectedControl(this));
        addChild(new BloodBloom(0, function () :void {}));
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
