package popcraft {

import com.whirled.contrib.simplegame.resource.*;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import popcraft.battle.*;
import popcraft.battle.view.*;
import popcraft.data.*;

public class UnitPurchaseButton extends Sprite
{
    public static const HEIGHT :uint = 48;
    public static const WIDTH :uint = 40;

    public function UnitPurchaseButton (unitType :uint)
    {
        _unitType = unitType;
        _button = new SimpleButton();

        var unitData :UnitData = GameContext.gameData.units[unitType];
        var playerColor :uint = Constants.PLAYER_COLORS[GameContext.localPlayerId];

        // try instantiating some animations
        // @TODO - why aren't the up animations playing?
        var upAnim :MovieClip = UnitAnimationFactory.instantiateUnitAnimation(unitData, playerColor, "walk_SW");
        if (null == upAnim) {
            upAnim = UnitAnimationFactory.instantiateUnitAnimation(unitData, playerColor, "stand_SW");
        }
        var overAnim :MovieClip = UnitAnimationFactory.instantiateUnitAnimation(unitData, playerColor, "attack_SW");
        var downAnim :MovieClip = UnitAnimationFactory.instantiateUnitAnimation(unitData, playerColor, "attack_SW");
        var disabledAnim :MovieClip = UnitAnimationFactory.instantiateUnitAnimation(unitData, playerColor, "stand_SW");

        if (null != upAnim && null != overAnim && null != downAnim && null != disabledAnim) {
            disabledAnim.gotoAndStop(1);
            _button.upState = makeAnimatedButonFace(upAnim, COLOR_OUTLINE, COLOR_BG_UP);
            _button.overState = makeAnimatedButonFace(overAnim, COLOR_OUTLINE, COLOR_BG_OVER, 1.0);
            _button.downState = makeAnimatedButonFace(downAnim, COLOR_OUTLINE, COLOR_BG_DOWN, 1.0);
            _disabledState = makeAnimatedButonFace(disabledAnim, COLOR_OUTLINE, COLOR_BG_DISABLED, ALPHA_DISABLED);

        } else {
            var bitmapData :BitmapData = (AppContext.resources.getResource(unitData.name + "_icon") as ImageResourceLoader).bitmapData;
            _button.upState         = makeIconButtonFace(bitmapData, COLOR_OUTLINE, COLOR_BG_UP);
            _button.overState       = makeIconButtonFace(bitmapData, COLOR_OUTLINE, COLOR_BG_OVER, 1.0);
            _button.downState       = makeIconButtonFace(bitmapData, COLOR_OUTLINE, COLOR_BG_DOWN, 1.0);
            _disabledState   = makeIconButtonFace(bitmapData, COLOR_OUTLINE, COLOR_BG_DISABLED, ALPHA_DISABLED);
        }

        _button.hitTestState = _disabledState;

        this.addChild(_button);
        this.addChild(_disabledState);

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

        this.enabled = true;

        this.addEventListener(MouseEvent.ROLL_OVER, handleMouseOver);
        this.addEventListener(MouseEvent.ROLL_OUT, handleMouseOut);
    }

    protected static function makeAnimatedButonFace (anim :MovieClip, fgColor :uint, bgColor :uint, animAlpha :Number = 1.0) :Sprite
    {
        var face :Sprite = new Sprite();

        var animParent :Sprite = new Sprite();
        animParent.scrollRect = new Rectangle(0, 0, WIDTH, HEIGHT);
        face.addChild(animParent);

        anim.scaleX = 0.75;
        anim.scaleY = 0.75;
        anim.x = WIDTH * 0.5;
        anim.y = HEIGHT - 4;
        anim.alpha = animAlpha;

        animParent.addChild(anim);

        // draw our button background (and outline)
        face.graphics.beginFill(bgColor);
        face.graphics.lineStyle(1, fgColor);
        face.graphics.drawRect(0, 0, WIDTH, HEIGHT);
        face.graphics.endFill();

        return face;
    }

    // @TODO - remove this function
    protected static function makeIconButtonFace (bitmapData :BitmapData, fgColor :uint, bgColor :uint, iconAlpha :Number = 1.0) :Sprite
    {
        var face :Sprite = new Sprite();

        var icon :Bitmap = new Bitmap(bitmapData);
        var scale :Number = (WIDTH / icon.width);
        icon.scaleX = scale;
        icon.scaleY = scale;
        icon.alpha = iconAlpha;

        face.addChild(icon);

        // draw our button background (and outline)
        face.graphics.beginFill(bgColor);
        face.graphics.lineStyle(1, fgColor);
        face.graphics.drawRect(0, 0, WIDTH, HEIGHT);
        face.graphics.endFill();

        icon.x = 0;
        icon.y = 0;

        return face;
    }

    protected function handleMouseOver (...ignored) :void
    {
        if (null != _descriptionPopup) {
            _descriptionPopup.visible = true;
        }
    }

    protected function handleMouseOut (...ignored) :void
    {
        if (null != _descriptionPopup) {
            _descriptionPopup.visible = false;
        }
    }

    public function get enabled () :Boolean
    {
        return _enabled;
    }

    public function set enabled (val :Boolean) :void
    {
        _enabled = val;
        _button.visible = enabled;
        _disabledState.visible = !enabled;
    }

    public function get unitType () :uint
    {
        return _unitType;
    }

    protected var _unitType :uint;
    protected var _button :SimpleButton;
    protected var _disabledState :Sprite;
    protected var _descriptionPopup :DisplayObject;

    protected var _enabled :Boolean;

    protected static const COLOR_OUTLINE :uint = 0x000000;
    protected static const COLOR_BG_UP :uint = 0xFFD800;
    protected static const COLOR_BG_OVER :uint = 0xCFAF00;
    protected static const COLOR_BG_DOWN :uint = 0xCFAF00;
    protected static const COLOR_BG_DISABLED :uint = 0x525252;

    protected static const ALPHA_DISABLED :Number = 0.5;
}

}
