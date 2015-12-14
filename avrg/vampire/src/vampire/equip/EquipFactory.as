package equip
{
    import com.threerings.flashbang.resource.ImageResource;
    import com.threerings.flashbang.resource.SwfResource;

    import flash.display.Bitmap;
    import flash.display.Graphics;
    import flash.display.MovieClip;
    import flash.display.Sprite;


//Generates the game assets
public class EquipFactory
{
    public static function createItemObject (itemId :int) :ItemObject
    {
        var item :Item = ItemData.get(itemId);
        trace(item);
        trace(item.rsrc);
        var s :Sprite = new Sprite();
        var b :Bitmap = instantiateBitmap(item.rsrc);
        if (b != null) {
            var size :Number = Math.max(b.width, b.height);
            b.scaleX = b.scaleY = (EquipCtx.BOX_SIZE - 4) / size;
            b.x = -b.width / 2;
            b.y = -b.height / 2;
            s.addChild(b);
            return new ItemObject(itemId, s);
        }
        else {
            var g :Graphics = s.graphics;
            g.beginFill(0xffffff);
            g.drawCircle(0,0,20);
            g.endFill();
            return new ItemObject(itemId, s);
        }
    }

    public static function instantiateBitmap (name :String) :Bitmap
    {
        return ImageResource.instantiateBitmap(EquipCtx.rsrcs, name);
    }

    public static function instantiateMovieClip (rsrcName :String, className :String,
        disableMouseInteraction :Boolean = false, fromCache :Boolean = false) :MovieClip
    {
        return SwfResource.instantiateMovieClip(
            EquipCtx.rsrcs,
            rsrcName,
            className,
            disableMouseInteraction,
            fromCache);
    }
}
}
