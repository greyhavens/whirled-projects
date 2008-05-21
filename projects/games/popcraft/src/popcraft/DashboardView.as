package popcraft {

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.SwfResource;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Point;
import flash.text.TextField;

import popcraft.data.ResourceData;

public class DashboardView extends SceneObject
{
    public function DashboardView ()
    {
        _movie = SwfResource.instantiateMovieClip("dashboard", "dashboard_sym");
        var puzzleFrame :MovieClip = this.puzzleFrame;

        // setup resources
        for (var resType :uint = 0; resType < Constants.RESOURCE__LIMIT; ++resType) {
            var resourceTextName :String = RESOURCE_TEXT_NAMES[resType];
            _resourceText.push(puzzleFrame[resourceTextName]);
            _resourceBars.push(null);
            _oldResourceAmounts.push(-1);
        }

        // setup unit purchase buttons
        var unitParent :MovieClip = _movie["frame_units"];
        var slotNumber :int = 1;
        for (var unitType :uint = 0; unitType < Constants.UNIT_TYPE__CREATURE_LIMIT; ++unitType) {
            if (GameContext.isSinglePlayer && !GameContext.spLevel.isAvailableUnit(unitType)) {
                // don't create buttons for unavailable units
                continue;
            }

            var upb :XUnitPurchaseButton = new XUnitPurchaseButton(unitType, slotNumber++, unitParent);
            _unitPurchaseButtons.push(upb);
        }

        this.updateResourceMeters();
    }

    public function get puzzleFrame () :MovieClip
    {
        return _movie["frame_puzzle"];
    }

    override public function get displayObject () :DisplayObject
    {
        return _movie;
    }

    override protected function update (dt :Number) :void
    {
        this.updateResourceMeters();
        this.updateUnitButtons();
    }

    protected function updateUnitButtons () :void
    {
        for each (var upb :XUnitPurchaseButton in _unitPurchaseButtons) {
            upb.updatePurchaseMeters();
        }
    }

    protected function updateResourceMeters () :void
    {
        for (var resType :uint = 0; resType < Constants.RESOURCE__LIMIT; ++resType) {
            this.updateResourceMeter(resType);
        }
    }

    protected function updateResourceMeter (resType :uint) :void
    {
        var resAmount :int = GameContext.localPlayerInfo.getResourceAmount(resType);

        // only update if the resource amount has changed
        if (resAmount == _oldResourceAmounts[resType]) {
            return;
        }

        _oldResourceAmounts[resType] = resAmount;

        var textField :TextField = _resourceText[resType];
        textField.text = String(resAmount);

        var puzzleFrame :MovieClip = this.puzzleFrame;
        var resourceBarParent :Sprite = _resourceBars[resType];

        // remove the old set of resource bars
        if (null != resourceBarParent) {
            puzzleFrame.removeChild(resourceBarParent);
            _resourceBars[resType] = null;
        }

        if (resAmount <= 0) {
            return;
        }

        resourceBarParent = new Sprite();
        puzzleFrame.addChildAt(resourceBarParent, 1);
        _resourceBars[resType] = resourceBarParent;

        // create new meters
        var color :uint = ResourceData(GameContext.gameData.resources[resType]).color;
        var firstMeterLoc :Point = RESOURCE_METER_LOCS[resType];
        var meterXOffset :Number = firstMeterLoc.x;
        while (resAmount > 0) {
            var meterVal :int = Math.min(resAmount, RESOURCE_METER_MAX_VAL);
            var meterHeight :Number = RESOURCE_METER_MAX_HEIGHT * (meterVal / RESOURCE_METER_MAX_VAL);
            var rectMeter :Shape = new Shape();

            var g :Graphics = rectMeter.graphics;
            g.beginFill(color);
            g.lineStyle(1, 0);
            g.drawRect(0, 0, RESOURCE_METER_WIDTH, meterHeight);
            g.endFill();

            rectMeter.x = meterXOffset;
            rectMeter.y = firstMeterLoc.y - meterHeight;
            resourceBarParent.addChild(rectMeter);

            meterXOffset += RESOURCE_METER_WIDTH;

            resAmount -= meterVal;
        }

    }

    protected var _movie :MovieClip;
    protected var _resourceText :Array = [];
    protected var _resourceBars :Array = [];
    protected var _oldResourceAmounts :Array = [];
    protected var _unitPurchaseButtons :Array = [];

    protected static const RESOURCE_TEXT_NAMES :Array =
        [ "resource_2", "resource_1", "resource_4", "resource_3" ];

    protected static const RESOURCE_METER_LOCS :Array =
        [ new Point(-64, 64), new Point(-133, 64), new Point(74, 64), new Point(5, 64) ];

    protected static const RESOURCE_METER_WIDTH :Number = 3;
    protected static const RESOURCE_METER_MAX_VAL :int = 50;
    protected static const RESOURCE_METER_MAX_HEIGHT :Number = 20;
}

}

import flash.display.MovieClip;

