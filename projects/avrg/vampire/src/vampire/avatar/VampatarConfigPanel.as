package vampire.avatar {

import fl.controls.ColorPicker;
import fl.events.ColorPickerEvent;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.system.ApplicationDomain;

public class VampatarConfigPanel extends Sprite
{
    public function VampatarConfigPanel (curConfig :VampatarConfig,
                                         applyConfigCallback :Function) :void
    {
        _originalConfig = curConfig;
        _config = curConfig.clone();
        _applyConfigCallback = applyConfigCallback;

        var panelClass :Class = getClass("popup_config");
        var panel :MovieClip = new panelClass();
        addChild(panel);

        // create dropdowns
        var skinButton :SimpleButton = panel["skin_option"];
        createDropdown(
            skinButton,
            [ "Lighter", 0xDEEFF5,
              "Light", 0xD0DFFD,
              "Cool", 0xC2EDD3,
              "Warm", 0xE1C2ED,
              "Dark", 0xC7B4EB,
              "Darker", 0xCCCCCC ],
            function (skinColor :uint) :void {
                if (_config.skinColor != skinColor) {
                    _config.skinColor = skinColor;
                    configUpdated();
                }
            },
            _config.skinColor);

        var hairButton :SimpleButton = panel["hair_option"];
        createDropdown(
            hairButton,
            [ "Long & Wavy", 1,
              "Long & Straight", 2,
              "Shag", 3,
              "Severe", 4 ],
            function (hairNumber :int) :void {
                if (_config.hairNumber != hairNumber) {
                    _config.hairNumber = hairNumber;
                    configUpdated();
                }
            },
            _config.hairNumber);

        var shirtButton :SimpleButton = panel["top_option"];
        createDropdown(
            shirtButton,
            [ "Tee", 1,
              "Corset", 2,
              "Striped", 3,
              "Hoodie", 4 ],
            function (shirtNumber :int) :void {
                if (_config.shirtNumber != shirtNumber) {
                    _config.shirtNumber = shirtNumber;
                    configUpdated();
                }
            },
            _config.shirtNumber);

        var shoesButton :SimpleButton = panel["shoes_option"];
        createDropdown(
            shoesButton,
            [ "Boots", 1,
              "Slip-ons", 2,
              "None", 3 ],
            function (shoesNumber :int) :void {
                if (_config.shoesNumber != shoesNumber) {
                    _config.shoesNumber = shoesNumber;
                    configUpdated();
                }
            },
            _config.shoesNumber);

        // color pickers
        var hairColorButton :ColorPicker = panel["hair_color"];
        hairColorButton.selectedColor = _config.hairColor;
        hairColorButton.addEventListener(ColorPickerEvent.CHANGE,
            function (e :ColorPickerEvent) :void {
                if (_config.hairColor != e.color) {
                    _config.hairColor = e.color;
                    configUpdated();
                }
            });

        var shirtColorButton :ColorPicker = panel["top_color"];
        shirtColorButton.selectedColor = _config.shirtColor;
        shirtColorButton.addEventListener(ColorPickerEvent.CHANGE,
            function (e :ColorPickerEvent) :void {
                if (_config.shirtColor != e.color) {
                    _config.shirtColor = e.color;
                    configUpdated();
                }
            });

        var shoesColorButton :ColorPicker = panel["shoes_color"];
        shoesColorButton.selectedColor = _config.shoesColor;
        shoesColorButton.addEventListener(ColorPickerEvent.CHANGE,
            function (e :ColorPickerEvent) :void {
                if (_config.shoesColor != e.color) {
                    _config.shoesColor = e.color;
                    configUpdated();
                }
            });

        // A hack to fake mouse capture when a dropdown is being displayed. (Captures
        // all clicks outside the dropdown, and closes the dropdown without allowing the
        // clicks to have any other affect.)
        _mouseCapture = new Sprite();
        var g :Graphics = _mouseCapture.graphics;
        g.beginFill(0, 0);
        g.drawRect(0, 0, this.width, this.height);
        g.endFill();
        _mouseCapture.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                hideAllPickers();
            });
    }

    protected function createDropdown (button :SimpleButton, items :Array,
                                       onItemSelected :Function, initialValue :*) :void
    {
        var dropdown :Dropdown = new Dropdown(button, items, onItemSelected);
        dropdown.x = button.x;
        dropdown.y = button.y;
        dropdown.selectItemByValue(initialValue);

        button.addEventListener(MouseEvent.MOUSE_DOWN,
            function (...ignored) :void {
                showPicker(dropdown);
            });

        _pickers.push(dropdown);
    }

    protected function showPicker (picker :DisplayObject) :void
    {
        hideAllPickers();

        _mouseCapture.addChild(picker);
        addChild(_mouseCapture);
    }

    protected function hideAllPickers () :void
    {
        for each (var picker :DisplayObject in _pickers) {
            if (picker.parent != null) {
                picker.parent.removeChild(picker);
            }
        }

        if (_mouseCapture.parent != null) {
            _mouseCapture.parent.removeChild(_mouseCapture);
        }
    }

    protected function configUpdated () :void
    {
        _applyConfigCallback(_config);
    }

    protected static function randPick (arr :Array) :*
    {
        return (arr.length == 0 ? undefined : arr[rand(0, arr.length - 1)]);
    }

    protected static function rand (lo :uint, hi :uint) :uint
    {
        return lo + (Math.random() * (hi - lo + 1));
    }

    protected var _pickers :Array = [];
    protected var _mouseCapture :Sprite;

    protected var _originalConfig :VampatarConfig;
    protected var _config :VampatarConfig;
    protected var _applyConfigCallback :Function;
}

}

