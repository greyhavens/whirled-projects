package {

import flash.display.DisplayObject;
import flash.display.Sprite;

import flash.filters.GlowFilter;

import flash.events.Event;
import flash.events.TimerEvent;

import flash.geom.Matrix;

import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;

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
        format.size = getMem(SIZE);
        format.color = getMem(COLOR);
        format.bold = getMem(BOLD);
        format.italic = getMem(ITALIC);

        _field.defaultTextFormat = format;
        _field.selectable = getMem(SELECTABLE) as Boolean;
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

        var updateText :Function = function (... ignored) :void {
            setMem(TEXT, tf.text);
        };

        var timer :Timer = new Timer(1000);
        timer.addEventListener(TimerEvent.TIMER, updateText);
        // TODO: this might be a bad idea..
        tf.addEventListener(Event.ADDED_TO_STAGE, function (... ignored) :void {
            timer.start();
        });
        tf.addEventListener(Event.REMOVED_FROM_STAGE, function (... ignored) :void {
            updateText(); // one last time..
            timer.stop();
        });

        addLabel(s, "Font size", 125);
        var size :Slider = new Slider();
        size.minimum = 8;
        size.maximum = 50;
        size.snapInterval = 1;
        size.value = getMem(SIZE) as int;
        size.setSize(100, 22);
        size.x = 110;
        size.y = 125;
        s.addChild(size);
        size.addEventListener(SliderEvent.CHANGE, function (... ignored) :void {
            setMem(SIZE, size.value);
        });

        addLabel(s, "Color", 150);
        var color :ColorPicker = new ColorPicker();
        color.selectedColor = getMem(COLOR) as uint;
        color.setSize(22, 22);
        color.x = 110;
        color.y = 150;
        s.addChild(color);
        color.addEventListener(ColorPickerEvent.CHANGE, function (event :ColorPickerEvent) :void {
            setMem(COLOR, event.color);
        });

        addLabel(s, "Bold", 175);
        var bold :CheckBox = new CheckBox();
        bold.selected = getMem(BOLD) as Boolean;
        bold.setSize(22, 22);
        bold.x = 110;
        bold.y = 175;
        s.addChild(bold);
        bold.addEventListener(Event.CHANGE, function (... ignored) :void {
            setMem(BOLD, bold.selected);
        });

        addLabel(s, "Italic", 200);
        var italic :CheckBox = new CheckBox();
        italic.selected = getMem(ITALIC) as Boolean;
        italic.setSize(22, 22);
        italic.x = 110;
        italic.y = 200;
        s.addChild(italic);
        italic.addEventListener(Event.CHANGE, function (... ignored) :void {
            setMem(ITALIC, italic.selected);
        });

        addLabel(s, "Outline", 225);
        var outline :CheckBox = new CheckBox();
        outline.selected = (null != getMem(OUTLINE_COLOR));
        outline.setSize(22, 22);
        outline.x = 110;
        outline.y = 225;
        s.addChild(outline);

        var outlineColor :ColorPicker = new ColorPicker();
        outlineColor.selectedColor = getMem(OUTLINE_COLOR) as uint;
        outlineColor.setSize(22, 22);
        outlineColor.x = 150;
        outlineColor.y = 225;
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

        addLabel(s, "Selectable", 250);
        var selectable :CheckBox = new CheckBox();
        selectable.selected = getMem(SELECTABLE) as Boolean;
        selectable.setSize(22, 22);
        selectable.x = 110;
        selectable.y = 250;
        s.addChild(selectable);
        selectable.addEventListener(Event.CHANGE, function (... ignored) :void {
            setMem(SELECTABLE, selectable.selected);
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
        return _ctrl.lookupMemory(mem[0], mem[1]);
    }

    protected function setMem (mem :Array, newValue :Object) :void
    {
        if (getMem(mem) != newValue) {
            _ctrl.updateMemory(mem[0], (mem[1] == newValue) ? null : newValue);
        }
    }

    protected var _ctrl :FurniControl;

    protected var _field :TextField;

    /** Memory constants: key name and default value. */
    protected static const TEXT :Array = [ "txt", "" ];
    protected static const SIZE :Array = [ "siz", 16 ];
    protected static const BOLD :Array = [ "bld", false ];
    protected static const ITALIC :Array = [ "itl", false ];
    protected static const COLOR :Array = [ "clr", 0x000000 ];
    protected static const OUTLINE_COLOR :Array = [ "out", null ];
    protected static const SELECTABLE :Array = [ "sel", false ];
}
}
