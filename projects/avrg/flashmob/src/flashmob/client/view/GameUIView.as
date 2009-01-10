package flashmob.client.view {

import com.whirled.contrib.simplegame.resource.SwfResource;

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.geom.Point;
import flash.text.TextField;

public class GameUIView extends Sprite
{
    public function GameUIView ()
    {
        _movie = SwfResource.instantiateMovieClip("Spectacle_UI", "gameUI");
        addChild(_movie);

        _clock = _movie["clock"];
        _clockText = (_clock["clock"])["clock_text"];

        _directionsText = _movie["directions"];
    }

    public function reset () :void
    {
        clearDisplayElements();
        clearButtons();
    }

    public function addDisplayElement (obj :DisplayObject) :void
    {
        addChild(obj);
        _elements.push(obj);
    }

    public function clearDisplayElements () :void
    {
        for each (var obj :DisplayObject in _elements) {
            if (obj.parent != null) {
                obj.parent.removeChild(obj);
            }
        }

        _elements = [];
    }

    public function set rightButton (button :DisplayObject) :void
    {
        setButton(button, RIGHT_BUTTON);
    }

    public function set leftButton (button :DisplayObject) :void
    {
        setButton(button, LEFT_BUTTON);
    }

    public function set centerButton (button :DisplayObject) :void
    {
        setButton(button, CENTER_BUTTON);
    }

    public function clearButtons () :void
    {
        for (var ii :int = 0; ii < _buttons.length; ++ii) {
            setButton(null, ii);
        }
    }

    public function set directionsText (text :String) :void
    {
        _directionsText.text = text;
    }

    public function set clockText (text :String) :void
    {
        _clockText.text = text;
    }

    public function set clockVisible (val :Boolean) :void
    {
        _clock.gotoAndStop(val ? "clockpresent" : "clockgone");
        _clockVisible = val;
    }

    public function animateShowClock (show :Boolean) :void
    {
        if (show != _clockVisible) {
            _clockVisible = show;
            _clock.gotoAndPlay(show ? "clockappear" : "clockdissappear");
        }
    }

    public function get closeButton () :SimpleButton
    {
        return _movie["close"];
    }

    public function get draggableObject () :InteractiveObject
    {
        return _movie["gameUIclick"];
    }

    protected function setButton (button :DisplayObject, index :int) :void
    {
        var oldButton :DisplayObject = _buttons[index];
        if (oldButton != null && oldButton.parent != null) {
            oldButton.parent.removeChild(oldButton);
        }

        if (button != null) {
            var loc :Point = BUTTON_LOCS[index];
            button.x = loc.x;
            button.y = loc.y;
            button.width = BUTTON_SIZE.x;
            button.height = BUTTON_SIZE.y;
            addChild(button);
        }

        _buttons[index] = button;
    }

    protected var _movie :MovieClip;
    protected var _clock :MovieClip;
    protected var _clockText :TextField;
    protected var _directionsText :TextField;
    protected var _clockVisible :Boolean;

    protected var _elements :Array = [];
    protected var _buttons :Array = [ null, null, null ];

    protected static const RIGHT_BUTTON :int = 0;
    protected static const LEFT_BUTTON :int = 1;
    protected static const CENTER_BUTTON :int = 2;

    protected static const BUTTON_LOCS :Array = [
        new Point(99, 26), new Point(-99, 26), new Point(0, 26)
    ];
    protected static const BUTTON_SIZE :Point = new Point(83, 27);
}

}
