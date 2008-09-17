package bingo {

import com.threerings.util.ArrayUtil;

public class BingoItem
{
    public var name :String;
    public var tags :Array;

    public function BingoItem (name :String, tags :Array)
    {
        this.name = name;
        this.tags = tags;
    }

    public function containsTag (tag :String) :Boolean
    {
        return ArrayUtil.contains(tags, tag);
    }
}

}
