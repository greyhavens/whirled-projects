package server {

import com.whirled.ServerObject;
import com.whirled.net.PropertyChangedEvent;

import flash.utils.ByteArray;

public class ServerGameManager extends GameManager
{
    public function ServerGameManager (mainObject :ServerObject)
    {
        super(mainObject);
        setup();
    }

    override protected function setup () :void
    {
        super.setup();
        setImmediate(Constants.PROP_GAMESTATE, Constants.STATE_PRE_ROUND);
    }

    override protected function propertyChanged (event:PropertyChangedEvent) :void
    {
        super.propertyChanged(event);
    }

    override protected function createBoardController () :BoardController
    {
        return new ServerBoardController(AppContext.gameCtrl);
    }

    override public function addShip (id :int, ship :Ship) :void
    {
        super.addShip(id, ship);

        // the server is in charge of starting the round when enough players join
        if (_population >= 2 && _gameState == Constants.STATE_PRE_ROUND) {
            log.info("Starting round...");
            setImmediate(Constants.PROP_GAMESTATE, Constants.STATE_IN_ROUND);
        }
    }
}

}
