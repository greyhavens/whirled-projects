package maps {

import flash.display.BitmapData;

import mx.core.BitmapAsset;

public class MapFactory
{
    public static function makeMapBackground (id :int) :BitmapAsset
    {
        // this will all be fixed by remixing...
    
        switch (id) {
        case 1: return new _m1() as BitmapAsset;
        default: throw new Error("Unknown map id: " + id);
        }
    }

    public static function makeBlankOverlay () :BitmapAsset
    {
        // todo
        return new _m1_1() as BitmapAsset;
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

    [Embed(source="../rsrc/maps/1.png")]
    protected static const _m1 :Class;
    [Embed(source="../rsrc/maps/1-1.png")]
    protected static const _m1_1 :Class;
    [Embed(source="../rsrc/maps/1-2.png")]
    protected static const _m1_2 :Class;
}
}
