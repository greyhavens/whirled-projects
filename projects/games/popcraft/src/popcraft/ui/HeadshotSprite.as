package popcraft.ui {

import com.threerings.flash.DisplayUtil;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.InteractiveObject;
import flash.display.Shape;
import flash.display.Sprite;

import popcraft.*;

public class HeadshotSprite extends Sprite
{
    public function HeadshotSprite (playerSeat :int, width :int, height :int,
        image :DisplayObject = null)
    {
        _width = width;
        _height = height;
        // If no image is supplied, let's pull the appropriate one out of the Seating Manager
        _image = (image != null ? image : ClientCtx.seatingMgr.getPlayerHeadshot(playerSeat, true));
        updateDisplay();

        this.mouseEnabled = false;
        this.mouseChildren = false;
    }

    public function setImage (image :DisplayObject) :void
    {
        _image = image;
        updateDisplay();
    }

    public function setSize (width :int, height :int) :void
    {
        _width = width;
        _height = height;
        updateDisplay();
    }

    override public function set width (value :Number) :void
    {
        setSize(value, _height);
    }

    override public function set height (value :Number) :void
    {
        setSize(_width, value);
    }

    protected function updateDisplay () :void
    {
        while (this.numChildren > 0) {
            removeChildAt(0);
        }

        this.mask = null

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

    protected var _width :int;
    protected var _height :int;
    protected var _image :DisplayObject;
}

}
