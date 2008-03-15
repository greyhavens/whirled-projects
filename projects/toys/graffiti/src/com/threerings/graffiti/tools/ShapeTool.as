// $Id$

package com.threerings.graffiti.tools {

import flash.utils.ByteArray;

import com.threerings.util.HashMap;

public class ShapeTool extends Tool
{
    public var borderOn :Boolean;
    public var fillColor :uint;
    public var fillOn :Boolean;

    public function ShapeTool (thickness :int, alpha :Number, borderColor :uint, 
        borderOn :Boolean, fillColor :uint, fillOn :Boolean)
    {
        super(thickness, alpha, borderColor);
        this.borderOn = borderOn;
        this.fillColor = fillColor;
        this.fillOn = fillOn;
    }

    override public function serialize (bytes :ByteArray, colorLUT :HashMap) :void
    {
        super.serialize(bytes, colorLUT);
        bytes.writeBoolean(borderOn);
        writeColor(fillColor, bytes, colorLUT);
        bytes.writeBoolean(fillOn);
    }

    override protected function deserialize (bytes :ByteArray, colorLUT :Array) :void
    {
        super.deserialize(bytes, colorLUT);
        borderOn = bytes.readBoolean();
        fillColor = readColor(bytes, colorLUT);
        fillOn = bytes.readBoolean();
    }
}
}
