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
            for (var ii :int; ii < _obstacles.length; ii++) {
                setAtImmediate(Constants.PROP_OBSTACLES,
                        _obstacles[ii].writeTo(new ByteArray()), ii);
            }
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

    public function addRandomPowerup (...ignored) :void
    {
        for (var ii :int = 0; ii < _powerups.length; ii++) {
            if (_powerups[ii] == null) {
                var x :int = Math.random() * width;
                var y :int = Math.random() * height;

                var repCt :int = 0;

                while (getObstacleAt(x, y) ||
                        (getObjectIdx(x+0.5, y+0.5, x+0.5, y+0.5, 0.1, _powerups) != -1)) {
                    x = Math.random() * width;
                    y = Math.random() * height;

                    // Safety valve - if we can't find anything after 100
                    //  tries, bail.
                    if (repCt++ > 100) {
                        return;
                    }
                }

                addPowerup(new Powerup(Math.random() * Powerup.COUNT, x, y), ii);
                return;
            }
        }
    }

    public function addHealthPowerup (x :int, y :int) :void
    {
        for (var ii :int = 0; ii < _powerups.length; ii++) {
            if (_powerups[ii] == null) {
                addPowerup(new Powerup(Powerup.HEALTH, x, y), ii);
                return;
            }
        }
    }

    protected function addPowerup (powerup :Powerup, index :int) :void
    {
        setAtImmediate(Constants.PROP_POWERUPS, powerup.writeTo(new ByteArray()), index);
        //powerupAdded(powerup, index);
    }

    public function handleMineCollisions (ship :Ship, oldX :Number, oldY :Number) :void
    {
        var mineIdx :int = getObjectIdx(oldX, oldY, ship.boardX, ship.boardY,
            Constants.getShipType(ship.shipTypeId).size, _mines);
        if (mineIdx != -1) {
            var mine :Mine = Mine(_mines[mineIdx]);
            if (mine.ownerId != ship.shipId) {
                AppContext.game.hitShip(ship, mine.bX, mine.bY, mine.ownerId, mine.dmg);
                removeMine(mineIdx);
            }
        }
    }
}

}
