package bingo {
    import com.threerings.util.ArrayUtil;
    import com.threerings.util.HashSet;


public class Trophies
{
    public static const ROUNDS_WON_VALUES :Array = [ 5, 10, 15, 20 ];
    public static const ROUNDS_WON_PREFIX :String = "rounds_won_";

    public static const ROUNDS_PLAYED_VALUES :Array = [ 5, 10, 25, 50, 100 ];
    public static const ROUNDS_PLAYED_PREFIX :String = "rounds_played_";

    public static const ROUNDS_WON_CONSEC_VALUES :Array = [ 3, 5, 10 ];
    public static const ROUNDS_WON_CONSEC_PREFIX :String = "rounds_won_consec_";

    public static function getAccumulationTrophies (values :Array, trophyPrefix :String,
        accumulatedValue :int, trophies :HashSet) :void
    {
        for each (var val :int in values) {
            if (accumulatedValue >= val) {
                trophies.add(trophyPrefix + val);
            }
        }
    }

    // win a round with all bag items, etc
    public static const WON_WITH_ITEMS_VALUES :Array = [
        "bag", "hat", "hair", "jewelry", "shoes", "pattern"
    ];
    public static const WON_WITH_ITEMS_PREFIX :String = "won_with_";

    // win a round with an item from each of the listed categories
    public static const FASHIONISTA :String = "fashionista";
    public static const FASHIONISTA_TAGS :Array = [ "bag", "hat", "hair", "jewelry", "shoes" ];

    // win a round without using the Free space
    public static const OVERACHIEVER :String = "overachiever";

    public static function getBoardTrophies (winningItems :Array, trophies :HashSet) :void
    {
        if (winningItems.length == 5) {
            trophies.add(OVERACHIEVER);
        }

        for each (var tag :String in WON_WITH_ITEMS_VALUES) {
            var allItemsHaveTag :Boolean = true;
            for each (var item :BingoItem in winningItems) {
                if (!item.containsTag(tag)) {
                    allItemsHaveTag = false;
                    break;
                }
            }

            if (allItemsHaveTag) {
                trophies.add(WON_WITH_ITEMS_PREFIX + tag);
            }
        }

        var hasAllFashionistaTags :Boolean = true;
        for each (tag in FASHIONISTA_TAGS) {
            var index :int = ArrayUtil.indexIf(
                winningItems,
                function (item :BingoItem) :Boolean {
                    return item.containsTag(tag);
                }
            );

            if (index < 0) {
                hasAllFashionistaTags = false;
                break;
            }
        }

        if (hasAllFashionistaTags) {
            trophies.add(FASHIONISTA);
        }
    }
}

}
