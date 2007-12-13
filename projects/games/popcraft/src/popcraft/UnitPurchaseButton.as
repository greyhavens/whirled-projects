package popcraft {

import popcraft.battle.*;

import core.AppObject;
import com.threerings.flash.DisablingButton;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.text.TextField;

public class UnitPurchaseButton extends DisablingButton
{
    public function UnitPurchaseButton (unitType :uint)
    {
        var data :UnitData = Constants.UNIT_DATA[unitType];

        // how much does it cost?
        var costString :String = new String();
        for (var resType :uint = 0; resType < Constants.RESOURCE__LIMIT; ++resType) {
            var resData :ResourceType = Constants.getResource(resType);
            var resCost :int = data.getResourceCost(resType);

            if (resCost == 0) {
                continue;
            }

            if (costString.length > 0) {
                costString += " ";
            }

            costString += (resData.name + " (" + data.getResourceCost(resType) + ")");
        }

        upState         = makeButtonFace(data.imageClass, costString, COLOR_OUTLINE, COLOR_BG_UP);
        overState       = makeButtonFace(data.imageClass, costString, COLOR_OUTLINE, COLOR_BG_OVER);
        downState       = makeButtonFace(data.imageClass, costString, COLOR_OUTLINE, COLOR_BG_DOWN);
        disabledState   = makeButtonFace(data.imageClass, costString, COLOR_OUTLINE, COLOR_BG_DISABLED, ALPHA_DISABLED);

        hitTestState = upState;

        downState.x = -1;
        downState.y = -1;
    }

    protected static function makeButtonFace (iconClass :Class, costString :String, foreground :uint, background :uint, iconAlpha :Number = 1.0) :Sprite
    {
        var face :Sprite = new Sprite();

        var icon :DisplayObject = new iconClass();
        icon.alpha = iconAlpha;

        face.addChild(icon);

        var costText :TextField = new TextField();
        costText.text = costString;
        costText.textColor = 0;
        costText.height = costText.textHeight + 2;
        costText.width = costText.textWidth + 3;
        costText.y = icon.height + 5;

        face.addChild(costText);

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
