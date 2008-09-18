package starfight {

import flash.display.Sprite;

import starfight.client.ClientAppController;
import starfight.server.*;

/**
 * Game client entry point.
 */
[SWF(width="700", height="500")]
public class StarFight extends Sprite
{
    public function StarFight ()
    {
        _appCtrl = new ClientAppController(this);

        var c :Class;
        c = Server;
        c = ServerAppController;
        c = ServerBoardController;
        c = ServerContext;
        c = ServerGameController;
        c = ServerShip;
    }

    protected var _appCtrl :ClientAppController;
}

}
