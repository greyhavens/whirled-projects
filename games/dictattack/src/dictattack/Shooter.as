//
// $Id$

package dictattack {

import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.SimpleButton;
import flash.display.Sprite

public class Shooter extends Sprite
{
    public function Shooter (ctx :Context, posidx :int, pidx :int, mp :Boolean)
    {
        _ctx = ctx;
        _pidx = pidx;
        _posidx = posidx;
        rotation = (posidx+1)%4 * 90;

        addChild(_name = new TextField());
        _name.text = "";
        _name.selectable = false;
        _name.defaultTextFormat = _ctx.content.makeNameFormat();
        _name.embedFonts = true;
        _name.autoSize = TextFieldAutoSize.RIGHT;

        _ship = _ctx.content.createShip();
        _ship.y = -3*Content.SHOOTER_SIZE/2;
        addChild(_ship);

        if (mp) {
            addChild(_points = _ctx.content.createWordScoreDisplay());
            _points.gotoAndStop(0);
            _points.y = -Content.SHOOTER_SIZE/2;

            addChild(_score = new Sprite());
            _score.x = _points.width/2 + 5;
            _score.y = -Content.SHOOTER_SIZE/2;

        } else {
            // we may add this later
            _endGame = _ctx.content.makeButton("End Game");
        }

        addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    public function setName (name :String) :void
    {
        _name.text = name;
        if (_points == null) {
            _name.x = -_ctx.view.getBoard().getPixelSize()/2;
        } else {
            _name.x = -_points.width/2 - _name.width - 2;
        }
        _name.y = -Content.SHOOTER_SIZE/2 - _name.getLineMetrics(0).ascent/2 + FONT_Y_HACK;
    }

    public function setPoints (points :int, maxPoints :int) :void
    {
        if (_points == null) { // single player mode
            _name.text = "Points: " + points;
            _name.x = -_ctx.view.getBoard().getPixelSize()/2;
        } else {
            var frame :int = int(_points.totalFrames * points / maxPoints);
            _points.gotoAndStop(frame);
        }
    }

    public function setScore (score :int) :void
    {
        if (_score == null) {
            return; // single player mode
        }
        while (_score.numChildren > 0) { // no removeAllChildren()? WTF?
            _score.removeChildAt(0);
        }
        for (var ii :int = 0; ii < score; ii++) {
            var icon :MovieClip = _ctx.content.createRoundScoreIcon();
            icon.x = ii * (icon.width + 2) + icon.width/2;
            _score.addChild(icon);
        }
    }

    public function setSaucers (count :int) :void
    {
        // out with the old
        for each (var child :MovieClip in _saucers) {
            removeChild(child);
        }
        _saucers.length = 0;

        // in with the new
        for (var ii :int = 0; ii < count; ii++) {
            var saucer :MovieClip = _ctx.content.createSaucer();
            saucer.x = _ctx.view.getBoard().getPixelSize()/2 - (saucer.width + 5) * ii;
            saucer.y = -Content.SHOOTER_SIZE/2;
            saucer.addEventListener(MouseEvent.CLICK, _ctx.view.saucerClicked);
            _saucers.push(saucer);
            addChild(saucer);
        }
    }

    public function flySaucer (board :Board, xx :int, yy :int) :void
    {
        // TODO: animate
        removeChild(_saucers.pop() as MovieClip);

        // if we have no saucers left, and we're a single player game, add the "end game" button
        if (_saucers.length == 0 && _points == null) { // single player mode
            _endGame.x = _ctx.view.getBoard().getPixelSize()/2;
            _endGame.y = -Content.SHOOTER_SIZE/2;
            _endGame.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
                _ctx.model.endGameEarly();
            });
            addChild(_endGame);
        }
    }

    public function shootLetter (board :Board, xx :int, yy :int) :void
    {
        _board = board;
        _targets.push([xx, yy]);
        if (_tgtx == -1) {
            shootNextTarget();
        }
    }

    public function roundDidEnd () :void
    {
        if (_endGame != null && _endGame.parent != null) {
            removeChild(_endGame);
        }
        for each (var child :MovieClip in _saucers) {
            removeChild(child);
        }
        _saucers.length = 0;
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
        _ctx.content.getShootSound().play();

        // TODO: fire a missile at the letter, blow it up when the missile hits
        _board.destroyLetter(_tgtx, _tgty);
        _ctx.view.shotTaken(this);

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

    protected var _ctx :Context;
    protected var _pidx :int;
    protected var _posidx :int;

    protected var _ship :Sprite;
    protected var _points :MovieClip;
    protected var _name :TextField;
    protected var _score :Sprite;
    protected var _saucers :Array = new Array();
    protected var _endGame :SimpleButton;

    protected var _board :Board;
    protected var _targets :Array = new Array();
    protected var _tgtx :int = -1;
    protected var _tgty :int = -1;
    protected var _shipx :int = 0;

    protected static const FONT_Y_HACK :int = -3;
}

}
