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
        for (var unitType :uint = 0; unitType < Constants.UNIT_TYPE__CREATURE_LIMIT; ++unitType) {
            var available :Boolean = (!GameContext.isSinglePlayer || GameContext.spLevel.isAvailableUnit(unitType));
            var upb :XUnitPurchaseButton = new XUnitPurchaseButton(unitType, unitType + 1, unitParent);
            upb.visible = available;
        }

        this.updateResources();
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
        this.updateResources();
    }

    protected function updateResources () :void
    {
        for (var resType :uint = 0; resType < Constants.RESOURCE__LIMIT; ++resType) {
            this.updateResource(resType);
        }
    }

    protected function updateResource (resType :uint) :void
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

class XUnitPurchaseButton
{
    public function XUnitPurchaseButton (unitType :uint, slotNum :int, parent :MovieClip)
    {
        _switch = parent["switch_" + slotNum];
        _costs = parent["cost_" + slotNum];
        _hilite = parent["highlight_" + slotNum];
        _unitDisplay = parent["unit_" + slotNum];
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
        }

        _unitDisplay.addChild(_enabledAnim);
        _unitDisplay.addChild(_disabledAnim);

        this.enabled = true;
    }

    public function set visible (val :Boolean) :void
    {
        _switch.visible = val;
        _costs.visible = val;
        _hilite.visible = val;
        _unitDisplay.visible = val;
        _progress.visible = val;
    }

    public function set enabled (val :Boolean) :void
    {
        if (val != _enabled) {
            _enabled = val;
            _enabledAnim.visible = val;
            _disabledAnim.visible = !val;
        }
    }

    protected var _switch :MovieClip;
    protected var _costs :MovieClip;
    protected var _hilite :MovieClip;
    protected var _unitDisplay :MovieClip;
    protected var _progress :MovieClip;

    protected var _enabledAnim :DisplayObject;
    protected var _disabledAnim :DisplayObject;

    protected var _enabled :Boolean;
}
