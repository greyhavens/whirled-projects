package popcraft.ui {

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;

import popcraft.*;

public class HeadshotSprite extends Sprite
{
    public function HeadshotSprite (playerSeat :int, width :int, height :int,
        image :DisplayObject = null)
    {
        _playerSeat = playerSeat;
        _width = width;
        _height = height;
        setImage(image);

        this.mouseEnabled = false;
        this.mouseChildren = false;
    }

    public function useDefaultHeadshotImage () :void
    {
        setImage(null);
    }

    public function setImage (image :DisplayObject) :void
    {
        // If no image is supplied, pull the appropriate one out of the Seating Manager
        if (image == null) {
            if (_defaultHeadshot == null) {
                _defaultHeadshot = ClientCtx.seatingMgr.getPlayerHeadshot(_playerSeat, true);
            }
            image = _defaultHeadshot;
        }

        updateDisplay(image);
    }

    public function setSize (width :int, height :int) :void
    {
        _width = width;
        _height = height;
        updateDisplay(_image);
    }

    override public function set width (value :Number) :void
    {
        setSize(value, _height);
    }

    override public function set height (value :Number) :void
    {
        setSize(_width, value);
    }

    protected function updateDisplay (newImage :DisplayObject) :void
    {
        if (_image != null) {
            removeChild(_image);
        }

        _image = newImage;
        this.mask = null;

        if (_image == null) {
            return;
        }

        // add the image, scaled appropriately
        _image.scaleX = 1;
        _image.scaleY = 1;
        var scale :Number = Math.max(_width / _image.width, _height / _image.height);
        _image.scaleX = scale;
        _image.scaleY = scale;
        _image.x = (_width - _image.width) * 0.5;
        _image.y = (_height - _image.height) * 0.5;
        addChild(_image);

        // mask
        var headshotMask :Shape = new Shape();
        var g :Graphics = headshotMask.graphics;
        g.beginFill(0);
        g.drawRect(0, 0, _width, _height);
        g.endFill();
        addChild(headshotMask);
        this.mask = headshotMask;
    }

    protected var _playerSeat :int;
    protected var _defaultHeadshot :DisplayObject;
    protected var _width :int;
    protected var _height :int;
    protected var _image :DisplayObject;
}

}
