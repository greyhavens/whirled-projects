package bloodbloom {

import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.geom.Point;
import flash.text.TextField;

public class PredatorBloodMeter extends SceneObject
{
    public function PredatorBloodMeter ()
    {
        _sprite = new Sprite();
        _tf = UIBits.createText("", 1.5);
        _sprite.addChild(_tf);
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    override protected function update (dt :Number) :void
    {
        if (_displayedBloodCount != _lastDisplayedBloodCount) {
            UIBits.initTextField(_tf, "Predator Blood: " + _displayedBloodCount, 1.5, 0, 0xff0000);
            _lastDisplayedBloodCount = _displayedBloodCount;
        }
    }

    public function showGatherAnim (x :Number, y :Number) :void
    {
        var cellSprite :Sprite = SpriteUtil.createSprite();
        cellSprite.addChild(ClientCtx.createCellBitmap(Constants.CELL_RED));
        var cellObj :SimpleSceneObject = new SimpleSceneObject(cellSprite);
        var loc :Point = this.displayObject.globalToLocal(new Point(x, y));
        cellObj.x = loc.x;
        cellObj.y = loc.y;
        ClientCtx.gameMode.addObject(cellObj, this.displayObject as DisplayObjectContainer);

        // fly the cell to the meter, make it disappear, increase the blood count
        cellObj.addTask(new SerialTask(
            LocationTask.CreateSmooth(0, 0, 1),
            new FunctionTask(
                function () :void {
                    _displayedBloodCount++;
                }),
            new SelfDestructTask()));

        cellObj.addTask(After(0.9, new AlphaTask(0, 0.1)));

        _bloodCount++;
    }

    protected var _sprite :Sprite;
    protected var _tf :TextField;
    protected var _bloodCount :int;
    protected var _lastDisplayedBloodCount :int = -1;
    protected var _displayedBloodCount :int;
}

}
