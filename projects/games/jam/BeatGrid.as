package {

import flash.display.Sprite;
import flash.display.Shape;

public class BeatGrid extends Sprite
{
    public var score :Score;
    public var player :int;
    
    public var beats :Array; // array of arrays of shapes
    
    public function BeatGrid (score :Score, playerIndex :int)
    {
        this.score = score;
        this.player = playerIndex;

        this.beats = new Array(Score.BEATS);
        for (var col :int = 0; col < Score.BEATS; col++)
        {
            beats[col] = new Array(12);

            for (var row :int = 0; row < 12; row++)
            {
                var s :Shape = new Shape();
                s.x = col * 12;
                s.y = row * 12;
                addChild(s);
                beats[col][row] = s;
            }
        }

        update();
    }

    public function update () :void
    {
        for (var col :int = 0; col < Score.BEATS; col++)
        {
            var note :Number = score.getBeat(player, col);
            var noterow :Number = note % 12;

            for (var row :int = 0; row < 12; row++)
            {
                var s :Shape = beats[col][row];
                s.graphics.beginFill(0xffffff,
                                     note != Score.BEAT_NONE && noterow == row ? 1.0 : 0.5);
                s.graphics.drawRect(0, 0, 10, 10);
                s.graphics.endFill();
            }
        }
    }



}

}
