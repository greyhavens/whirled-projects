package popcraft {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.objects.*;

import flash.display.*;

import popcraft.battle.*;
import popcraft.data.*;

public class UnitPurchaseMeter extends SceneObject
{
    public function UnitPurchaseMeter (unitType :uint)
    {
        _unitType = unitType;

        var data :UnitData = Constants.UNIT_DATA[_unitType];

        var yOffset :Number = 0;

        // how much does it cost?
        for (var resType :uint = 0; resType < Constants.RESOURCE__LIMIT; ++resType) {
            var resData :ResourceData = Constants.getResource(resType);
            var resCost :int = data.getResourceCost(resType);

            if (resCost == 0) {
                continue;
            }

            // create a little rectangle indicating the
            // resource type
            var shape :Shape = new Shape();
            var g :Graphics = shape.graphics;
            g.beginFill(resData.color);
            g.drawRect(0, yOffset, RECT_WIDTH, METER_HEIGHT);
            g.endFill();
            _sprite.addChild(shape);


            // create a new meter
            var rectMeter :RectMeter = new RectMeter();
            rectMeter.width = METER_WIDTH;
            rectMeter.height = METER_HEIGHT;
            rectMeter.minValue = 0;
            rectMeter.maxValue = resCost;
            rectMeter.value = resCost;
            rectMeter.foregroundColor = resData.color;
            rectMeter.backgroundColor = 0x7B7A78;
            rectMeter.outlineColor = 0;
            rectMeter.x = RECT_WIDTH + 1;
            rectMeter.y = yOffset;

            rectMeter.updateDisplay();

            var textMeter :IntTextMeter = new IntTextMeter();
            textMeter.minValue = 0;
            textMeter.maxValue = resCost;
            textMeter.value = 0;
            textMeter.textColor = 0x000000;

            textMeter.updateDisplay();

            textMeter.x = rectMeter.x + (rectMeter.width * 0.5) - (textMeter.width * 0.5);
            textMeter.y = rectMeter.y + (rectMeter.height * 0.5) - (textMeter.height * 0.5);

            yOffset += METER_HEIGHT + METER_YOFFSET;

            GameContext.gameMode.addObject(rectMeter, _sprite);
            GameContext.gameMode.addObject(textMeter, _sprite);
            _meters.push(rectMeter);
            _meters.push(textMeter);
        }

        updateDisplay();
    }

    override protected function removedFromDB () :void
    {
        for each (var meter :SimObject in _meters) {
            meter.destroySelf();
        }
    }

    override protected function update (dt :Number) :void
    {
        updateDisplay();
    }

    protected function updateDisplay () :void
    {
        var data :UnitData = Constants.UNIT_DATA[_unitType];

        var meterIndex :uint = 0;
        for (var resType :uint = 0; resType < Constants.RESOURCE__LIMIT; ++resType) {

            var resCost :int = data.getResourceCost(resType);

            if (resCost == 0) {
                continue;
            }

            var rectMeter :RectMeter = (_meters[meterIndex] as RectMeter);
            var textMeter :IntTextMeter = (_meters[meterIndex + 1] as IntTextMeter);
            meterIndex += 2;

            var resAmount :int = GameContext.localPlayerData.getResourceAmount(resType);

            var meterValue :Number = Math.min(resCost, resAmount);
            rectMeter.value = meterValue;
            textMeter.value = meterValue;
        }
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _sprite :Sprite = new Sprite();
    protected var _meters :Array = new Array();
    protected var _unitType :uint;

    protected static const METER_WIDTH :int = 36;
    protected static const METER_HEIGHT :int = 14;
    protected static const METER_YOFFSET :int = 4;
    protected static const RECT_WIDTH :int = 3;
}

}