import flash.display.Sprite;
import flash.system.ApplicationDomain;
import flash.display.SimpleButton;
import flash.text.TextField;
import flash.events.MouseEvent;
import flash.display.DisplayObjectContainer;
import com.threerings.util.Log;
import flash.display.DisplayObject;

function getClass (name :String) :Class
{
    return ApplicationDomain.currentDomain.getDefinition(name) as Class;
}

class Dropdown extends Sprite
{
    public function Dropdown (button :SimpleButton, items :Array,
                              onItemSelected :Function)
    {
        _button = button;
        _items = items;
        _onItemSelected = onItemSelected;

        var dropdownClass :Class = getClass("dropdown_option");
        var yOffset :Number = 0;
        for (var ii :int = 0; ii < items.length; ii += 2) {
            var name :String = items[ii];
            var value :* = items[ii + 1];

            var selectButton :SimpleButton = new dropdownClass();
            setButtonText(selectButton, name);
            selectButton.addEventListener(MouseEvent.CLICK, createItemSelectedCallback(ii));
            selectButton.x = (selectButton.width * 0.5);
            selectButton.y = (selectButton.height * 0.5) + yOffset;
            addChild(selectButton);

            yOffset += 15;
        }
    }

    public function selectItemByName (name :String) :void
    {
        for (var ii :int = 0; ii < _items.length; ii += 2) {
            if (_items[ii] == name) {
                selectItem(ii);
            }
        }
    }

    public function selectItemByValue (value :*) :void
    {
        for (var ii :int = 0; ii < _items.length; ii += 2) {
            if (_items[ii + 1] == value) {
                selectItem(ii);
            }
        }
    }

    protected function selectItem (idx :int) :void
    {
        var name :String = _items[idx];
        var value :* = _items[idx + 1];

        setButtonText(_button, name);

        _onItemSelected(value);
    }

    protected function createItemSelectedCallback (idx :int) :Function
    {
        return function (...ignored) :void {
            selectItem(idx);
        };
    }

    protected static function setButtonText (button :SimpleButton, text :String)
        :void
    {
        // Holy shit, this is an ugly hack. Flash doesn't allow access to named
        // instances inside SimpleButtons, because they aren't DisplayObjectContainers.
        // So we iterate the children of the each of the button's display states until we
        // find a TextField, and use that. This might fail if there are multiple TextFields.
        var setText :Function = function (disp :DisplayObjectContainer) :void {
            for (var ii :int = 0; ii < disp.numChildren; ++ii) {
                var child :DisplayObject = disp.getChildAt(ii);
                if (child is TextField) {
                    (child as TextField).text = text;
                    return;
                }
            }
        }

        setText(button.upState);
        setText(button.downState);
        setText(button.overState);
        setText(button.hitTestState);
    }

    protected var _button :SimpleButton;
    protected var _items :Array;
    protected var _onItemSelected :Function;

    protected static const log :Log = Log.getLog(Dropdown);
}
