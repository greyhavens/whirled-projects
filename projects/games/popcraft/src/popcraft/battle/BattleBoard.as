package popcraft.battle {

import popcraft.*;
import popcraft.battle.geom.*;

public class BattleBoard
{
    public function BattleBoard (width :int, height :int)
    {
        _width = width;
        _height = height;

        _collisionGrid = new AttractRepulseGrid(_width, _height, Constants.UNIT_GRID_CELL_SIZE);
    }

    public function get collisionGrid () :AttractRepulseGrid
    {
        return _collisionGrid;
    }

    protected var _width :int;
    protected var _height :int;
    protected var _collisionGrid :AttractRepulseGrid;
}

}
