package {

public class Track
{
    public var sequence :Array;
    public var durations :Array;
    public var looping :Boolean;

    public function Track (sequence :Array, durations :Array, looping :Boolean = true)
    {
        this.sequence = sequence;
        this.durations = durations;
        this.looping = looping;
    }

    public function getDuration (frame :int) :Number
    {
        return durations[frame < durations.length ? frame : 0];
    }
}

}
