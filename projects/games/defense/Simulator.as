package {

/**
 * Contains all the game logic for directing critters on the map.
 */
public class Simulator
{
    public function Simulator (board :Board, game :Game)
    {
        _board = board;
        _game = game;
    }

    public function processSpawners (spawners :Array) :void
    {
        for each (var spawner :Spawner in spawners) {
                spawner.tick();
            }
    }

    protected var _board :Board;
    protected var _game :Game;
}
}
