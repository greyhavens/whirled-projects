package popcraft {

import flash.display.MovieClip;

public class BitmapAnim
{
    public static const STOP :int = 0;
    public static const LOOP :int = 1;

    public var frames :Array;
    public var frameRate :Number;
    public var endBehavior :int;

    /**
     * Creates a BitmapAnim from the given movie and frameIndexes.
     */
    public static function fromMovie (movie :MovieClip, frameIndexes :Array, totalTime :Number,
        endBehavior :int = LOOP) :BitmapAnim
    {
        // create the frame array
        var frames :Array = [];
        var instantiatedFrameIndexes :Array = [];
        for each (var frameIndex :int in frameIndexes) {
            var frame :BitmapAnimFrame;
            // have we already instantiated this frame? if so, just insert the
            // existing bitmap back into the array
            var existingFrameIndex :int = instantiatedFrameIndexes.indexOf(frameIndex);
            if (existingFrameIndex >= 0) {
                frame = frames[existingFrameIndex];
            } else {
                movie.gotoAndPlay(frameIndex);
                frame = BitmapAnimFrame.fromDisplayObject(movie);
            }

            frames.push(frame);
            instantiatedFrameIndexes.push(frameIndex);
        }

        var frameRate :Number = frameIndexes.length / Math.max(totalTime, 1/60);
        return new BitmapAnim(frames, frameRate, endBehavior);
    }

    public function BitmapAnim (frames :Array, frameRate :Number, endBehavior :int = LOOP)
    {
        this.frames = frames;
        this.frameRate = frameRate;
        this.endBehavior = endBehavior;
    }
}

}
