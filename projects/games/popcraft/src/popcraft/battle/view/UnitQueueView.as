package popcraft.battle.view {

import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.MouseEvent;

import popcraft.*;
import popcraft.battle.*;

public class UnitQueueView extends SceneObject
{
    public function UnitQueueView ()
    {
        var xOffset :Number = 0;
        var yOffset :Number = 2;

        for (var unitType :uint = 0; unitType < Constants.UNIT_TYPE__CREATURE_LIMIT; ++unitType) {
            var urd :UnitReservesDisplay = new UnitReservesDisplay(unitType);
            urd.addEventListener(MouseEvent.MOUSE_DOWN, this.createSendUnitFunction(unitType));
            urd.x = xOffset;
            urd.y = yOffset;
            xOffset += 35;
            _topSprite.addChild(urd);

            _unitReserveDisplays.push(urd);
        }

        _topSprite.addChild(_queueDisplay);

        var g :Graphics = _topSprite.graphics;
        g.beginFill(0xBBBBBB);
        g.drawRect(0, 0, _topSprite.width + 4, _topSprite.height + 34);
    }

    protected function createSendUnitFunction (unitType :uint) :Function
    {
        return function (...ignored) :void {
            if (GameContext.unitQueue.hasReadyUnits(unitType)) {
                GameContext.gameMode.sendUnit(unitType);
            }
        }
    }

    override protected function addedToDB () :void
    {
        GameContext.unitQueue.addEventListener(UnitQueue.QUEUE_UPDATED, handleQueueUpdated);
    }

    override protected function removedFromDB () :void
    {
        GameContext.unitQueue.removeEventListener(UnitQueue.QUEUE_UPDATED, handleQueueUpdated);
    }

    override public function get displayObject () :DisplayObject
    {
        return _topSprite;
    }

    protected function handleQueueUpdated (...ignored) :void
    {
        this.updateDisplay();
    }

    protected function updateDisplay () :void
    {
        var queue :UnitQueue = GameContext.unitQueue;

        // update ready unit counts
        for (var unitType :uint = 0; unitType < Constants.UNIT_TYPE__CREATURE_LIMIT; ++unitType) {
            var urd :UnitReservesDisplay = _unitReserveDisplays[unitType];
            urd.numReserves = queue.getNumReadyUnits(unitType);
        }

        // rebuild the queue display
        _topSprite.removeChild(_queueDisplay);
        _queueDisplay = new Sprite();

        var xOffset :Number = 15;
        var yOffset :Number = 30;
        var queuedUnitList :Array = queue.queuedUnits;
        for each (unitType in queuedUnitList) {
            var icon :UnitQueueIcon = new UnitQueueIcon(unitType, true);
            icon.alpha = 0.5;
            icon.x = xOffset;
            icon.y = yOffset;
            _queueDisplay.addChild(icon);

            xOffset += 32;
        }

        _queueDisplay.y = 40;
        _topSprite.addChild(_queueDisplay);
    }

    protected var _topSprite :Sprite = new Sprite();
    protected var _unitReserveDisplays :Array = [];
    protected var _queueDisplay :Sprite = new Sprite();
}

}

import flash.display.Sprite;
import flash.text.TextField;
import flash.display.DisplayObject;
import flash.display.Bitmap;
import flash.display.MovieClip;

import popcraft.*;
import popcraft.battle.*;
import popcraft.battle.view.*;
import flash.filters.ColorMatrixFilter;
import com.whirled.contrib.ColorMatrix;
import flash.text.TextFieldAutoSize;

class UnitQueueIcon extends Sprite
{
    public function UnitQueueIcon (unitType :uint, grayscale :Boolean = false)
    {
        var data :UnitData = Constants.UNIT_DATA[unitType];
        var playerColor :uint = Constants.PLAYER_COLORS[GameContext.localPlayerId];

        // try instantiating an animation
        var anim :MovieClip = UnitAnimationFactory.instantiateUnitAnimation(data, playerColor, "walk_SW");
        if (null == anim) {
            anim = UnitAnimationFactory.instantiateUnitAnimation(data, playerColor, "stand_SW");
        }

        if (null != anim) {
            anim.cacheAsBitmap = true;
            anim.gotoAndStop(1);
            var scale :Number = Math.min(30 / anim.width, 30 / anim.height);
            anim.scaleX = scale;
            anim.scaleY = scale;

            _icon = anim;
        } else {
            var bitmap :Bitmap = PopCraft.instantiateBitmap(data.name + "_icon");
            scale = Math.min(30 / bitmap.width, 30 / bitmap.height);
            bitmap.scaleX = scale;
            bitmap.scaleY = scale;
            bitmap.x = -bitmap.width * 0.5;
            bitmap.y = -bitmap.height;

            _icon = bitmap;
        }

        this.addChild(_icon);

        this.grayscale = grayscale;
    }

    public function set grayscale (val :Boolean) :void
    {
        if (_grayscale != val) {
            _grayscale = val;
            if (!_grayscale) {
                _icon.filters = [];
            } else {
                if (null == g_grayscaleFilter) {
                    var cm :ColorMatrix = new ColorMatrix();
                    cm.makeGrayscale();
                    g_grayscaleFilter = cm.createFilter();
                }

                _icon.filters = [ g_grayscaleFilter ];
            }
        }
    }

    protected var _icon :DisplayObject;
    protected var _grayscale :Boolean;

    protected static var g_grayscaleFilter :ColorMatrixFilter;
}

class UnitReservesDisplay extends Sprite
{
    public function UnitReservesDisplay (unitType :uint)
    {
        _icon = new UnitQueueIcon(unitType);
        _icon.x = 15;
        _icon.y = 30;

        _textField = new TextField();
        _textField.autoSize = TextFieldAutoSize.CENTER;
        _textField.textColor = 0;
        _textField.x = 15;
        _textField.y = 30;

        this.addChild(_icon);
        this.addChild(_textField);

        this.numReserves = 0;
    }

    public function set numReserves (val :uint) :void
    {
        _textField.text = val.toString();
        _icon.grayscale = (val == 0);
        _icon.alpha = (val == 0 ? 0.5 : 1);
    }

    protected var _textField :TextField;
    protected var _icon :UnitQueueIcon;
}
