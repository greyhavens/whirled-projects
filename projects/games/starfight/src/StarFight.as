package {

import client.ClientGameManager;

import server.*;

import flash.display.Sprite;

/**
 * Game client entry point.
 */
[SWF(width="700", height="500")]
public class StarFight extends Sprite
{
    public function StarFight ()
    {
        _gameMgr = new ClientGameManager(this);

        // references to server-only classes, so that Flex Builder will alert me
        // to compile errors
        // TODO - remove me before shipping
        var c :Class;
        c = Server;
        c = ServerBoardController;
        c = ServerGameManager;
    }

    protected var _gameMgr :ClientGameManager;
}
}
