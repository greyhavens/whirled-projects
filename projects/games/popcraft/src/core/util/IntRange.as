package core.util {

public class IntRange
{
    public var min :int;
    public var max :int;

    public function IntRange (min :int = 0, max :int = 0)
    {
        this.min = min;
        this.max = max;
    }

    public function next (randStreamId :uint = Rand.STREAM_COSMETIC) :int
    {
        return Rand.nextIntRange(this.min, this.max, randStreamId);
    }
}

}
