package {

import flash.geom.Point;
import flash.display.Sprite;
import flash.display.DisplayObject;

public class GridPanel extends Sprite
{
    public function GridPanel (widths :Array, heights :Array)
    {
        function sizesToPositions (sizes :Array) :Array {
            var sum :int = 0;
            var pos :Array = [];
            for each (var size :int in sizes) {
                pos.push(sum);
                sum += size;
            }
            pos.push(sum);
            return pos;
        }

        _columns = sizesToPositions(widths);
        _rows = sizesToPositions(heights);
    }

    public function addCell (
        column :int, 
        row :int, 
        contents :DisplayObject) :void
    {
        addChild(contents);
        contents.x = _columns[column];
        contents.y = _rows[row];
    }

    public function getCellSize (column :int, row :int) :Point
    {
        return new Point(
            _columns[column + 1] - _columns[column],
            _rows[row + 1] - _rows[row]);
    }

    public function get numColumns () :int
    {
        return _columns.length - 1;
    }

    public function get numRows () :int
    {
        return _rows.length - 1;
    }

    protected var _rows :Array = [];
    protected var _columns :Array = [];
}

}
