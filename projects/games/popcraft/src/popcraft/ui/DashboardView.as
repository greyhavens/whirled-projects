package popcraft.ui {

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.SwfResource;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
import flash.geom.Point;
import flash.text.TextField;

import popcraft.*;
import popcraft.data.ResourceData;

public class DashboardView extends SceneObject
{
    public function DashboardView ()
    {
        _movie = SwfResource.instantiateMovieClip("dashboard", "dashboard_sym");
        var puzzleFrame :MovieClip = this.puzzleFrame;

        // info text
        _infoTextParent = _movie["info"];
        _infoText = _infoTextParent["info_text"];
        _infoTextParent.y = -76;
        _infoTextParent.visible = false;

        // setup resources
        for (var resType :uint = 0; resType < Constants.RESOURCE__LIMIT; ++resType) {
            var resourceTextName :String = RESOURCE_TEXT_NAMES[resType];
            _resourceText.push(puzzleFrame[resourceTextName]);
            _resourceBars.push(null);
            _oldResourceAmounts.push(-1);
        }

        // setup unit purchase buttons
        var unitParent :MovieClip = _movie["frame_units"];
        var buttonNumber :int = 1;
        for (var unitType :uint = 0; unitType < Constants.UNIT_TYPE__CREATURE_LIMIT; ++unitType) {
            if (GameContext.isSinglePlayer && !GameContext.spLevel.isAvailableUnit(unitType)) {
                // don't create buttons for unavailable units
                continue;
            }

            GameContext.gameMode.addObject(new UnitPurchaseButton(unitType, buttonNumber++, unitParent));
        }

        // hide the components of all the buttons that aren't being used
        for ( ; buttonNumber < Constants.UNIT_TYPE__CREATURE_LIMIT + 1; ++buttonNumber) {
            DisplayObject(unitParent["switch_" + buttonNumber]).visible = false;
            DisplayObject(unitParent["cost_" + buttonNumber]).visible = false;
            DisplayObject(unitParent["highlight_" + buttonNumber]).visible = false;
            DisplayObject(unitParent["unit_" + buttonNumber]["unit"]).visible = false;
            DisplayObject(unitParent["progress_" + buttonNumber]).visible = false;
            DisplayObject(unitParent["button_" + buttonNumber]).visible = false;
            DisplayObject(unitParent["multiplicity_" + buttonNumber]).visible = false;
        }

        // setup PlayerStatusViews
        var statusViewLocs :Array = PLAYER_STATUS_VIEW_LOCS[GameContext.playerInfos.length - 2];
        var playerFrame :MovieClip = _movie["frame_players"];
        for (var i :int = 0; i < statusViewLocs.length; ++i) {
            var playerInfo :PlayerInfo = GameContext.playerInfos[i];
            var loc :Point = statusViewLocs[i];

            var psv :PlayerStatusView = new PlayerStatusView(playerInfo.playerId);
            psv.x = loc.x;
            psv.y = loc.y;
            GameContext.gameMode.addObject(psv, playerFrame);
        }

        this.updateResourceMeters();
    }

    public function showInfoText (text :String) :void
    {
        _infoText.text = text;
        _infoTextParent.visible = true;
    }

    public function hideInfoText () :void
    {
        _infoTextParent.visible = false;
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
    protected var _infoTextParent :MovieClip;
    protected var _infoText :TextField;

    protected static const RESOURCE_TEXT_NAMES :Array =
        [ "resource_2", "resource_1", "resource_4", "resource_3" ];

    protected static const RESOURCE_METER_LOCS :Array =
        [ new Point(-64, 64), new Point(-133, 64), new Point(74, 64), new Point(5, 64) ];

    protected static const RESOURCE_METER_WIDTH :Number = 3;
    protected static const RESOURCE_METER_MAX_VAL :int = 50;
    protected static const RESOURCE_METER_MAX_HEIGHT :Number = 20;

    protected static const PLAYER_STATUS_VIEW_LOCS :Array = [
        [ new Point(40, 47), new Point(105, 47) ],                                          // 2 players
        [ new Point(40, 47), new Point(105, 47), new Point(170, 47), ],                     // 3 players
        [ new Point(29, 47), new Point(81, 47), new Point(133, 47), new Point(185, 47) ],   // 4 players
    ];
}

}
