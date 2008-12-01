package {

import flash.display.DisplayObject;
import flash.display.Sprite;

import flash.filters.GlowFilter;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;

import flash.geom.Matrix;

import flash.text.Font;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;

import flash.utils.ByteArray;
import flash.utils.Timer;

import fl.controls.Label;
import fl.controls.CheckBox;
import fl.controls.ColorPicker;
import fl.controls.ComboBox;
import fl.controls.Slider;

import fl.events.ColorPickerEvent;
import fl.events.SliderEvent;

import fl.skins.DefaultCheckBoxSkins;
import fl.skins.DefaultColorPickerSkins;
import fl.skins.DefaultComboBoxSkins;
import fl.skins.DefaultSliderSkins;

import com.threerings.util.StringUtil;

import com.whirled.FurniControl;
import com.whirled.ControlEvent;

[SWF(width="300", height="150")]
public class Text extends Sprite
{
    public static const WIDTH :int = 300;

    // reference skin classes we use
    DefaultCheckBoxSkins;
    DefaultColorPickerSkins;
    DefaultComboBoxSkins;
    DefaultSliderSkins;

    public function Text ()
    {
        _ctrl = new FurniControl(this);
        _ctrl.addEventListener(Event.UNLOAD, handleUnload);
        _ctrl.addEventListener(ControlEvent.MEMORY_CHANGED, handleMemoryChanged);
        _ctrl.registerCustomConfig(createConfigPanel);

        _field = new TextField();
        _field.autoSize = TextFieldAutoSize.LEFT;
        _field.wordWrap = true;
        _field.multiline = true;
        addChild(_field);

        handleMemoryChanged();
        addEventListener(Event.ENTER_FRAME, checkScale);
    }

    protected function checkScale (... ignored) :void
    {
        var matrix :Matrix = this.transform.concatenatedMatrix;
        // make the textfield take up all our visual width, but correct for scaling so that it appears at 1.0
        _field.width = WIDTH * matrix.a;
        _field.scaleX = 1 / matrix.a;
        _field.scaleY = 1 / matrix.d;;
    }

    protected function handleMemoryChanged (... ignored) :void
    {
        var format :TextFormat = new TextFormat();
        format.font = getMem(FONT) as String;
        format.size = getMem(SIZE);
        format.color = getMem(COLOR);
        format.bold = getMem(BOLD);
        format.italic = getMem(ITALIC);

        _field.defaultTextFormat = format;
        _field.selectable = getMem(SELECTABLE) as Boolean;
//        if (_field.length > 0) {
//            _field.setTextFormat(format, 0, _field.length);
//        }
        _field.text = getMem(TEXT) as String;

        var outline :Object = getMem(OUTLINE_COLOR);
        if (outline != null) {
            _field.filters = [ new GlowFilter(uint(outline), 1, 2, 2, 255) ];
        } else {
            _field.filters = null;
        }
    }

    protected function handleUnload (event :Event) :void
    {
        removeEventListener(Event.ENTER_FRAME, checkScale);
    }

    protected function createConfigPanel () :DisplayObject
    {
        var s :Sprite = new Sprite();

        var tf :TextField = new TextField();
        tf.background = true;
        tf.backgroundColor = 0xFFFFFF;
        tf.border = true;
        tf.borderColor = 0x000000;
        tf.multiline = true;
        tf.type = TextFieldType.INPUT;
        tf.wordWrap = true;
        tf.width = 250;
        tf.height = 122;
        tf.text = getMem(TEXT) as String;
        s.addChild(tf);

        // focus handling for flash 10 and above??
        tf.addEventListener(MouseEvent.CLICK, function (... ignored) :void {
            tf.stage.focus = tf;
        });

        var yy :int = 125;
        addLabel(s, "Font face", yy);
        var font :ComboBox = new ComboBox();
        var setFont :String = getMem(FONT) as String;
        for each (var obj :Object in FONTS) {
            font.addItem(obj);
            if (setFont == obj.data) {
                font.selectedItem = obj;
            }
        }
        font.setSize(140, 22);
        font.x = 100;
        font.y = yy;
        s.addChild(font);
        font.addEventListener(Event.CHANGE, function (... ignored) :void {
            setMem(FONT, font.selectedItem.data);
        });

        yy += 25;
        addLabel(s, "Font size", yy);
        var size :Slider = new Slider();
        size.minimum = 10;
        size.maximum = 96;
        size.snapInterval = 1;
        size.liveDragging = true;
        size.value = getMem(SIZE) as int;
        size.setSize(140, 22);
        size.x = 100;
        size.y = yy;
        s.addChild(size);

        yy += 25;
        addLabel(s, "Color", yy);
        var color :ColorPicker = new ColorPicker();
        color.selectedColor = getMem(COLOR) as uint;
        color.setSize(22, 22);
        color.x = 100;
        color.y = yy;
        s.addChild(color);
        color.addEventListener(ColorPickerEvent.CHANGE, function (... ignored) :void {
            setMem(COLOR, color.selectedColor);
        });

        yy += 25;
        addLabel(s, "Bold", yy);
        var bold :CheckBox = new CheckBox();
        bold.selected = getMem(BOLD) as Boolean;
        bold.setSize(22, 22);
        bold.x = 100;
        bold.y = yy;
        s.addChild(bold);
        bold.addEventListener(Event.CHANGE, function (... ignored) :void {
            setMem(BOLD, bold.selected);
        });

        yy += 25;
        addLabel(s, "Italic", yy);
        var italic :CheckBox = new CheckBox();
        italic.selected = getMem(ITALIC) as Boolean;
        italic.setSize(22, 22);
        italic.x = 100;
        italic.y = yy;
        s.addChild(italic);
        italic.addEventListener(Event.CHANGE, function (... ignored) :void {
            setMem(ITALIC, italic.selected);
        });

        yy += 25;
        addLabel(s, "Outline", yy);
        var outline :CheckBox = new CheckBox();
        outline.selected = (null != getMem(OUTLINE_COLOR));
        outline.setSize(22, 22);
        outline.x = 100;
        outline.y = yy;
        s.addChild(outline);

        var outlineColor :ColorPicker = new ColorPicker();
        outlineColor.selectedColor = getMem(OUTLINE_COLOR) as uint;
        outlineColor.setSize(22, 22);
        outlineColor.x = 140;
        outlineColor.y = yy;
        s.addChild(outlineColor);
        outlineColor.addEventListener(Event.ADDED_TO_STAGE, function (... ignored) :void {
            outlineColor.enabled = outline.selected;
        });

        var updateOutlineColor :Function = function (... ignored) :void {
            setMem(OUTLINE_COLOR, outline.selected ? outlineColor.selectedColor : null);
        };
        outline.addEventListener(Event.CHANGE, function (... ignored) :void {
            outlineColor.enabled = outline.selected;
            updateOutlineColor();
        });
        outlineColor.addEventListener(ColorPickerEvent.CHANGE, updateOutlineColor);

        yy += 25;
        addLabel(s, "Selectable", yy);
        var selectable :CheckBox = new CheckBox();
        selectable.selected = getMem(SELECTABLE) as Boolean;
        selectable.setSize(22, 22);
        selectable.x = 100;
        selectable.y = yy;
        s.addChild(selectable);
        selectable.addEventListener(Event.CHANGE, function (... ignored) :void {
            setMem(SELECTABLE, selectable.selected);
        });

        // fill a transparent area in the sprite so that it can get mouse clicks better
        s.graphics.beginFill(0xFF0000, 0);
        s.graphics.drawRect(0, 0, 250, yy + 25);
        s.graphics.endFill();

        // finally, some things can change so rapidly that we only update them every half second
        var updateTextAndSize :Function = function (... ignored) :void {
            setMem(TEXT, tf.text);
            setMem(SIZE, size.value);
        };
        var timer :Timer = new Timer(500);
        timer.addEventListener(TimerEvent.TIMER, updateTextAndSize);
        s.addEventListener(Event.ADDED_TO_STAGE, function (... ignored) :void {
            timer.start();
        });
        s.addEventListener(Event.REMOVED_FROM_STAGE, function (... ignored) :void {
            updateTextAndSize(); // one last time..
            timer.stop();
        });

        return s;
    }

    protected function addLabel (s :Sprite, text :String, y :int) :void
    {
        var l :Label = new Label();
        l.text = text + ":";
        l.setSize(100, 22);
        l.y = y;
        s.addChild(l);
    }

    protected function getMem (mem :Array) :Object
    {
        var result :Object = _ctrl.getMemory(mem[0], mem[1]);
        if (Boolean(mem[2]) && (result is ByteArray)) {
            var ba :ByteArray = result as ByteArray;
            ba.uncompress();
            return ba.readUTF();
        }
        return result;
    }

    protected function setMem (mem :Array, newValue :Object) :void
    {
        if (getMem(mem) == newValue) {
            return;
        }

        if (mem[1] == newValue) {
            newValue = null;
        }
        if (newValue is String && Boolean(mem[2])) {
            // try compressing it
            var strValue :String = newValue as String;
            var ba :ByteArray = new ByteArray();
            ba.writeUTF(strValue);
            ba.compress();
            // if the compressed form is shorter, let's use that instead
            if (ba.length < strValue.length) {
                newValue = ba;
            }
        }
        _ctrl.setMemory(mem[0], newValue);
    }

    protected var _ctrl :FurniControl;

    protected var _field :TextField;

    /** Memory constants: key name, default value, whether to try to compress in a ByteArray. */
    protected static const TEXT :Array = [ "txt", "", true ];
    protected static const FONT :Array = [ "fnt", "Times New Roman" ];
    protected static const SIZE :Array = [ "siz", 16 ];
    protected static const BOLD :Array = [ "bld", false ];
    protected static const ITALIC :Array = [ "itl", false ];
    protected static const COLOR :Array = [ "clr", 0x000000 ];
    protected static const OUTLINE_COLOR :Array = [ "out", null ];
    protected static const SELECTABLE :Array = [ "sel", false ]; 

    protected static const FONTS :Array = [ { label: "Serif", data: "Times New Roman" }, { label: "Sans serif", data: "_sans" } ];
}
}
