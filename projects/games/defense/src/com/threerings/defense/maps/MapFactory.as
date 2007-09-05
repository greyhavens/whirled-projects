package com.threerings.defense.maps {

import flash.display.BitmapData;

import mx.core.BitmapAsset;
import mx.core.IFlexDisplayObject;

public class MapFactory
{
    public static function makeMapBackground (id :int) :IFlexDisplayObject
    {
        // this will all be fixed by remixing...
    
        switch (id) {
        case 1: return new _m1() as IFlexDisplayObject;
        default: throw new Error("Unknown map id: " + id);
        }
    }

    public static function makeBlankOverlay () :BitmapAsset
    {
        return new _blank() as BitmapAsset;
    }
    
    /** Returns a new bitmap corresponding to the specified map for some number of players. */
    public static function makeGroundMapData (id :int, playerCount :int) :BitmapData
    {
        // my kingdom for some remixing!

        var b :BitmapAsset;
        switch (id) {
        case 1:
            switch (playerCount) {
            case 1: b = new _m1_1() as BitmapAsset;
            case 2: b = new _m1_2() as BitmapAsset;
            }
            break;
        }

        if (b != null) {
            return b.bitmapData;
        } else {
            throw new Error("Unknown map type id: " + id + ", playerCount: " + playerCount);
        }        
    }

    [Embed(source="../../../../../rsrc/maps/blank.png")]
    protected static const _blank :Class;

    [Embed(source="../../../../../TreeHouseD_01_c.swf#FullBG")]
    //    [Embed(source="../../../../../rsrc/maps/1.png")]
    protected static const _m1 :Class;
    [Embed(source="../../../../../rsrc/maps/1-1.png")]
    protected static const _m1_1 :Class;
    [Embed(source="../../../../../rsrc/maps/1-2.png")]
    protected static const _m1_2 :Class;
}
}
