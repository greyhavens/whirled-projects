package popcraft {

import com.threerings.util.HashMap;
import com.whirled.contrib.ColorMatrix;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.resource.SwfResource;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;

import popcraft.*;
import popcraft.battle.view.*;
import popcraft.data.*;
import popcraft.ui.UIBits;
import popcraft.util.SpriteUtil;

public class UnitAnimTestMode extends AppMode
{
    override protected function setup () :void
    {
        var playerDisplayDatas :HashMap = ClientCtx.defaultGameData.playerDisplayDatas;
        var playerDisplayData :PlayerDisplayData = playerDisplayDatas.values()[0];
        _recolor = playerDisplayData.color;

        var g :Graphics = this.modeSprite.graphics;

        g.beginFill(0xBCBCBC);
        g.drawRect(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);
        g.endFill();

        // unit buttons
        var xLoc :Number = 10;
        var yLoc :Number = 380;
        for (var unitType :int = 0; unitType < Constants.UNIT_NAMES.length; ++unitType) {
            var button :SimpleButton = createUnitButton(unitType);
            button.x = xLoc;
            button.y = yLoc;
            xLoc += button.width + 3;
            this.modeSprite.addChild(button);
        }

        // player color buttons
        xLoc = 10;
        yLoc = 420;
        for each (playerDisplayData in playerDisplayDatas.values()) {
            button = createPlayerColorButton(playerDisplayData);
            button.x = xLoc;
            button.y = yLoc;
            xLoc += button.width + 3;
            this.modeSprite.addChild(button);
        }

        // back button
        button = UIBits.createButton("Back");
        registerOneShotCallback(button, MouseEvent.CLICK,
            function (...ignored) :void {
                ClientCtx.mainLoop.popMode();
            });
        button.x = 10;
        button.y = 460;
        this.modeSprite.addChild(button);

        updateView();
    }

    protected function createUnitButton (unitType :int) :SimpleButton
    {
        var thisObject :UnitAnimTestMode = this;

        var unitData :UnitData = ClientCtx.defaultGameData.units[unitType];
        var unitButton :SimpleButton = UIBits.createButton(unitData.displayName);
        registerListener(unitButton, MouseEvent.CLICK,
            function (...ignored) :void {
                thisObject.unitType = unitType;
            });

        return unitButton;
    }

    protected function createPlayerColorButton (playerDisplayData :PlayerDisplayData) :SimpleButton
    {
        var thisObject :UnitAnimTestMode = this;

        var unitButton :SimpleButton = UIBits.createButton(playerDisplayData.displayName);
        registerListener(unitButton, MouseEvent.CLICK,
            function (...ignored) :void {
                thisObject.recolor = playerDisplayData.color;
            });

        return unitButton;
    }

    protected function set unitType (val :int) :void
    {
        _unitType = val;
        updateView();
    }

    protected function set recolor (val :int) :void
    {
        _recolor = val;
        updateView();
    }

    protected function updateView () :void
    {
        if (null != _animSprite) {
            this.modeSprite.removeChild(_animSprite);
        }

        _animSprite = SpriteUtil.createSprite();
        this.modeSprite.addChild(_animSprite);

        _xLoc = 50;
        _yLoc = 90;

        if (_unitType == Constants.UNIT_TYPE_WORKSHOP) {
            createWorkshopAnimations();

        } else {
            for each (var animPrefix :String in ANIM_PREFIX_STRINGS) {
                for each (var facingString :String in FACING_STRINGS) {
                    var animName :String = animPrefix + facingString;
                    createCreatureAnimations(animName);
                }
            }

            createCreatureAnimations("die");
        }
    }

    protected function createWorkshopAnimations () :void
    {
        var anim :MovieClip = ClientCtx.instantiateMovieClip("workshop", "base");
        var workshop :MovieClip = anim["workshop"];
        var recolorMovie :MovieClip = workshop["recolor"];
        recolorMovie.filters = [ ColorMatrix.create().colorize(_recolor).createFilter() ];
        addAnimToWindow(anim);
    }

    protected function createCreatureAnimations (animName :String) :void
    {
        var anim :MovieClip = CreatureAnimFactory.instantiateUnitAnimation(_unitType, _recolor,
            animName);
        if (null != anim) {
            addAnimToWindow(anim);
        }

        var bmAnim :BitmapAnim = CreatureAnimFactory.getBitmapAnim(_unitType, _recolor, animName);
        if (null != bmAnim) {
            var bmaView :BitmapAnimView = new BitmapAnimView(bmAnim);
            addObject(bmaView);
            addAnimToWindow(bmaView.displayObject);
        }
    }

    protected function addAnimToWindow (anim :DisplayObject) :void
    {
        if (_xLoc + anim.width > 680) {
            _xLoc = 40;
            _yLoc += anim.height + 20;
        }

        anim.x = _xLoc;
        anim.y = _yLoc;

        _xLoc += anim.width + 20;

        _animSprite.addChild(anim);
    }

    protected var _animSprite :Sprite;
    protected var _recolor :uint;
    protected var _unitType :int = 0;

    protected var _xLoc :Number;
    protected var _yLoc :Number;

    protected static const ANIM_PREFIX_STRINGS :Array = [ "stand_", "walk_", "attack_", "die_" ];
    protected static const FACING_STRINGS :Array = [ "N", "NW", "SW", "S", ];
}

}
