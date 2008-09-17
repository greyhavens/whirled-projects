package bingo {

import com.threerings.util.HashSet;
import com.threerings.util.Log;
import com.threerings.util.Random;
import com.threerings.util.ArrayUtil;

public class BingoItemManager
{
    public function BingoItemManager ()
    {
        // discover all the item tags

        // @TODO - should these be stored in a
        // structure that's weighted in some way, so
        // that less common tags are drawn more frequently, or vice-versa?

        var tagSet :HashSet = new HashSet();

        for each (var item :BingoItem in Constants.ITEMS) {

            if (Constants.USE_ITEM_NAMES_AS_TAGS) {
                tagSet.add(item.name);
            }

            for each (var tag :String in item.tags) {
                tagSet.add(tag);
            }
        }

        _tags = tagSet.toArray().sort();
        this.resetRemainingTags();

        /*log.info(Constants.ITEMS.length.toString() + " items, " + _tags.length + " tags");
        for each (tag in _tags) {
            log.info(tag);
        }*/
    }

    public function get tags () :Array
    {
        return _tags;
    }

    public function getRandomTag () :String
    {
        if (_remainingTags.length == 0) {
            this.resetRemainingTags();
        }

        return _remainingTags[_rand.nextInt(_remainingTags.length)];
    }

    public function removeFromRemainingTags (tag :String) :void
    {
        ArrayUtil.removeFirst(_remainingTags, tag);
    }

    public function resetRemainingTags () :void
    {
        _remainingTags = _tags.slice();
    }

    public function getRandomItem () :BingoItem
    {
        return Constants.ITEMS[_rand.nextInt(Constants.ITEMS.length)];
    }

    protected var _tags :Array;
    protected var _rand :Random = new Random();

    protected var _remainingTags :Array;

    protected static var log :Log = Log.getLog(BingoItemManager);

}

}
