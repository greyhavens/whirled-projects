package {

import client.ClientAppController;

import flash.display.Sprite;

import server.*;

/**
 * Game client entry point.
 */
[SWF(width="700", height="500")]
public class StarFight extends Sprite
{
    public function StarFight ()
    {
        _appCtrl = new ClientAppController(this);

        // references to server-only classes, so that Flex Builder will alert me
        // to compile errors
        // TODO - remove me before shipping
        var c :Class;
        c = Server;
        c = ServerBoardController;
        c = ServerGameController;
    }

    protected var _appCtrl :ClientAppController;
}

}