import popcraft.*;
import popcraft.battle.view.UnitAnimationFactory;
import popcraft.data.UnitData;
import flash.display.DisplayObject;
import com.whirled.contrib.simplegame.resource.ImageResource;
import flash.text.TextField;
import popcraft.data.ResourceData;
import flash.filters.GlowFilter;
import flash.display.Sprite;
import flash.display.Shape;
import flash.display.Graphics;
import flash.display.BitmapData;
import flash.display.Bitmap;
import com.whirled.contrib.simplegame.resource.ResourceManager;
import com.whirled.contrib.simplegame.resource.SwfResource;
import flash.geom.Point;

class XUnitPurchaseButton
{
    public function XUnitPurchaseButton (unitType :uint, slotNum :int, parent :MovieClip)
    {
        _switch = parent["switch_" + slotNum];
        _costs = parent["cost_" + slotNum];
        _hilite = parent["highlight_" + slotNum];
        _unitDisplay = parent["unit_" + slotNum]["unit"];
        _progress = parent["progress_" + slotNum];

        var unitData :UnitData = GameContext.gameData.units[unitType];
        var playerColor :uint = Constants.PLAYER_COLORS[GameContext.localPlayerId];

        // try instantiating some animations
        _enabledAnim = UnitAnimationFactory.instantiateUnitAnimation(unitData, playerColor, "walk_SW");
        if (null == _enabledAnim) {
            _enabledAnim = UnitAnimationFactory.instantiateUnitAnimation(unitData, playerColor, "attack_SW");
        }

        _disabledAnim = UnitAnimationFactory.instantiateUnitAnimation(unitData, playerColor, "stand_SW");

        if (null == _disabledAnim || null == _enabledAnim) {
            _enabledAnim = ImageResource.instantiateBitmap(unitData.name + "_icon");
            _disabledAnim = ImageResource.instantiateBitmap(unitData.name + "_icon");

            _enabledAnim.x = _enabledAnim.width * 0.5;
            _enabledAnim.y = -_enabledAnim.height;
            _disabledAnim.x = _disabledAnim.width * 0.5;
            _disabledAnim.y = -_disabledAnim.height;
        }

        _unitDisplay.addChild(_enabledAnim);
        _unitDisplay.addChild(_disabledAnim);

        // set up the Unit Cost indicators
        for (var resType :uint = 0; resType < Constants.RESOURCE__LIMIT; ++resType) {
            var resCost :int = unitData.getResourceCost(resType);
            if (resCost > 0) {
                if (_resource1Cost == 0) {
                    _resource1Type = resType;
                    _resource1Cost = resCost;
                    _resource1Data = GameContext.gameData.resources[resType];
                } else {
                    _resource2Type = resType;
                    _resource2Cost = resCost;
                    _resource2Data = GameContext.gameData.resources[resType];
                }
            }
        }

        var cost1Text :TextField = _costs["cost_1"];
        var cost2Text :TextField = _costs["cost_2"];
        var cost1Filter :GlowFilter = cost1Text.filters[0];
        var cost2Filter :GlowFilter = cost2Text.filters[0];

        cost1Filter.color = _resource1Data.hiliteColor;
        cost1Text.textColor = _resource1Data.color;
        cost1Text.text = String(_resource1Cost);

        cost2Filter.color = _resource2Data.hiliteColor;
        cost2Text.textColor = _resource2Data.color;
        cost2Text.text = String(_resource2Cost);

        this.createPurchaseMeters();

        // force this.enabled = false to have an effect
        _enabled = true;
        this.enabled = false;
    }

    public function set enabled (val :Boolean) :void
    {
        if (val != _enabled) {
            _enabled = val;
            _enabledAnim.visible = val;
            _disabledAnim.visible = !val;
        }
    }

    protected function createPurchaseMeters () :void
    {
        var resource1Bitmap :BitmapData = SwfResource.getBitmapData("dashboard", RESOURCE_BITMAP_NAMES[_resource1Type], 18, 18);
        var resource2Bitmap :BitmapData = SwfResource.getBitmapData("dashboard", RESOURCE_BITMAP_NAMES[_resource2Type], 18, 18);
        var resource1BgColor :uint = _resource1Data.hiliteColor;
        var resource2BgColor :uint = _resource2Data.hiliteColor;

        var meter :ResourceMeter;
        var meterXOffset :Number = FIRST_METER_LOC.x;
        if (_resource1Cost <= 50 && _resource2Cost <= 50) {
            // use large meters for costs <= 50
            meter = new ResourceMeter(resource1Bitmap, resource1BgColor, true, 0, _resource1Cost);
            meter.x = meterXOffset;
            meter.y = FIRST_METER_LOC.y;
            _resource1Meters.push(meter);
            _progress.addChild(meter);

            meterXOffset += meter.meterWidth;

            meter = new ResourceMeter(resource2Bitmap, resource2BgColor, true, 0, _resource2Cost);
            meter.x = meterXOffset;
            meter.y = FIRST_METER_LOC.y;
            _resource2Meters.push(meter);
            _progress.addChild(meter);

        } else {
            // make a bunch of small meters
            for (var i :int = 0; i < 2; ++i) {
                var totalCost :int;
                var fgBitmap :BitmapData;
                var bgColor :uint;
                var meterArray :Array;
                if (i == 0) {
                    totalCost = _resource1Cost;
                    fgBitmap = resource1Bitmap;
                    bgColor = resource1BgColor;
                    meterArray = _resource1Meters;
                } else {
                    totalCost = _resource2Cost;
                    fgBitmap = resource2Bitmap;
                    bgColor = resource2BgColor;
                    meterArray = _resource2Meters;
                }

                while (totalCost > 0) {
                    var meterMax :int = Math.min(totalCost, ResourceMeter.MAX_MAX_VALUE);
                    meter = new ResourceMeter(fgBitmap, bgColor, false, 0, meterMax);
                    meter.x = meterXOffset;
                    meter.y = FIRST_METER_LOC.y;
                    meterArray.push(meter);
                    _progress.addChild(meter);

                    meterXOffset += meter.meterWidth;
                    totalCost -= meterMax;
                }
            }
        }
    }

