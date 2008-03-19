package bingo {

import com.threerings.util.ArrayUtil;

public class BingoItem
{
    public var name :String;
    public var tags :Array;
    public var itemClass :Class;

    public var requiresTint :Boolean;
    public var tintColor :uint;
    public var tintAmount :Number;

    public function BingoItem (name :String, tags :Array, itemClass :Class, requiresTint :Boolean = false, tintColor :uint = 0, tintAmount :Number = 0)
    {
        this.name = name;
        this.tags = tags;
        this.itemClass = itemClass;

        this.requiresTint = requiresTint;
        this.tintColor = tintColor;
        this.tintAmount = tintAmount;
    }

    public function containsTag (tag :String) :Boolean
    {
        return ArrayUtil.contains(tags, tag);
    }
}

}
