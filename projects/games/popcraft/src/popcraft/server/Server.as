package popcraft.server {

import com.whirled.ServerObject;
import com.whirled.game.GameControl;

import popcraft.*;

public class Server extends ServerObject
{
    public function Server ()
    {
        _gameCtrl = new GameControl(this);
        _seatingMgr.init(_gameCtrl);

        // We don't have anything to do in single-player games
        if (_seatingMgr.numPlayers < 2) {
            return;
        }
    }

    protected var _gameCtrl :GameControl;
    protected var _seatingMgr :SeatingManager = new SeatingManager();
}

}
