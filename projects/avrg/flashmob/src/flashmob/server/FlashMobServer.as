package flashmob.server {

import com.whirled.ServerObject;
import com.whirled.avrg.AVRServerGameControl;

public class FlashMobServer extends ServerObject
{
    public function FlashMobServer ()
    {
        ServerContext.gameCtrl = new AVRServerGameControl(this);
    }
}

}
