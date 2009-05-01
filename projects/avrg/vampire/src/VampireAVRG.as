package {

import com.whirled.contrib.avrg.debug.fakeavrg.AVRGameControlFake;

import flash.display.Sprite;

import vampire.client.ClientContext;
import vampire.client.VampireMain;
import vampire.data.VConstants;
import vampire.server.GameServer;
import vampire.server.ServerContext;


[SWF(width="1000", height="600")]
public class VampireAVRG extends Sprite
{
    public function VampireAVRG()
    {
        VConstants.LOCAL_DEBUG_MODE = true;
        ServerContext.server = new GameServer();
        ClientContext.init(new AVRGameControlFake(this));
        addChild(new VampireMain());
        graphics.lineStyle(2,0);
        graphics.drawRect(0, 0, ClientContext.ctrl.local.getRoomBounds()[0] - 2,ClientContext.ctrl.local.getRoomBounds()[1] - 2);
        graphics.lineStyle(2,0);
        graphics.drawRect(0, 0, ClientContext.ctrl.local.getPaintableArea().width - 2,ClientContext.ctrl.local.getPaintableArea().height - 2);

    }
}
}
