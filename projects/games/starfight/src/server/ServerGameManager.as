package server {

import com.whirled.ServerObject;

public class ServerGameManager extends GameManager
{
    public function ServerGameManager (mainObject :ServerObject)
    {
        super(mainObject);
    }

    override protected function createBoardController () :BoardController
    {
        return new ServerBoardController(AppContext.gameCtrl);
    }
}

}
