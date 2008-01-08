package popcraft {

import popcraft.battle.*;

import com.whirled.contrib.core.AppObject;
import com.threerings.flash.DisablingButton;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.text.TextField;

public class UnitPurchaseButton extends DisablingButton
{
    public function UnitPurchaseButton (unitType :uint)
    {
        var data :UnitData = Constants.UNIT_DATA[unitType];

        upState         = makeButtonFace(data.imageClass, COLOR_OUTLINE, COLOR_BG_UP);
        overState       = makeButtonFace(data.imageClass, COLOR_OUTLINE, COLOR_BG_OVER);
        downState       = makeButtonFace(data.imageClass, COLOR_OUTLINE, COLOR_BG_DOWN);
        disabledState   = makeButtonFace(data.imageClass, COLOR_OUTLINE, COLOR_BG_DISABLED, ALPHA_DISABLED);

        hitTestState = upState;

        downState.x = -1;
        downState.y = -1;
    }

    protected static function makeButtonFace (iconClass :Class, foreground :uint, background :uint, iconAlpha :Number = 1.0) :Sprite
    {
        var face :Sprite = new Sprite();

        var icon :DisplayObject = new iconClass();
        icon.alpha = iconAlpha;

        face.addChild(icon);

        var padding :int = 5;
        var w :Number = icon.width + 2 * padding;
        var h :Number = icon.height + 2 * padding;

        // draw our button background (and outline)
        face.graphics.beginFill(background);
        face.graphics.lineStyle(1, foreground);
        face.graphics.drawRect(0, 0, w, h);
        face.graphics.endFill();

        icon.x = padding;
        icon.y = padding;

        return face;
    }

    protected static const COLOR_OUTLINE :uint = 0x000000;
    protected static const COLOR_BG_UP :uint = 0xFFD800;
    protected static const COLOR_BG_OVER :uint = 0xCFAF00;
    protected static const COLOR_BG_DOWN :uint = 0xCFAF00;
    protected static const COLOR_BG_DISABLED :uint = 0x525252;

    protected static const ALPHA_DISABLED :Number = 0.5;
}

}
