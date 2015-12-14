package {

import flash.display.DisplayObject;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.MouseEvent;

import fl.controls.Label;
import fl.controls.ColorPicker;
import fl.controls.ComboBox;

import fl.events.ColorPickerEvent;

import fl.skins.DefaultColorPickerSkins;
import fl.skins.DefaultComboBoxSkins;

import com.threerings.flash.FrameSprite;

import com.whirled.ControlEvent;
import com.whirled.FurniControl;

[SWF(width="200", height="200")]
public class Sparkler extends FrameSprite
{
    public function Sparkler ()
    {
        super(false);

        _ctrl = new FurniControl(this);
        _ctrl.registerCustomConfig(createConfigPanel);
        _ctrl.addEventListener(ControlEvent.MEMORY_CHANGED, handleMemoryChanged);
        _lifetime = _ctrl.getMemory("lifetime", 2000) as int;
        _color = _ctrl.getMemory("color", 0xFFFFFF) as uint;

        //addChild(createConfigPanel());
    }

    private static function refShit () :void
    {
        DefaultColorPickerSkins;
        DefaultComboBoxSkins;
    }

//    override public function hitTestPoint (
//        x :Number, y :Number, shapeFlag :Boolean = false) :Boolean
//    {
//        return false;
//    }

    override protected function handleFrame (... ignored) :void
    {
        var mx :Number = mouseX;
        var my :Number = mouseY;
        if (mx != _lastX || my != _lastY) {
            _lastX = mx;
            _lastY = my;
            addChild(new Sparkle(mx, my, _color, _lifetime));
        }
    }

    protected function handleMemoryChanged (event :ControlEvent) :void
    {
        switch (event.name) {
        case "lifetime":
            _lifetime = event.value as int;
            break;

        case "color":
            _color = event.value as uint;
            break;
        }
    }

    protected function createConfigPanel () :DisplayObject
    {
        var s :Sprite = new Sprite();

        var label :Label = new Label();
        label.text = "Sparkle color:";
        label.setSize(100, 22);
        s.addChild(label);

        var colorPicker :ColorPicker = new ColorPicker();
        colorPicker.selectedColor = _color;
        colorPicker.addEventListener(ColorPickerEvent.CHANGE, handleColorPicked)
        colorPicker.x = 110;
        colorPicker.setSize(22, 22);
        s.addChild(colorPicker);

        label = new Label();
        label.text = "Sparkle lifetime:";
        label.setSize(100, 22);
        label.y = 25;
        s.addChild(label);

        var box :ComboBox = new ComboBox();
        for each (var time :int in LIFETIMES) {
            var o :Object = { data: time };
            if (time >= 1000) {
                o.label = (time / 1000) + " seconds";
            } else {
                o.label = time + " milliseconds";
            }
            box.addItem(o);
            if (time == _lifetime) {
                box.selectedItem = o;
            }
        }
        box.addEventListener(Event.CHANGE, handleLifetimePicked);
        box.setSize(100, 22);
        box.x = 110;
        box.y = 25;
        s.addChild(box);

        return s;
    }

    protected function handleColorPicked (event :ColorPickerEvent) :void
    {
        _color = event.color;
        _ctrl.setMemory("color", _color);
    }

    protected function handleLifetimePicked (event :Event) :void
    {
        _lifetime = (event.target as ComboBox).selectedItem.data as int;
        _ctrl.setMemory("lifetime", _lifetime);
    }

    protected var _ctrl :FurniControl;

    /** The lifetime of a sparkle, in ms. */
    protected var _lifetime :int;

    /** The color of a sparkle. */
    protected var _color :uint;

    protected var _lastX :Number = NaN;
    protected var _lastY :Number = NaN;

    protected static const LIFETIMES :Array = [ 100, 500, 1000, 1500, 2000, 3000, 5000, 10000 ];
}
}
