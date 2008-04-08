package {

import flash.display.DisplayObject;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.TimerEvent;

import flash.geom.Matrix;

import flash.text.TextField;
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
        _field.wordWrap = true;
        _field.multiline = true;
        addChild(_field);

        handleMemoryChanged();
//        _field.text = "This here is some sample text that I hope will word-wrap and generally " +
//            "look good, even if I enter in some crazy long-ass shit that totally boochificates " +
//            "normal sensible layout. Or not. I like hamsters, they are like little bears. " +
//            "Only bears don't stuff their cheeks overfull with sunflower seeds. I wish bears " +
//            "did that. I used to put hamsters on my cat's back, and the hamsters would grip on " +
//            "with their little grippy paws, and the cat would freak out and run, but for a " +
//            "little while the hamster would stay on- riding the cat like a little furry-faced " +
//            "knight on horse. Well, ok, more like a little bear holding onto a giant " +
//            "mythical cat-beast, and not really getting that far.";

        addEventListener(Event.ENTER_FRAME, checkScale);
    }

    protected function checkScale (... ignored) :void
    {
        var matrix :Matrix = this.transform.concatenatedMatrix;
        _field.width = WIDTH * matrix.a;
        _field.scaleX = 1 / matrix.a;
        _field.scaleY = 1 / matrix.d;;
    }

    protected function handleMemoryChanged (... ignored) :void
    {
//        _field.text = "";

        var format :TextFormat = new TextFormat();
        format.size = _ctrl.lookupMemory(SIZE, 16) as int;
        _field.defaultTextFormat = format;

        _field.text = _ctrl.lookupMemory(TEXT, "") as String;
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
        tf.text = _ctrl.lookupMemory(TEXT, "") as String;
        s.addChild(tf);

        var updateText :Function = function (... ignored) :void {
            var newText :String = StringUtil.trim(tf.text);
            if (newText != _ctrl.lookupMemory(TEXT)) {
                trace("Updating text: " + newText);
                _ctrl.updateMemory(TEXT, newText);
            } else {
                trace("Text is the same: " + newText);
            }
        };

        var timer :Timer = new Timer(1000);
        timer.addEventListener(TimerEvent.TIMER, updateText);
        // TODO: this might be a bad idea..
        tf.addEventListener(Event.ADDED_TO_STAGE, function (... ignored) :void {
            timer.start();
        });
        tf.addEventListener(Event.REMOVED_FROM_STAGE, function (... ignored) :void {
            timer.stop();
        });

        var l :Label = new Label();
        l.text = "Font size:";
        l.setSize(100, 22);
        l.y = 125;
        s.addChild(l);

        var size :Slider = new Slider();
        size.minimum = 8;
        size.maximum = 50;
        size.snapInterval = 1;
        size.value = _ctrl.lookupMemory(SIZE, 16) as int;
        size.setSize(100, 22);
        size.x = 110;
        size.y = 125;
        s.addChild(size);
        size.addEventListener(SliderEvent.CHANGE, function (... ignored) :void {
            trace("Updating size");
            _ctrl.updateMemory(SIZE, size.value);
        });

        return s;
    }

    /** Memory key constants. */
    protected static const TEXT :String = "txt";
    protected static const SIZE :String = "siz";
    protected static const BOLD :String = "bld";
    protected static const ITALIC :String = "itl";
    protected static const COLOR :String = "clr";
    protected static const OUTLINE_COLOR :String = "out";

    protected var _ctrl :FurniControl;

    protected var _field :TextField;
}
}

//class Memories
//{
//    public function Memories (ctrl :FurniControl)
//    {
//        _ctrl = ctrl;
//    }
//
//    public function set text (text :String) :void
//    {
//        _ctrl.updateMemory
//    }
//
//    public function set size (
//}
