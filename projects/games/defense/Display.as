package {

import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;

public class Display extends Sprite
{
    public function Display (game :Defense, controller :Controller)
    {
        AssetFactory.makeTower(AssetFactory.TOWER_DEFAULT);
        _game = game;
        _controller = controller;
        
        initBoard();
    }

    public function handleUnload (event : Event) : void
    {
        trace("DISPLAY UNLOAD");
    }

    public function addTower (type :int) :TowerSprite
    {
        var t :TowerSprite = new TowerSprite(type);
        _towers.push(t);
        _board.addChild(t);
        return t;
    }

    public function removeTower (tower :TowerSprite) :void
    {
        var ii :int = _towers.indexOf(tower);
        if (ii != -1) {
            _towers.splice(ii, 1);
            removeChild(tower);
        }
    }

    /** Initializes the empty board. */
    protected function initBoard () :void
    {
        _board = new Sprite();
        _board.x = Properties.pixelBoardLeft;
        _board.y = Properties.pixelBoardTop;
        addChild(_board);

        var bg :Shape = new Shape();
        _board.addChild(bg);
        
        var g :Graphics = bg.graphics;
        g.clear();
        g.beginFill(0x0000ff, 0.1);
        g.drawRoundRect(0, 0, Properties.pixelWidth, Properties.pixelHeight, 5, 5);
        g.endFill();

        // now draw the grid
        g.lineStyle(1, 0x000000, 0.1);
        var colwidth :int = Properties.pixelWidth / Properties.boardWidth;
        var rowheight :int = Properties.pixelHeight / Properties.boardHeight;
        for (var col :int = 0; col <= Properties.boardWidth; col++) {
            g.moveTo(col * colwidth, 0);
            g.lineTo(col * colwidth, Properties.pixelHeight);
        }
        for (var row :int = 0; row <= Properties.boardHeight; row++) {
            g.moveTo(0, row * rowheight);
            g.lineTo(Properties.pixelWidth, row * rowheight);
        }
    }
    
    /** Simple gridded board display. */
    protected var _board :Sprite;

    protected var _towers :Array = new Array(); // of TowerSprite
    
    protected var _game :Defense;
    protected var _controller :Controller;
}
}
