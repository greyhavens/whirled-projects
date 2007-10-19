//
// $Id$

package dictattack {

/**
 * Tracks a word played by a player.
 */
public class WordPlay
{
    public var pidx :int;

    public var word :String;

    public var positions :Array = [];

    public var mults :Array = [];

    public var wilds :Array = [];

    public var when :int;

    public static function unflatten (values :Array) :WordPlay
    {
        var unflat :WordPlay = new WordPlay();
        unflat.pidx = int(values[0]);
        unflat.word = (values[1] as String);
        unflat.positions = (values[2] as Array);
        unflat.mults = (values[3] as Array);
        unflat.wilds = (values[4] as Array);
        return unflat;
    }

    public function flatten () :Array
    {
        var flat :Array = [];
        flat.push(pidx);
        flat.push(word);
        flat.push(positions);
        flat.push(mults);
        flat.push(wilds);
        return flat;
    }

    public function getPoints (model :Model) :int
    {
        var points :int = word.length - model.getMinWordLength() + 1;
        // account for multipliers and wildcards
        var mult :int = 1;
        for (var ii :int = 0; ii < word.length; ii++) {
            mult = Math.max(mult, int(mults[ii]));
            if (wilds[ii]) {
                points = Math.max(0, points-1);
            }
        }
        return points * mult;
    }

    public function getMultiplier () :int
    {
        var mult :int = 1;
        for (var ii :int = 0; ii < word.length; ii++) {
            mult = Math.max(mult, int(mults[ii]));
        }
        return mult;
    }

    public function usedWild () :Boolean
    {
        for (var ii :int = 0; ii < wilds.length; ii++) {
            if (wilds[ii]) {
                return true;
            }
        }
        return false;
    }
}
}
