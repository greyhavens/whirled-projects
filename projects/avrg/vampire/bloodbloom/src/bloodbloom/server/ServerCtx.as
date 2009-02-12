package bloodbloom.server {

import com.whirled.contrib.simplegame.net.BasicMessageManager;
import com.whirled.game.GameControl;

public class ServerCtx
{
    public static var gameCtrl :GameControl;
    public static var msgMgr :BasicMessageManager = new BasicMessageManager();
}

}
