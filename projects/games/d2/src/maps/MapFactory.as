package maps {

import flash.display.BitmapData;

import mx.core.BitmapAsset;

import game.Board;

public class MapFactory
{
    public static function makeBlankOverlay () :BitmapAsset
    {
        return new _blank() as BitmapAsset;
    }
    
    /** Returns a new bitmap corresponding to the specified map for some number of players. */
    public static function makeGroundMapData (board :Board, playerCount :int) :BitmapData
    {
        var name :String = "_m1_2";

        var c :Class = MapFactory[name] as Class;
        if (c == null) {
            throw new Error("Unknown map type id: " + board + ", playerCount: " + playerCount);
        } else {
            var b :BitmapAsset = BitmapAsset(new c());
            return b.bitmapData;
        }
    }

    [Embed(source="../../rsrc/maps/blank.png")]
    protected static const _blank :Class;

    [Embed(source="../../rsrc/maps/1-1.png")]
    protected static const _m1_1 :Class;
    [Embed(source="../../rsrc/maps/1-2.png")]
    protected static const _m1_2 :Class;

}
}
