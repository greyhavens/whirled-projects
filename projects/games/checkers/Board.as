package {

import com.whirled.game.GameControl;

public class Board
{

    public function Board (gameCtrl :GameControl, lengthOfSide :int = 8)
    {
        _gameCtrl = gameCtrl;
        _lengthOfSide = lengthOfSide;
    }

    public function initialize () :void
    {
    }

    public function getDisc (index :int) :int
    {
    }

    public function getDiscByCoords (x :int, y :int) :int
    {
    }

    public function getMoves (playerIdx :int) :Array
    {
    }

    public function playDisc (index :int, playerIdx :int) :void
    {
    }
    
   public function isValidMove (index :int, playerIdx :int) :Boolean
    {
    }


    protected function setDisc (x :int, y :int, playerIdx :int) :void
    {
    }


    /** The length of one side of the board. */
    protected var _lengthOfSide :int;

    protected var _gameCtrl :GameControl;
}
}
