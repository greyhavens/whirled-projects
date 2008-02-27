package bingo {
    
import com.threerings.util.HashSet;
import com.threerings.util.Random;
    
public class BingoItemManager
{
    public static function get instance () :BingoItemManager
    {
        return g_instance;
    }
    
    public function BingoItemManager ()
    {
        if (null != g_instance) {
            throw new Error("Can't instantiate multiple instances of BingoItemManager");
        }
        
        g_instance = this;
        
        // discover all the item tags
        
        // @TODO - should these be stored in a
        // structure that's weighted in some way, so
        // that less common tags are drawn more frequently, or vice-versa?
        
        var tagSet :HashSet = new HashSet();
        
        for each (var item :BingoItem in Constants.ITEMS) {
            for each (var tag :String in item.tags) {
                tagSet.add(tag);
            }
        }
        
        _tags = tagSet.toArray();
    }
    
    public function get tags () :Array
    {
        return _tags;
    }
    
    public function getRandomTag () :String
    {
        return _tags[_rand.nextInt(_tags.length)];
    }
    
    public function getRandomItem () :BingoItem
    {
        return Constants.ITEMS[_rand.nextInt(Constants.ITEMS.length)];
    }
    
    protected static var g_instance :BingoItemManager;
    
    protected var _tags :Array;
    protected var _rand :Random = new Random();

}

}