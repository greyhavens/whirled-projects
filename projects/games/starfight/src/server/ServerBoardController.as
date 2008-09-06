package server {

import com.whirled.game.GameControl;

import flash.utils.ByteArray;

public class ServerBoardController extends BoardController
{
    public function ServerBoardController (gameCtrl :GameControl)
    {
        super(gameCtrl);
    }

    override public function loadBoard (boardLoadedCallback :Function) :void
    {
        createBoard();
        boardLoadedCallback();
    }

    protected function createBoard () :void
    {
        this.width = 100;
        this.height = 100;

        loadObstacles();
        var maxPowerups :int = Math.max(1, width * height / MIN_TILES_PER_POWERUP);
        _powerups = new Array(maxPowerups);
        _mines = new Array(MAX_MINES);

        _gameCtrl.doBatch(function () :void {
            setImmediate(Constants.PROP_OBSTACLES, new Array(_obstacles.length));
            /*for (var ii :int; ii < _obstacles.length; ii++) {
                setAtImmediate(Constants.PROP_OBSTACLES,
                        _obstacles[ii].writeTo(new ByteArray()), ii);
            }*/
            setImmediate(Constants.PROP_POWERUPS, new Array(_powerups.length));
            setImmediate(Constants.PROP_MINES, new Array(MAX_MINES));
            setImmediate(Constants.PROP_BOARD, writeTo(new ByteArray()));
        });
    }

    override public function roundEnded () :void
    {
        super.roundEnded();

        _gameCtrl.doBatch(function () :void {
            setImmediate(Constants.PROP_OBSTACLES, null);
            setImmediate(Constants.PROP_POWERUPS, null);
            setImmediate(Constants.PROP_MINES, null);
            setImmediate(Constants.PROP_BOARD, null);
        });
    }
}

}