    public function updatePurchaseMeters () :void
    {
        var playerInfo :LocalPlayerInfo = GameContext.localPlayerInfo;
        var res1Amount :int = Math.min(playerInfo.getResourceAmount(_resource1Type), _resource1Cost);
        var res2Amount :int = Math.min(playerInfo.getResourceAmount(_resource2Type), _resource2Cost);

        if (res1Amount == _lastResource1Amount && res2Amount == _lastResource2Amount) {
            // don't update if nothing has changed
            return;
        }

        // update all the meters
        for (var i :int = 0; i < 2; ++i) {
            var availableResources :int;
            var meterArray :Array;
            if (i == 0) {
                availableResources = res1Amount;
                meterArray = _resource1Meters;
            } else {
                availableResources = res2Amount;
                meterArray = _resource2Meters;
            }

            for each (var meter :ResourceMeter in meterArray) {
                var thisMeterVal :int = Math.min(availableResources, ResourceMeter.MAX_MAX_VALUE);
                meter.update(thisMeterVal);
                availableResources = Math.max(availableResources - thisMeterVal, 0);
            }
        }
    }

    protected var _switch :MovieClip;
    protected var _costs :MovieClip;
    protected var _hilite :MovieClip;
    protected var _unitDisplay :MovieClip;
    protected var _progress :MovieClip;

    protected var _enabledAnim :DisplayObject;
    protected var _disabledAnim :DisplayObject;

    protected var _resource1Type :uint;
    protected var _resource2Type :uint;
    protected var _resource1Cost :int;
    protected var _resource2Cost :int;
    protected var _resource1Data :ResourceData;
    protected var _resource2Data :ResourceData;
    protected var _lastResource1Amount :int = -1;
    protected var _lastResource2Amount :int = -1;
    protected var _resource1Meters :Array = [];
    protected var _resource2Meters :Array = [];

    protected var _enabled :Boolean;

    protected static const FIRST_METER_LOC :Point = new Point(-18, -50);

    protected static const RESOURCE_BITMAP_NAMES :Array =
        [ "flesh", "blood", "energy", "artifice" ];
}

class ResourceMeter extends Shape
{
    public static const MAX_MAX_VALUE :int = 50;

    public function ResourceMeter (fgBitmap :BitmapData, bgColor :uint, isLarge :Boolean, value :int, maxValue :int)
    {
        _fgBitmap = fgBitmap;
        _bgColor = bgColor;
        _width = (isLarge ? LG_WIDTH : SM_WIDTH);
        _maxValue = maxValue;

        _totalHeight = (_maxValue / MAX_MAX_VALUE) * MAX_HEIGHT;

        this.update(value);
    }

    public function update (newValue :int) :void
    {
        if (_value == newValue) {
            return;
        }

        _value = newValue;

        var percentFill :Number = _value / _maxValue;
        var fgHeight :Number = _totalHeight * percentFill;
        var bgHeight :Number = _totalHeight - fgHeight;
        var bgStart :Number = MAX_HEIGHT - _totalHeight;
        var fgStart :Number = bgStart + bgHeight;

        var g :Graphics = this.graphics;
        g.clear();

        if (fgHeight > 0) {
            // draw the fg
            g.beginBitmapFill(_fgBitmap);
            g.lineStyle(1, 0);
            g.drawRect(0, fgStart, _width, fgHeight);
            g.endFill();
        }

        if (bgHeight > 1) {
            // draw the bg
            g.beginFill(_bgColor);
            g.lineStyle(1, 0);
            g.drawRect(0, bgStart, _width, bgHeight);
            g.endFill();
        }
    }

    public function get meterWidth () :int
    {
        return _width;
    }

    protected var _fgBitmap :BitmapData;
    protected var _bgColor :uint;
    protected var _maxValue :int;
    protected var _value :int = -1;
    protected var _width :int;
    protected var _totalHeight :Number;

    protected static const MAX_HEIGHT :int = 65;
    protected static const LG_WIDTH :int = 18;
    protected static const SM_WIDTH :int = 3;
}
