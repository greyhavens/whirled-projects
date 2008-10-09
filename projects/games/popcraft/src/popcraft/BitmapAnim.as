package popcraft {

public class BitmapAnim
{
    public static const STOP :int = 0;
    public static const LOOP :int = 1;

    public var frames :Array;
    public var frameRate :Number;
    public var endBehavior :int;

    public function BitmapAnim (frames :Array, frameRate :Number, endBehavior :int = LOOP)
    {
        this.frames = frames;
        this.frameRate = frameRate;
        this.endBehavior = endBehavior;
    }
}

}
