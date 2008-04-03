package spades.card {


/** Sorts cards so that it is easy for a player to assess his hand. */
public class Sorter
{
    public function Sorter (rankOrder :int, suitOrder :Array)
    {
        _rankOrder = rankOrder;
        _suitOrder = suitOrder;
    }

    public function sort (cards :CardArray) :void
    {
        cards.standardSort(_suitOrder, _rankOrder);
    }

    protected var _rankOrder :int;
    protected var _suitOrder :Array;
}

}
