package {

import flash.display.Sprite;
import flash.geom.Point;

public class TestPanel extends TabPanel
{
    function TestPanel ()
    {
        addTab("r", new Button("Red"), new Color(0xff0000));
        addTab("g", new Button("Green"), new Color(0x00ff00));
        addTab("b", new Button("Blue"), new Color(0x0000ff));

        var grid :GridPanel = new GridPanel([150, 150, 200, 200], [50, 50, 100, 100, 50, 150]);
        for (var x :int = 0; x < grid.numColumns; ++x) {
            for (var y :int = 0; y < grid.numRows; ++y) {
                var r :uint = int(255 * (y + 1) / grid.numRows);
                var g :uint = int(255 * (x + 1) / grid.numColumns);
                var color :uint = (r << 16) | (g << 8);
                var size :Point = grid.getCellSize(x, y);
                grid.addCell(x, y, new Color(color, size.x, size.y));
            }
        }

        addTab("grid", new Button("Grid"), grid);

        addTab("params", new Button("Params"), new ParameterPanel([
            new Parameter("p1", int),
            new Parameter("p2", String),
            new Parameter("p3", int, false),
            new Parameter("p4", String, false),
            ]));
    }
}
}

import flash.display.Sprite;

class Color extends Sprite
{
    public function Color (
        color :uint, 
        width :int = 700, 
        height :int = 500)
    {
        graphics.beginFill(color);
        graphics.drawRect(0, 0, width, height);
        graphics.endFill();
    }
}

