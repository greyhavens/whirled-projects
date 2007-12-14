package core.util {

public class NumRange
{
    public var min :Number;
    public var max :Number;

    public function NumRange (min :Number = 0, max :Number = 0)
    {
        this.min = min;
        this.max = max;
    }

    public function next (randStreamId :uint = Rand.STREAM_COSMETIC) :Number
    {
        return Rand.nextNumberRange(this.min, this.max, randStreamId);
    }
}

}
