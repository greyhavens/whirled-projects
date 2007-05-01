package {

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Shape;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

public class BeatGrid extends Sprite
{
    public var score :Score;
    public var player :int;
    public var base :int = 60;
    public var beatcontainer :Sprite;
    public var cursor :Shape;

    protected var beats :Array; // array of arrays of shapes

    public function BeatGrid (score :Score, playerIndex :int)
    {
        this.score = score;
        this.player = playerIndex;

        cursor = new Shape();
        cursor.x = 0;
        cursor.y = 0;
        cursor.graphics.beginFill(0xccccff, 0.25);
        cursor.graphics.drawRect(0, 0, 12, 12 * 12);
        cursor.graphics.endFill();
        addChild(cursor);

        // make a nice container
        beatcontainer = new Sprite;
        beatcontainer.x = 0;
        beatcontainer.y = 0;
        addChild(beatcontainer);

        // create each square
        this.beats = new Array(Score.BEATS);
        for (var col :int = 0; col < Score.BEATS; col++)
        {
            beats[col] = new Array(12);

            for (var row :int = 0; row < 12; row++)
            {
                var s :Shape = new Shape();
                s.x = col * 12;
                s.y = (11 - row) * 12;
                beatcontainer.addChild(s);
                beats[col][row] = s;
            }
        }

        beatcontainer.addEventListener(MouseEvent.CLICK, clickHandler);
        this.addEventListener(Event.ENTER_FRAME, frameHandler);

        updateDisplay();
        setCursor(0);
    }

    protected function frameHandler (event :Event) :void
    {

    }

    protected function setCursor (col :int) :void
    {
        cursor.x = col * 12 - 1;
        cursor.y = -1;
    }

    protected function clickHandler (event :MouseEvent) :void
    {
        var p :Point =
            beatcontainer.globalToLocal(new Point(event.stageX, event.stageY));
        var col :int = int(Math.floor(p.x / 12));
        var row :int = 11 - int(Math.floor(p.y / 12));
        var note :Number = score.getBeat(player, col);

        if (note % 12 == row) {
            score.setBeat(player, col, Score.BEAT_NONE);
        } else {
            score.setBeat(player, col, base + row);
        }
        updateDisplay();
    }

    public function updateDisplay () :void
    {
        var isminor :Function = function (n :uint) :Boolean {
            return n == 1 || n == 3 || n == 6 || n == 8 || n == 10;
        }

        for (var col :int = 0; col < Score.BEATS; col++)
        {
            var note :Number = score.getBeat(player, col);
            var modnote :Number = note % 12;

            for (var row :int = 0; row < 12; row++)
            {
                var s :Shape = beats[col][row];
                var color :uint = isminor(row) ? 0xeeeeee : 0xffffff;
                var selected :Boolean =
                    (note != Score.BEAT_NONE && row == modnote);

                s.graphics.clear();
                s.graphics.beginFill(color, selected ? 1.0 : 0.5);
                s.graphics.drawRect(0, 0, 10, 10);
                s.graphics.endFill();
            }
        }
    }



}

}


