package spades.card {

/** Sorts cards so that it is easy for a player to assess his hand. */
public class Sorter
{
    public function Sorter (rankOrder :int, suitOrder :Array)
    {
        _rankOrder = rankOrder;
        _suitOrder = suitOrder;
    }

    /** Sort an array of cards. */
    public function sort (cards :CardArray) :void
    {
        cards.standardSort(_suitOrder, _rankOrder);
    }

    /** Insert some new cards into a previously sorted array.
     *  @param newCards the incoming cards
     *  @param cards the previously sorted array
     */
    public function insert(newCards :CardArray, cards :CardArray) :void
    {
        if (cards.length == 0) {
            var sortedNewCards :CardArray = new CardArray(newCards.ordinals);
            sort(sortedNewCards);
            cards.reset(sortedNewCards.ordinals);
        }
        else {
            for (var i :int = 0; i < newCards.length; ++i) {
                cards.sortedInsert(newCards.cards[i], _suitOrder, _rankOrder);
            }
        }
    }

    protected var _rankOrder :int;
    protected var _suitOrder :Array;
}

}
