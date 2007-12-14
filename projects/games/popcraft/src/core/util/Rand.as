package core.util {

import com.threerings.util.Random;
import com.threerings.util.Assert;

public class Rand
{
    public static const STREAM_GAME :int = 0;
    public static const STREAM_COSMETIC :int = 1;

    public static function setup () :void
    {
        if (_hasSetup) {
            return;
        }

        _hasSetup = true;

        _randStreams[STREAM_GAME] = new Random();
        _randStreams[STREAM_COSMETIC] = new Random();
    }

    public static function addStream (streamId :int, seed :uint = 0) :Random
    {
        _randStreams[streamId] = new Random(seed);
        return (_randStreams[streamId] as Random);
    }

    public static function getStream (streamId :int) :Random
    {
        Assert.isTrue(_hasSetup);

        return (_randStreams[streamId] as Random);
    }

    public static function seedStream (streamId :int, seed :uint) :void
    {
        getStream(streamId).setSeed(seed);
    }

    /** Returns an integer in the range [0, MAX) */
    public static function nextInt (streamId :int= STREAM_COSMETIC) :int
    {
        return getStream(streamId).nextInt();
    }

    /** Returns an int in the range [low, high) */
    public static function nextIntRange (low :int, high :int, streamId :int= STREAM_COSMETIC) :int
    {
        return low + getStream(streamId).nextInt(high - low);
    }

    public static function nextBoolean (streamId :int= STREAM_COSMETIC) :Boolean
    {
        return getStream(streamId).nextBoolean();
    }

    public static function nextNumber (streamId :int= STREAM_COSMETIC) :Number
    {
        return getStream(streamId).nextNumber();
    }

    /** Returns a Number in the range [low, high) */
    public static function nextNumberRange (low :Number, high :Number, streamId :int= STREAM_COSMETIC) :Number
    {
        return low + (getStream(streamId).nextNumber() * (high - low));
    }

    protected static var _hasSetup :Boolean = false;
    protected static var _randStreams :Array = new Array();
}

}
