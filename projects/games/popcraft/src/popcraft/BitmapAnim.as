package popcraft {

import flash.display.BitmapData;
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
        if (totalTime <= 0) {
            throw new ArgumentError("totalTime must be > 0");
        }

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
            } else if (frameIndex >= 0) {
                movie.gotoAndPlay(frameIndex);
                frame = BitmapAnimFrame.fromDisplayObject(movie);
            } else {
                // if frameIndex < 0, use an empty BitmapAnimFrame for the frame
                frame = BitmapAnimFrame.EMPTY;
            }

            frames.push(frame);
            if (frameIndex > 0) {
                instantiatedFrameIndexes.push(frameIndex);
            }
        }

        var frameRate :Number = frameIndexes.length / totalTime;
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
