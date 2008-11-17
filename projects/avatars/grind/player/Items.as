package {

import com.threerings.util.RandomUtil;

public class Items
{
    // Item slots, each of which can wear one item
    public static const BACK :int = 0;
    public static const TORSO :int = 1;
    public static const HAND :int = 2;

    // Item categories, for class-based bonuses
    public static const NONE :int = -1;
    public static const ARCANE :int = 0;
    public static const LIGHT :int = 1;
    public static const HEAVY :int = 2;

    public static const BOW :int = 3;
    public static const CLUB :int = 4;
    public static const AXE :int = 5;
    public static const SWORD :int = 6;
    public static const SPEAR :int = 7;
    public static const MAGIC :int = 8;
    public static const DAGGER :int = 9;

    /** The big kahuna. */
    public static const TABLE :Array = [
        // [ sprite, name, slot, category, power, (range) ]
        [ 94, "Loincloth", TORSO, NONE, 0 ],
        [ 95, "Fancy Tunic", TORSO, NONE, 1 ],
        [ 98, "Uber Armor", TORSO, HEAVY, 6 ],
        [ 321, "Crossbow", HAND, BOW, 1, 800 ],
        [ 304, "Sword", HAND, SWORD, 2, 200 ],

        [ 249, "Black cloak", BACK, NONE, 1 ],
        [ 250, "Blue cloak", BACK, NONE, 1 ],
        [ 252, "Cyan cloak", BACK, NONE, 1 ],
        [ 254, "Green cloak", BACK, NONE, 1 ],
        [ 255, "Pink cloak", BACK, NONE, 1 ],
        [ 256, "Red cloak", BACK, NONE, 1 ],
        [ 257, "White cloak", BACK, NONE, 1 ],
        [ 258, "Yellow cloak", BACK, NONE, 1 ],

        [ 208, "Elegant robe", TORSO, ARCANE, 1 ],
        [ 209, "Scale mail", TORSO, LIGHT, 3 ],
        [ 210, "Chain mail", TORSO, LIGHT, 3 ],
        [ 211, "Yet another armor", TORSO, HEAVY, 2 ],

        [ 300, "Test dagger", HAND, DAGGER, 5, 200 ],
        [ 365, "Test axe", HAND, AXE, 5, 200 ],
        [ 290, "Test club", HAND, CLUB, 5, 200 ],
        [ 443, "Test magic", HAND, MAGIC, 5, 800 ],
        [ 421, "Test spear", HAND, SPEAR, 6666, 200 ],
    ];

    /** A list of item IDs sorted ascending by power. */
    public static var SORTED_GOODIES :Array = TABLE.sortOn(
        "4", Array.NUMERIC | Array.RETURNINDEXEDARRAY);

    /** Returns a random item with around this power. */
    protected static function randomItem (power :int) :int
    {
        function search (low :int, high :int) :int {
            var mid :int = (low+high)/2;
            var value :int = TABLE[SORTED_GOODIES[mid]][4];

            if (high == low) {
                if (value > power) {
                    return Math.max(0, high-1);
                } else {
                    return Math.min(high+1, SORTED_GOODIES.length-1);
                }
            }

            if (value > power) {
                return search(low, mid);
            } else if (value < power) {
                return search(mid+1, high);
            } else {
                trace("Found it: " + mid); 
                return mid;
            }
        }

        var found :int = search(0, SORTED_GOODIES.length-1);
        var power :int = TABLE[SORTED_GOODIES[found]][4];

        return RandomUtil.pickRandom(SORTED_GOODIES.filter(function (item :int, ..._) {
            return TABLE[item][4] == power;
        })) as int;
    }

    public static function randomLoot (base :Number, spread :Number) :int
    {
        var r :Number = (2*Math.random()-1);
        var power :Number =  spread*r*r*r + base;

        trace("Random power: " + power + "(r="+r+")");

        return randomItem(Math.round(power));
    }
}

}
