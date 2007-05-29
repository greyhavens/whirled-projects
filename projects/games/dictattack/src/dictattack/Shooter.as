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
        rotation = (posidx+1)%4 * 90;

        _ship = content.createShip();
        _ship.y = -Content.SHOOTER_SIZE/2;
        addChild(_ship);

        _name = new TextField();
        _name.text = "";
        _name.selectable = false;
        _name.defaultTextFormat = makeTextFormat(Content.FONT_COLOR);
        _name.embedFonts = true;
        _name.autoSize = TextFieldAutoSize.LEFT;
        addChild(_name);

        _score = new TextField();
        _score.autoSize = TextFieldAutoSize.CENTER;
        _score.selectable = false;
        _score.defaultTextFormat = makeTextFormat(Content.FONT_COLOR);
        _score.embedFonts = true;
        _score.autoSize = TextFieldAutoSize.RIGHT;
        addChild(_score);
        setScore(0);
    }

    public function setName (name :String) :void
    {
        _name.text = name;
        _name.x = Content.SHOOTER_SIZE/2 + 2;
        _name.y = -Content.SHOOTER_SIZE/2 - _name.getLineMetrics(0).ascent/2 + FONT_Y_HACK;
    }

    public function setPoints (points :int, maxPoints :int) :void
    {
        if (_points != null) {
            removeChild(_points);
        }

        _points = new Shape();
        _points.x = -Content.SHOOTER_SIZE/2 - POINTS_WIDTH - 5;
        _points.y = -Content.SHOOTER_SIZE/2 - POINTS_HEIGHT/2;
        _points.graphics.beginFill(Content.SHOOTER_COLOR[_pidx]);
        var filled :int = Math.min(POINTS_WIDTH, points * POINTS_WIDTH / maxPoints);
        _points.graphics.drawRect(POINTS_WIDTH-filled, 0, filled, POINTS_HEIGHT);
        _points.graphics.endFill();
        _points.graphics.lineStyle(1, uint(0xFFFFFF));
        _points.graphics.drawRect(0, 0, POINTS_WIDTH, POINTS_HEIGHT);
        addChild(_points);
    }

    public function setScore (score :int) :void
    {
        _score.text = ("" + score);
        _score.x = -Content.SHOOTER_SIZE/2 - 5 - POINTS_WIDTH - _score.width - 2;
        _score.y = -Content.SHOOTER_SIZE/2 - _score.getLineMetrics(0).ascent/2 + FONT_Y_HACK;
    }

    public function shootLetter (board :Board, xx :int, yy :int) :void
    {
        _targets.push([xx, yy]);
        if (_current == null) {
            shootNextTarget(board);
        }
    }

    protected function shootNextTarget (board :Board) :void
    {
        if (_targets.length == 0) {
            return;
        }

        _current = _targets.shift() as Array;
        var xx :int = int(_current[0]);
        var yy :int = int(_current[1]);

        // TEMP: position our ship under that letter
        var size :int = board.getSize(), cx :int = int(size/2);
        switch (_posidx) {
        default:
        case 3:
            _ship.x = (xx - cx) * (Content.TILE_SIZE + Board.GAP);
            break;
        case 1:
            _ship.x = ((size-1-xx) - cx) * (Content.TILE_SIZE + Board.GAP);
            break;
        case 2:
            _ship.x = ((size-1-yy) - cx) * (Content.TILE_SIZE + Board.GAP);
            break;
        case 0:
            _ship.x = (yy - cx) * (Content.TILE_SIZE + Board.GAP);
            break;
        }

        // TODO: move the ship into position, shoot the letter, then destroy it
        board.destroyLetter(xx, yy);

        Util.invokeLater(500, function () :void {
            if (_targets.length > 0) {
                shootNextTarget(board);
            } else {
                _current = null;
                _ship.x = 0;
            }
        });
    }

    protected static function makeTextFormat (color :uint) : TextFormat
    {
        var format : TextFormat = new TextFormat();
        format.font = "Name";
        format.color = color;
        format.size = 16;
        return format;
    }

    protected var _pidx :int;
    protected var _posidx :int;
    protected var _ship :Sprite;
    protected var _points :Shape;
    protected var _name :TextField;
    protected var _score :TextField;

    protected var _targets :Array = new Array();
    protected var _current :Array;

    protected static const SCORE_X :Array = [ 0, -0.5, -1, -0.5 ];
    protected static const SCORE_Y :Array = [ -0.5, 0, -0.5, -1 ];

    protected static const POINTS_WIDTH :int = 50;
    protected static const POINTS_HEIGHT :int = 15;

    protected static const FONT_Y_HACK :int = -3;
}

}
