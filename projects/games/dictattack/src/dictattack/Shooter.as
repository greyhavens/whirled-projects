//
// $Id$

package dictattack {

import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

import flash.display.Shape;
import flash.display.Sprite

public class Shooter extends Sprite
{
    public function Shooter (content :Content, posidx :int, pidx :int)
    {
        _pidx = pidx;
        _posidx = posidx;

        _rotor = new Sprite();
        _rotor.rotation = posidx * 90;
        addChild(_rotor);

        var ship :Sprite = content.createShip();
        ship.rotation = 90;
        ship.x = ship.width/2;
        _rotor.addChild(ship);

        _name = new TextField();
        _name.text = "";
        _name.selectable = false;
        _name.defaultTextFormat = makeTextFormat(Content.FONT_COLOR, false);
        _name.embedFonts = true;
        _name.autoSize = (posidx == 0) ? TextFieldAutoSize.LEFT : TextFieldAutoSize.RIGHT;
        _name.rotation = 90;
        _rotor.addChild(_name);

        _score = new TextField();
        _score.autoSize = TextFieldAutoSize.CENTER;
        _score.selectable = false;
        _score.defaultTextFormat = makeTextFormat(uint(0xFFFFFF), true);
        _score.embedFonts = true;
        addChild(_score);
        setScore(0);
    }

    public function setName (name :String) :void
    {
        if (_posidx % 2 == 0 && name.length > 10) {
            name = name.substring(0, 10) + "...";
        }
        _name.text = name;
        _name.x = _name.getLineMetrics(0).ascent + 2;
        _name.y = Content.SHOOTER_SIZE/2 + 5;
    }

    public function setPoints (points :int, maxPoints :int) :void
    {
        if (_points != null) {
            _rotor.removeChild(_points);
        }

        _points = new Shape();
        _points.x = 0;
        _points.y = -Content.SHOOTER_SIZE/2 - POINTS_HEIGHT - 5;
        _points.graphics.beginFill(Content.SHOOTER_COLOR[_pidx]);
        var filled :int = Math.min(POINTS_HEIGHT, points * POINTS_HEIGHT / maxPoints);
        _points.graphics.drawRect(0, POINTS_HEIGHT-filled, POINTS_WIDTH, filled);
        _points.graphics.endFill();
        _points.graphics.lineStyle(1, uint(0x000000));
        _points.graphics.drawRect(0, 0, POINTS_WIDTH, POINTS_HEIGHT);
        _rotor.addChild(_points);
    }

    public function setScore (score :int) :void
    {
        _score.text = ("" + score);
        _score.x = SCORE_X[_posidx] * _score.width;
        _score.y = SCORE_Y[_posidx] * _score.height;
    }

    protected static function makeTextFormat (color :uint, bold :Boolean) : TextFormat
    {
        var format : TextFormat = new TextFormat();
        format.font = "Name";
        format.color = color;
        format.size = 16;
        format.bold = bold;
        return format;
    }

    protected var _pidx :int;
    protected var _posidx :int;
    protected var _rotor :Sprite;
    protected var _points :Shape;
    protected var _name :TextField;
    protected var _score :TextField;

    protected static const SCORE_X :Array = [ 0, -0.5, -1, -0.5 ];
    protected static const SCORE_Y :Array = [ -0.5, 0, -0.5, -1 ];

    protected static const POINTS_WIDTH :int = 15;
    protected static const POINTS_HEIGHT :int = 50;
}

}
