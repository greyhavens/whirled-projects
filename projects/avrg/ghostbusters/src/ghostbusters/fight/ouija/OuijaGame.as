package ghostbusters.fight.ouija {
    
import flash.display.Sprite;

import ghostbusters.fight.core.MainLoop;

[SWF(width="280", height="222", frameRate="30")]
public class OuijaGame extends Sprite
{
    public function OuijaGame()
    {
        var mainLoop :MainLoop = new MainLoop(this);
        mainLoop.run();
        mainLoop.changeMode(new OuijaGameMode());
    }
}

}

import ghostbusters.fight.core.AppMode;
import ghostbusters.fight.ouija.Board;
import ghostbusters.fight.ouija.Cursor;

class OuijaGameMode extends AppMode
{
    public function OuijaGameMode ()
    {
    }
    
    override public function setup () :void
    {
        var board :Board = new Board();
        this.addObject(board, this);
        this.addObject(new Cursor(board), board.displayObjectContainer);
    }
}