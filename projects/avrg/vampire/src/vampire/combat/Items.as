package vampire.combat
{
import com.threerings.util.ArrayUtil;

import flash.utils.ByteArray;

public class Items
{
    public function fromBytes (bytes :ByteArray) :void
    {
        _items = [];
        var length :int = bytes.readInt();
        for (var ii :int = 0; ii < length; ++ii) {
            _items.push(bytes.readInt());
        }
    }

    public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        if(bytes == null) {
            bytes = new ByteArray();
        }
        bytes.writeInt(_items.length);
        for (var ii :int = 0; ii < _items.length; ++ii) {
            bytes.writeInt(_items[ii]);
        }
        return bytes;
    }

    public function get items () :Array
    {
        return _items.slice();
    }

    public function addItem (itemId :int) :void
    {
        items.push(itemId);
    }

    public function removeItem (itemId :int) :void
    {
        ArrayUtil.removeFirst(items, itemId);
    }

    public function removeItemAt (index :int) :void
    {
        _items.splice(index, 1);
    }

    protected var _items :Array = [];

}
}