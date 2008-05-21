package popcraft.ui {

import com.whirled.contrib.simplegame.resource.*;

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import popcraft.*;
import popcraft.battle.*;
import popcraft.battle.view.*;
import popcraft.data.*;

public class UnitPurchaseButton
{
    public function UnitPurchaseButton (unitType :uint, slotNum :int, parent :MovieClip)
    {
        _unitType = unitType;

        _switch = parent["switch_" + slotNum];
        _costs = parent["cost_" + slotNum];
        _hilite = parent["highlight_" + slotNum];
        _unitDisplay = parent["unit_" + slotNum]["unit"];
        _progress = parent["progress_" + slotNum];
        _button = parent["button_" + slotNum];

        _button.addEventListener(MouseEvent.CLICK, onClicked);
        _button.addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
        _button.addEventListener(MouseEvent.ROLL_OUT, onMouseOut);

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

        // create the unit's description popup
        var tf :TextField = new TextField();
        tf.background = true;
        tf.backgroundColor = 0xFFFFFF;
        tf.border = true;
        tf.borderColor = 0;
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.wordWrap = true;
        tf.selectable = false;
        tf.width = 200;
        tf.text = unitData.description;
        tf.visible = false;
        tf.x = -tf.width;
        tf.y = -tf.height;

        _descriptionPopup = tf;
        GameContext.gameMode.descriptionPopupParent.addChild(_descriptionPopup);

        // force this.enabled = false to have an effect
        _enabled = true;
        this.enabled = false;
    }

    protected function onClicked (...ignored) :void
    {
        if (_enabled) {
            _switch.gotoAndPlay("deploy");
            _hilite.gotoAndPlay("deploy");
            GameContext.gameMode.buildUnit(GameContext.localPlayerId, _unitType);
        }
    }

    protected function onMouseOver (...ignored) :void
    {
        _descriptionPopup.visible = true;
    }

    protected function onMouseOut (...ignored) :void
    {
        _descriptionPopup.visible = false;
    }

    protected function set enabled (val :Boolean) :void
    {
        if (val != _enabled) {
            _enabled = val;
            _enabledAnim.visible = val;
            _disabledAnim.visible = !val;
            _button.enabled = val;

            _switch.gotoAndPlay(_enabled ? "activate" : "off");
            _hilite.gotoAndPlay(_enabled ? "on" : "off");
        }
    }

    public function update () :void
    {
        var playerInfo :LocalPlayerInfo = GameContext.localPlayerInfo;
        var res1Amount :int = Math.min(playerInfo.getResourceAmount(_resource1Type), _resource1Cost);
        var res2Amount :int = Math.min(playerInfo.getResourceAmount(_resource2Type), _resource2Cost);

        if (res1Amount == _lastResource1Amount && res2Amount == _lastResource2Amount) {
            // don't update if nothing has changed
            return;
        }

        this.enabled = (res1Amount >= _resource1Cost && res2Amount >= _resource2Cost);

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

    protected var _unitType :uint;

    protected var _switch :MovieClip;
    protected var _costs :MovieClip;
    protected var _hilite :MovieClip;
    protected var _unitDisplay :MovieClip;
    protected var _progress :MovieClip;
    protected var _button :SimpleButton;

    protected var _descriptionPopup :DisplayObject;

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

}

import flash.display.Shape;
import flash.display.BitmapData;
import flash.display.Graphics;

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
