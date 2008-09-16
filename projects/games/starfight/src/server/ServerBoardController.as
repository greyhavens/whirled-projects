package server {

import com.whirled.game.GameControl;

import flash.utils.ByteArray;

public class ServerBoardController extends BoardController
{
    public function ServerBoardController (gameCtrl :GameControl)
    {
        super(gameCtrl);
    }

    public function createBoard () :void
    {
        this.width = 100;
        this.height = 100;

        createObstacles();
        var maxPowerups :int = Math.max(1, width * height / MIN_TILES_PER_POWERUP);
        _powerups = new Array(maxPowerups);
        _mines = new Array(MAX_MINES);

        _gameCtrl.doBatch(function () :void {
            var obstacleBytes :Array = new Array(_obstacles.length);
            for (var ii :int = 0; ii < _obstacles.length; ii++) {
                obstacleBytes[ii] = Obstacle(_obstacles[ii]).toBytes();
            }
            setImmediate(Constants.PROP_OBSTACLES, obstacleBytes);
            setImmediate(Constants.PROP_POWERUPS, new Array(_powerups.length));
            setImmediate(Constants.PROP_MINES, new Array(MAX_MINES));
            setImmediate(Constants.PROP_BOARD, toBytes());
        });
    }

    protected function createObstacles () :void
    {
        _obstacles = [];

        var ii :int;
        var index :int;

        // TODO Load obstacles from a file instead of random.
        var numAsteroids :int = width*height/100;
        for (ii = 0; ii < numAsteroids; ii++) {
            var type :int = 0;
            switch (int(Math.floor(Math.random()*2.0))) {
            case 0: type = Obstacle.ASTEROID_1; break;
            case 1: type = Obstacle.ASTEROID_2; break;
            }
            _obstacles.push(new Obstacle(
                type, 1 + Math.random()*(width-2), 1+Math.random()*(height-2)));
            _obstacles[_obstacles.length - 1].index = index++;
        }

        // Place a wall around the outside of the board.

        for (ii = 0; ii < height; ii++) {
            if (ii == 0) {
                _obstacles.push(new Obstacle(Obstacle.WALL, 0, ii, 1, height));
            } else {
                _obstacles.push(new Obstacle(Obstacle.WALL, 0, ii));
            }
            _obstacles[_obstacles.length - 1].index = index++;
            if (ii == 0) {
                _obstacles.push(new Obstacle(Obstacle.WALL, width-1, ii, 1, height));
            } else {
                _obstacles.push(new Obstacle(Obstacle.WALL, width-1, ii));
            }
            _obstacles[_obstacles.length - 1].index = index++;
        }

        for (ii = 0; ii < width; ii++) {
            if (ii == 0) {
                _obstacles.push(new Obstacle(Obstacle.WALL, ii, 0, width, 1));
            } else {
                _obstacles.push(new Obstacle(Obstacle.WALL, ii, 0));
            }
            _obstacles[_obstacles.length - 1].index = index++;
            if (ii == 0) {
                _obstacles.push(new Obstacle(Obstacle.WALL, ii, height-1, width, 1));
            } else {
                _obstacles.push(new Obstacle(Obstacle.WALL, ii, height-1));
            }
            _obstacles[_obstacles.length - 1].index = index++;
        }
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
        setAtImmediate(Constants.PROP_POWERUPS, powerup.toBytes(new ByteArray()), index);
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

    override public function addMine (mine :Mine) :int
    {
        var mineIndex :int = super.addMine(mine);
        if (mineIndex >= 0) {
            setAtImmediate(Constants.PROP_MINES, mine.toBytes(new ByteArray()), mineIndex);
        }

        return mineIndex;
    }

    override public function removeMine (idx:int) :void
    {
        setAtImmediate(Constants.PROP_MINES, null, idx);
        super.removeMine(idx);
    }

    public function removeMines (shipId :int) :void
    {
        for each (var mineIndex :int in getShipMineIndices(shipId)) {
            removeMine(mineIndex);
        }
    }
}

}
