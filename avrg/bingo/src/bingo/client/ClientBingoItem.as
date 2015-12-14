package bingo.client {

import bingo.BingoItem;

public class ClientBingoItem extends BingoItem
{
    public var itemClass :Class;

    public var requiresTint :Boolean;
    public var tintColor :uint;
    public var tintAmount :Number;

    public function ClientBingoItem (name :String, tags :Array, itemClass :Class,
        requiresTint :Boolean = false, tintColor :uint = 0, tintAmount :Number = 0)
    {
        super(name, tags);

        this.itemClass = itemClass;

        this.requiresTint = requiresTint;
        this.tintColor = tintColor;
        this.tintAmount = tintAmount;
    }

}

}
