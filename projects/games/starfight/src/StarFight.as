package {

import client.ClientAppController;

import flash.display.Sprite;
import flash.geom.Rectangle;

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

        // clip games to the bounds of the player
        this.scrollRect = new Rectangle(0, 0, Constants.GAME_WIDTH, Constants.GAME_HEIGHT);

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
