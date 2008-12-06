package redrover.game {

public class PlayerMove
{
    public var direction :int;
    public var atGridX :int;
    public var atGridY :int;

    public function PlayerMove (direction :int, atGridX :int = -1, atGridY :int = -1)
    {
        this.direction = direction;
        this.atGridX = atGridX;
        this.atGridY = atGridY;
    }

    public function get doAsap () :Boolean
    {
        return (atGridX < 0 || atGridY < 0);
    }

    public function get atPixelX () :Number
    {
        return (atGridX + 0.5) * GameContext.levelData.cellSize;
    }

    public function get atPixelY () :Number
    {
        return (atGridY + 0.5) * GameContext.levelData.cellSize;
    }
}

}
