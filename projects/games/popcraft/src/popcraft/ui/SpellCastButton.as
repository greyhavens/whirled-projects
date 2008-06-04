package popcraft.ui {

import com.whirled.contrib.simplegame.resource.*;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import popcraft.*;
import popcraft.battle.*;
import popcraft.battle.view.*;
import popcraft.data.*;

public class SpellCastButton extends Sprite
{
    public static const HEIGHT :uint = 24;
    public static const WIDTH :uint = 20;

    public function SpellCastButton (spellType :uint)
    {
        _spellType = spellType;

        _spellData = GameContext.gameData.spells[spellType];
        var bitmapData :BitmapData = (ResourceManager.instance.getResource(_spellData.name + "_icon") as ImageResource).bitmapData;

        _button = new SimpleButton();
        _button.upState = makeButtonFace(bitmapData, COLOR_OUTLINE, COLOR_BG_UP, 1.0);
        _button.overState = makeButtonFace(bitmapData, COLOR_OUTLINE, COLOR_BG_OVER, 1.0);
        _button.downState = makeButtonFace(bitmapData, COLOR_OUTLINE, COLOR_BG_DOWN, 1.0);
        _disabledState = makeButtonFace(bitmapData, COLOR_OUTLINE, COLOR_BG_DISABLED, ALPHA_DISABLED);
        _button.hitTestState = _disabledState;

        this.addChild(_button);
        this.addChild(_disabledState);

        // spell count text
        _spellCountText = new TextField();
        _spellCountText.autoSize = TextFieldAutoSize.CENTER;
        _spellCountText.selectable = false;
        _spellCountText.textColor = 0xFFFFFF;
        _spellCountText.y = HEIGHT;
        this.addChild(_spellCountText);

        this.enabled = true;

        this.addEventListener(MouseEvent.ROLL_OVER, handleMouseOver);
        this.addEventListener(MouseEvent.ROLL_OUT, handleMouseOut);

        this.updateSpellCount(0);
    }

    public function updateSpellCount (count :uint) :void
    {
        _spellCountText.text = String(count);
        _spellCountText.x = (WIDTH * 0.5) - (_spellCountText.width * 0.5);
    }

    protected static function makeButtonFace (bitmapData :BitmapData, fgColor :uint, bgColor :uint, iconAlpha :Number) :Sprite
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
        GameContext.dashboard.showInfoText(_spellData.description);
    }

    protected function handleMouseOut (...ignored) :void
    {
        GameContext.dashboard.hideInfoText();
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

    public function get spellType () :uint
    {
        return _spellType;
    }

    protected var _spellType :uint;
    protected var _spellData :SpellData;
    protected var _button :SimpleButton;
    protected var _disabledState :Sprite;
    protected var _spellCountText :TextField;

    protected var _enabled :Boolean;

    protected static const COLOR_OUTLINE :uint = 0x000000;
    protected static const COLOR_BG_UP :uint = 0xFFD800;
    protected static const COLOR_BG_OVER :uint = 0xCFAF00;
    protected static const COLOR_BG_DOWN :uint = 0xCFAF00;
    protected static const COLOR_BG_DISABLED :uint = 0x525252;

    protected static const ALPHA_DISABLED :Number = 0.5;
}

}
