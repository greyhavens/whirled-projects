//
// $Id$

package dictattack {

import flash.events.Event;
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

        _ship = content.createShip();
        _ship.y = -Content.SHOOTER_SIZE/2;
        addChild(_ship);

        addEventListener(Event.ENTER_FRAME, onEnterFrame);
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
        _board = board;
        _targets.push([xx, yy]);
        if (_tgtx == -1) {
            shootNextTarget();
        }
    }

    protected function shootNextTarget () :void
    {
        if (_targets.length == 0) {
            return;
        }

        // obtain the coordinates of our next target
        var data :Array = _targets.shift() as Array;
        _tgtx = int(data[0]);
        _tgty = int(data[1]);

        // position our ship under that letter
        var size :int = _board.getSize(), cx :int = int(size/2);
        switch (_posidx) {
        default:
        case 3:
            _shipx = (_tgtx - cx) * (Content.TILE_SIZE + Board.GAP);
            break;
        case 1:
            _shipx = ((size-1-_tgtx) - cx) * (Content.TILE_SIZE + Board.GAP);
            break;
        case 2:
            _shipx = ((size-1-_tgty) - cx) * (Content.TILE_SIZE + Board.GAP);
            break;
        case 0:
            _shipx = (_tgty - cx) * (Content.TILE_SIZE + Board.GAP);
            break;
        }
    }

    protected function readyToShoot () :void
    {
        Content.getShootSound().play();

        // TODO: fire a missile at the letter, blow it up when the missile hits
        _board.destroyLetter(_tgtx, _tgty);

        if (_targets.length > 0) {
            shootNextTarget();
        } else {
            _shipx = 0;
            _tgtx = _tgty = -1;
            _board = null;
        }
    }

    protected function onEnterFrame (event :Event) :void
    {
        if (_ship.x != _shipx) {
            var dx :int = (_shipx - _ship.x);
            if (Math.abs(dx) < 3) {
                _ship.x = _shipx;
                if (_tgtx != -1) {
                    readyToShoot();
                }
            } else {
                _ship.x += dx/2;
            }

        } else if (_tgtx != -1) {
            readyToShoot();
        }
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

    protected var _board :Board;
    protected var _targets :Array = new Array();
    protected var _tgtx :int = -1;
    protected var _tgty :int = -1;
    protected var _shipx :int = 0;

    protected static const SCORE_X :Array = [ 0, -0.5, -1, -0.5 ];
    protected static const SCORE_Y :Array = [ -0.5, 0, -0.5, -1 ];

    protected static const POINTS_WIDTH :int = 50;
    protected static const POINTS_HEIGHT :int = 15;

    protected static const FONT_Y_HACK :int = -3;
}

}
