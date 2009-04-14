package config {

import com.threerings.util.Log;

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.system.ApplicationDomain;

public class ConfigPanel extends Sprite
{
    public function ConfigPanel (curConfigData :ConfigData, applyConfigCallback :Function) :void
    {
        _originalConfig = curConfigData;
        _config = curConfigData.clone();
        _applyConfigCallback = applyConfigCallback;

        var panelClass :Class = getClass("popup_config");
        var panel :MovieClip = new panelClass();
        addChild(panel);

        // create dropdowns
        var topDropdown :Dropdown = createDropdown(
            panel["top_option"],
            numberItems([ "Button-Down", "Striped", "Tee", "None", "Jacket" ]),
            function (value :int) :void {
                if (_config.topNumber != value) {
                    _config.topNumber = value;
                    configUpdated();
                }
            },
            _config.topNumber);

        // color pickers
        var skinPicker :MyColorPicker = createColorPicker(
            MyColorPicker.PALETTE_SKIN,
            panel["skin_color"],
            function (color :uint) :void {
                if (_config.skinColor != color) {
                    _config.skinColor = color;
                    configUpdated();
                }
            },
            _config.skinColor);

        var pantsPicker :MyColorPicker = createColorPicker(
            MyColorPicker.PALETTE_GENERAL,
            panel["pants_color"],
            function (color :uint) :void {
                if (_config.pantsColor != color) {
                    _config.pantsColor = color;
                    configUpdated();
                }
            },
            _config.pantsColor);

        var topPicker :MyColorPicker = createColorPicker(
            MyColorPicker.PALETTE_GENERAL,
            panel["top_color"],
            function (color :uint) :void {
                if (_config.topColor != color) {
                    _config.topColor = color;
                    configUpdated();
                }
            },
            _config.topColor);

        // randomize button
        var randomizeButton :SimpleButton = panel["button_randomize"];
        randomizeButton.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                // suppress config updates until all options have been chosen, so
                // that we don't flood the network with meaningless updates
                _suppressConfigUpdates = true;

                topDropdown.selectRandomItem();
                skinPicker.selectRandomColor();
                pantsPicker.selectRandomColor();
                topPicker.selectRandomColor();

                _suppressConfigUpdates = false;
                configUpdated();
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
                                       onItemSelected :Function, initialValue :*) :Dropdown
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

        return dropdown;
    }

    protected function createColorPicker (type :int,
                                          button :MovieClip,
                                          onColorSelected :Function,
                                          initialColor :uint) :MyColorPicker
    {
        var cp :MyColorPicker = new MyColorPicker(type, button, onColorSelected);
        cp.x = button.x;
        cp.y = button.y;
        cp.selectColor(initialColor);

        button.addEventListener(MouseEvent.MOUSE_DOWN,
            function (...ignored) :void {
                showPicker(cp);
            });

        _pickers.push(cp);

        return cp;
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
        if (!_suppressConfigUpdates) {
            _applyConfigCallback(_config);
        }
    }

    protected static function numberItems (arr :Array) :Array
    {
        // Given [ "apple", "orange", "banana" ], returns [ "apple", 1, "orange", 2, "banana", 3 ]
        var out :Array = [];
        for (var ii :int = 0; ii < arr.length; ++ii) {
            out.push(arr[ii], ii + 1);
        }

        return out;
    }

    protected var _pickers :Array = [];
    protected var _mouseCapture :Sprite;

    protected var _originalConfig :ConfigData;
    protected var _config :ConfigData;
    protected var _applyConfigCallback :Function;
    protected var _suppressConfigUpdates :Boolean;

    protected static const log :Log = Log.getLog(ConfigPanel);
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
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.BitmapData;
import com.whirled.contrib.platformer.piece.Rect;
import flash.geom.Rectangle;
import flash.geom.Matrix;
import flash.display.Bitmap;
import com.whirled.contrib.ColorMatrix;

function getClass (name :String) :Class
{
    return ApplicationDomain.currentDomain.getDefinition(name) as Class;
}

function randPick (arr :Array) :*
{
    return (arr.length == 0 ? undefined : arr[rand(0, arr.length - 1)]);
}

function rand (lo :uint, hi :uint) :uint
{
    return lo + (Math.random() * (hi - lo + 1));
}

class MyColorPicker extends Sprite
{
    public static const PALETTE_SKIN :int = 0;
    public static const PALETTE_GENERAL :int = 1;

    public static function randPaletteColor (paletteType :int) :uint
    {
        var bm :BitmapData = _bitmaps[paletteType];
        return bm.getPixel(rand(0, bm.width - 1), rand(0, bm.height - 1));
    }

    public function MyColorPicker (type :int, button :MovieClip, onColorSelected :Function)
    {
        _button = button;
        _type = type;
        _onColorSelected = onColorSelected;

        var uiSprite :Sprite = new Sprite();

        _swatch = new Shape();
        uiSprite.addChild(_swatch);

        var paletteClass :Class = getClass(PALETTE_MOVIES[type]);
        _palette = new paletteClass();
        _palette.scaleX = _palette.scaleY = SCALES[type];
        _palette.y = SWATCH_HEIGHT;
        uiSprite.addChild(_palette);

        setSwatchColor(0xffffff);

        var g :Graphics = this.graphics;
        g.beginFill(0);
        g.drawRect(0, 0, uiSprite.width + (BORDER * 2), uiSprite.height + (BORDER * 2));
        g.endFill();

        uiSprite.x = (this.width - uiSprite.width) * 0.5;
        uiSprite.y = (this.height - uiSprite.height) * 0.5;
        addChild(uiSprite);

        if (_bitmaps[type] == null) {
            _bitmaps[type] = getBitmapData(_palette);
        }

        _palette.addEventListener(MouseEvent.MOUSE_MOVE,
            function (e :MouseEvent) :void {
                var bm :BitmapData = _bitmaps[type];
                if (e.localX >= 0 && e.localX < bm.width && e.localY >= 0 && e.localY < bm.height) {
                    setSwatchColor(bm.getPixel(e.localX, e.localY));
                }
            });

        _palette.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                selectColor(_swatchColor);
            });
    }

    public function selectColor (color :uint) :void
    {
        setSwatchColor(color);
        _button.filters = [ new ColorMatrix().colorize(color).createFilter() ];
        _onColorSelected(color);
    }

    public function selectRandomColor () :void
    {
        var bm :BitmapData = _bitmaps[_type];
        selectColor(bm.getPixel(rand(0, bm.width - 1), rand(0, bm.height - 1)));
    }

    protected function setSwatchColor (color :uint) :void
    {
        _swatch.graphics.beginFill(color);
        _swatch.graphics.drawRect(0, 0, _palette.width, SWATCH_HEIGHT);
        _swatch.graphics.endFill();

        _swatchColor = color;
    }

    protected static function getBitmapData (src :DisplayObject) :BitmapData
    {
        var bounds :Rectangle = src.getBounds(src);
        var bd :BitmapData = new BitmapData(bounds.width, bounds.height, true, 0);
        bd.draw(src, new Matrix(1, 0, 0, 1, -bounds.x, -bounds.y));
        return bd;
    }

    protected var _button :MovieClip;
    protected var _type :int;
    protected var _onColorSelected :Function;
    protected var _palette :MovieClip;
    protected var _swatch :Shape;
    protected var _swatchColor :uint;

    protected static var _bitmaps :Array = [ null, null ];

    protected static const PALETTE_MOVIES :Array = [ "palette_skin", "palette_all" ];
    protected static const SCALES :Array = [ 3, 2 ];

    protected static const SWATCH_HEIGHT :int = 20;
    protected static const BORDER :int = 6;
}

class Dropdown extends Sprite
{
    public function Dropdown (button :SimpleButton, items :Array,
                              onItemSelected :Function)
    {
        _button = button;
        _items = items;
        _onItemSelected = onItemSelected;

        var uiSprite :Sprite = new Sprite();
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
            uiSprite.addChild(selectButton);

            yOffset += 15;
        }

        var g :Graphics = this.graphics;
        g.beginFill(0);
        g.drawRect(0, 0, uiSprite.width + (BORDER * 2), uiSprite.height + (BORDER * 2));
        g.endFill();

        uiSprite.x = (this.width - uiSprite.width) * 0.5;
        uiSprite.y = (this.height - uiSprite.height) * 0.5;
        addChild(uiSprite);
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

    public function selectRandomItem () :void
    {
        selectItem(2 * rand(0, (_items.length / 2) - 1));
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

    protected static const BORDER :Number = 6;
}
