package popcraft {

import com.threerings.flash.DisablingButton;
import com.whirled.contrib.simplegame.resource.*;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import popcraft.battle.*;

public class UnitPurchaseButton extends DisablingButton
{
    public function UnitPurchaseButton (unitType :uint)
    {
        var data :UnitData = Constants.UNIT_DATA[unitType];
        var bitmapData :BitmapData = (PopCraft.resourceManager.getResource(data.name + "_icon") as ImageResourceLoader).bitmapData;

        this.upState         = makeButtonFace(bitmapData, COLOR_OUTLINE, COLOR_BG_UP);
        this.overState       = makeButtonFace(bitmapData, COLOR_OUTLINE, COLOR_BG_OVER, 1.0, data.description);
        this.downState       = makeButtonFace(bitmapData, COLOR_OUTLINE, COLOR_BG_DOWN, 1.0, data.description);
        this.disabledState   = makeButtonFace(bitmapData, COLOR_OUTLINE, COLOR_BG_DISABLED, ALPHA_DISABLED);

        this.hitTestState = upState;

        downState.x = -1;
        downState.y = -1;
    }

    protected static function makeButtonFace (bitmapData :BitmapData, foreground :uint, background :uint, iconAlpha :Number = 1.0, descriptionText :String = null) :Sprite
    {
        var face :Sprite = new Sprite();

        var icon :Bitmap = new Bitmap(bitmapData);
        var scale :Number = (WIDTH / icon.width);
        icon.scaleX = scale;
        icon.scaleY = scale;
        icon.alpha = iconAlpha;

        face.addChild(icon);

        var w :Number = icon.width;
        var h :Number = icon.height;

        // draw our button background (and outline)
        face.graphics.beginFill(background);
        face.graphics.lineStyle(1, foreground);
        face.graphics.drawRect(0, 0, w, h);
        face.graphics.endFill();

        icon.x = 0;
        icon.y = 0;

        // create a text field with the description of the unit, to
        // display above the button
        if (null != descriptionText) {
            var tf :TextField = new TextField();
            tf.background = true;
            tf.backgroundColor = 0xFFFFFF;
            tf.border = true;
            tf.borderColor = 0;
            tf.autoSize = TextFieldAutoSize.LEFT;
            tf.wordWrap = true;
            tf.selectable = false;
            tf.width = 200;
            tf.text = descriptionText;
            tf.y = - tf.height;

            face.addChild(tf);
        }

        return face;
    }

    protected static const WIDTH :uint = 40;

    protected static const COLOR_OUTLINE :uint = 0x000000;
    protected static const COLOR_BG_UP :uint = 0xFFD800;
    protected static const COLOR_BG_OVER :uint = 0xCFAF00;
    protected static const COLOR_BG_DOWN :uint = 0xCFAF00;
    protected static const COLOR_BG_DISABLED :uint = 0x525252;

    protected static const ALPHA_DISABLED :Number = 0.5;
}

}
