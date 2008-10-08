package popcraft.sp {

import com.whirled.contrib.simplegame.AppMode;

import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;

import popcraft.*;
import popcraft.battle.view.*;
import popcraft.data.*;
import popcraft.ui.UIBits;

public class UnitAnimTestMode extends AppMode
{
    override protected function setup () :void
    {
        var playerColors :Array = AppContext.defaultGameData.playerColors;

        _recolor = playerColors[0];

        var g :Graphics = this.modeSprite.graphics;

        g.beginFill(0xBCBCBC);
        g.drawRect(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);
        g.endFill();

        // unit buttons
        var xLoc :Number = 10;
        var yLoc :Number = 300;
        for (var unitType :int = 0; unitType < Constants.UNIT_TYPE__CREATURE_LIMIT; ++unitType) {
            var button :SimpleButton = this.createUnitButton(unitType);
            button.x = xLoc;
            button.y = yLoc;
            xLoc += button.width + 3;
            this.modeSprite.addChild(button);
        }

        // player color buttons
        xLoc = 10;
        yLoc = 350;
        for (var playerNum :int = 0; playerNum < playerColors.length; ++playerNum) {
            button = this.createPlayerColorButton(playerNum);
            button.x = xLoc;
            button.y = yLoc;
            xLoc += button.width + 3;
            this.modeSprite.addChild(button);
        }

        // back button
        button = UIBits.createButton("Back");
        this.registerOneShotCallback(button, MouseEvent.CLICK,
            function (...ignored) :void {
                AppContext.mainLoop.popMode();
            });
        button.x = 10;
        button.y = 420;
        this.modeSprite.addChild(button);

        this.updateView();
    }

    protected function createUnitButton (unitType :int) :SimpleButton
    {
        var thisObject :UnitAnimTestMode = this;

        var unitData :UnitData = AppContext.defaultGameData.units[unitType];
        var unitButton :SimpleButton = UIBits.createButton(unitData.displayName);
        this.registerEventListener(unitButton, MouseEvent.CLICK,
            function (...ignored) :void {
                thisObject.unitType = unitType;
            });

        return unitButton;
    }

    protected function createPlayerColorButton (playerNum :int) :SimpleButton
    {
        var thisObject :UnitAnimTestMode = this;

        var color :uint = AppContext.defaultGameData.playerColors[playerNum];
        var unitButton :SimpleButton = UIBits.createButton("Player " + String(playerNum + 1));
        this.registerEventListener(unitButton, MouseEvent.CLICK,
            function (...ignored) :void {
                thisObject.recolor = color;
            });

        return unitButton;
    }

    protected function set unitType (val :int) :void
    {
        _unitType = val;
        this.updateView();
    }

    protected function set recolor (val :int) :void
    {
        _recolor = val;
        this.updateView();
    }

    protected function updateView () :void
    {
        var unitData :UnitData = AppContext.defaultGameData.units[_unitType];

        if (null != _animSprite) {
            this.modeSprite.removeChild(_animSprite);
        }

        _animSprite = new Sprite();
        this.modeSprite.addChild(_animSprite);

        var xLoc :Number = 30;
        var yLoc :Number = 80;

        for each (var animPrefix :String in ANIM_PREFIX_STRINGS) {
            for each (var facingString :String in FACING_STRINGS) {
                var animName :String = animPrefix + facingString;
                var anim :MovieClip =
                    UnitAnimationFactory.instantiateUnitAnimation(unitData, _recolor, animName);

                if (null != anim) {
                    if (xLoc + anim.width > 680) {
                        xLoc = 30;
                        yLoc += anim.height + 20;
                    }

                    anim.x = xLoc;
                    anim.y = yLoc;

                    xLoc += anim.width + 20;

                    _animSprite.addChild(anim);
                }

                var bmAnim :BitmapAnim =
                    UnitAnimationFactory.getBitmapAnim(_unitType, _recolor, animName);

                if (null != bmAnim) {
                    var bmaView :BitmapAnimView = new BitmapAnimView(bmAnim);
                    this.addObject(bmaView, _animSprite);

                    if (xLoc + bmaView.width > 680) {
                        xLoc = 30;
                        yLoc += bmaView.height + 20;
                    }

                    bmaView.x = xLoc;
                    bmaView.y = yLoc;

                    xLoc += bmaView.width + 20;
                }
            }
        }
    }

    protected var _animSprite :Sprite;
    protected var _recolor :uint;
    protected var _unitType :int = 0;

    protected static const ANIM_PREFIX_STRINGS :Array = [ "stand_", "walk_", "attack_", "die_" ];
    protected static const FACING_STRINGS :Array = [ "N", "NW", "SW", "S", ];
}

}
