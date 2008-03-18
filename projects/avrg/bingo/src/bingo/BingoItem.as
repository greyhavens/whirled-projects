package bingo {

import com.threerings.util.ArrayUtil;

public class BingoItem
{
    public var name :String;
    public var tags :Array;
    public var itemClass :Class;

    public function BingoItem (name :String, tags :Array, itemClass :Class)
    {
        this.name = name;
        this.tags = tags;
        this.itemClass = itemClass;
    }

    public function containsTag (tag :String) :Boolean
    {
        return ArrayUtil.contains(tags, tag);
    }
}

}
