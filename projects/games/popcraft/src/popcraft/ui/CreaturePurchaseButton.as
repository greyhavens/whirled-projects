package popcraft.ui {

import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.filters.BitmapFilterQuality;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.text.TextField;

import popcraft.*;
import popcraft.battle.*;
import popcraft.battle.view.*;
import popcraft.data.*;

public class CreaturePurchaseButton extends SimObject
{
    public function CreaturePurchaseButton (unitType :uint, slotNum :int, parent :MovieClip)
    {
        _unitType = unitType;

        _switch = parent["switch_" + slotNum];
        _costs = parent["cost_" + slotNum];
        _hilite = parent["highlight_" + slotNum];
        _unitDisplay = parent["unit_" + slotNum]["unit"];
        _progress = parent["progress_" + slotNum];
        _button = parent["button_" + slotNum];
        _multiplicity = parent["multiplicity_" + slotNum]["multiplicity"];

        _switch.cacheAsBitmap = true;
        _hilite.cacheAsBitmap = true;

        _multiplicity.text = "";

        _button.addEventListener(MouseEvent.CLICK, onClicked);
        _button.addEventListener(MouseEvent.ROLL_OVER, onMouseOver);
        _button.addEventListener(MouseEvent.ROLL_OUT, onMouseOut);

        _unitData = GameContext.gameData.units[unitType];
        var playerColor :uint = GameContext.gameData.playerColors[GameContext.localPlayerId];

        // try instantiating some animations
        _enabledAnim = UnitAnimationFactory.instantiateUnitAnimation(_unitData, playerColor, "walk_SW");
        if (null == _enabledAnim) {
            _enabledAnim = UnitAnimationFactory.instantiateUnitAnimation(_unitData, playerColor, "attack_SW");
        }

        _disabledAnim = UnitAnimationFactory.instantiateUnitAnimation(_unitData, playerColor, "stand_SW");
        if (null == _disabledAnim) {
            _disabledAnim = UnitAnimationFactory.instantiateUnitAnimation(_unitData, playerColor, "walk_SW");
        }

        _unitDisplay.addChild(_enabledAnim);
        _unitDisplay.addChild(_disabledAnim);

        // set up the Unit Cost indicators
        for (var resType :uint = 0; resType < Constants.RESOURCE__LIMIT; ++resType) {
            var resCost :int = _unitData.getResourceCost(resType);
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

        // put some colored rectangles behind the cost texts
        var resource1Tile :MovieClip = SwfResource.instantiateMovieClip("dashboard", RESOURCE_COST_TILES[_resource1Type]);
        var resource2Tile :MovieClip = SwfResource.instantiateMovieClip("dashboard", RESOURCE_COST_TILES[_resource2Type]);
        resource1Tile.x = -(resource1Tile.width * 0.5);
        resource1Tile.y = -2;
        resource2Tile.x = 18 - (resource2Tile.width * 0.5);
        resource2Tile.y = -2;
        _costs.addChildAt(resource1Tile, 0);
        _costs.addChildAt(resource2Tile, 0);

        var cost1Text :TextField = _costs["cost_1"];
        var cost2Text :TextField = _costs["cost_2"];
        cost1Text.filters = [ new GlowFilter(_resource1Data.hiliteColor, 1, 2, 2, 1000, BitmapFilterQuality.LOW) ];
        cost2Text.filters = [ new GlowFilter(_resource2Data.hiliteColor, 1, 2, 2, 1000, BitmapFilterQuality.LOW) ];

        cost1Text.textColor = _resource1Data.color;
        cost1Text.text = String(_resource1Cost);

        cost2Text.textColor = _resource2Data.color;
        cost2Text.text = String(_resource2Cost);

        // create the purchase meters
        this.createPurchaseMeters();

        this.updateDisplayState();
    }

    protected function onClicked (...ignored) :void
    {
        if (_enabled) {
            _switch.gotoAndPlay("deploy");
            _hilite.gotoAndPlay("deploy");
            _multiplicity.visible = false;
            GameContext.gameMode.buildUnit(GameContext.localPlayerId, _unitType);

            this.addNamedTask(
                DEPLOY_ANIM_TASK_NAME,
                After(DEPLOY_ANIM_LENGTH,
                    new FunctionTask(playSwitchHiliteAnimation)),
                true);
        }
    }

    protected function playSwitchHiliteAnimation () :void
    {
        if (_enabled) {
            _switch.gotoAndPlay("activate");
        } else {
            _switch.gotoAndStop("off");
        }

        _hilite.gotoAndStop(_available ? "on" : "off");
        _multiplicity.visible = _available;
    }

    protected function onMouseOver (...ignored) :void
    {
        GameContext.dashboard.showInfoText(_unitData.description);
    }

    protected function onMouseOut (...ignored) :void
    {
        GameContext.dashboard.hideInfoText();
    }

    protected function updateDisplayState () :void
    {
        _enabledAnim.visible = _enabled;
        _disabledAnim.visible = !_enabled;
        _button.enabled = _enabled;

        // if we're playing the deploy animation, these animations
        // will get played automatically when it has completed
        if (!this.playingDeployAnimation) {
            this.playSwitchHiliteAnimation();
        }
    }

    override protected function update (dt :Number) :void
    {
        var playerInfo :LocalPlayerInfo = GameContext.localPlayerInfo;
        var res1Amount :int = Math.min(playerInfo.getResourceAmount(_resource1Type), _resource1Cost);
        var res2Amount :int = Math.min(playerInfo.getResourceAmount(_resource2Type), _resource2Cost);

        var available :Boolean = (playerInfo.isAlive && res1Amount >= _resource1Cost && res2Amount >= _resource2Cost);
        var enabled :Boolean = (_available && GameContext.diurnalCycle.isNight);
        if (available != _available || enabled != _enabled) {
            _available = available;
            _enabled = enabled;
            this.updateDisplayState();
        }

        if (res1Amount == _lastResource1Amount && res2Amount == _lastResource2Amount) {
            // don't update if nothing has changed
            return;
        }

        if (_available) {
            var numAvailableUnits :int = Math.min(
                Math.floor(playerInfo.getResourceAmount(_resource1Type) / _resource1Cost),
                Math.floor(playerInfo.getResourceAmount(_resource2Type) / _resource2Cost));

            _multiplicity.text = String(numAvailableUnits);
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

    protected function get playingDeployAnimation () :Boolean
    {
        return this.hasTasksNamed(DEPLOY_ANIM_TASK_NAME);
    }

    protected var _unitType :uint;
    protected var _unitData :UnitData;

    protected var _switch :MovieClip;
    protected var _costs :MovieClip;
    protected var _hilite :MovieClip;
    protected var _unitDisplay :MovieClip;
    protected var _progress :MovieClip;
    protected var _button :SimpleButton;
    protected var _multiplicity :TextField;

    protected var _enabledAnim :MovieClip;
    protected var _disabledAnim :MovieClip;

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

    // _available is true when the player has enough resources to purchase the
    // creature. _enabled is true if _available is true and it's nighttime.
    // If it's daytime, _available will be true and _enabled will be false.
    protected var _available :Boolean;
    protected var _enabled :Boolean;

    protected static const FIRST_METER_LOC :Point = new Point(-18, -65);
    protected static const DEPLOY_ANIM_LENGTH :Number = 0.7;
    protected static const DEPLOY_ANIM_TASK_NAME :String = "DeployAnimation";
    protected static const RESOURCE_COST_TILES :Array = [ "Ablank", "Bblank", "Cblank", "Dblank" ];
    protected static const RESOURCE_BITMAP_NAMES :Array = [ "flesh", "blood", "energy", "artifice" ];
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
