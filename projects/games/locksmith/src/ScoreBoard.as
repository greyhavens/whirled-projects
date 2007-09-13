// $Id$

package {

import flash.display.Sprite;

import flash.filters.DropShadowFilter;

import flash.text.TextField;
import flash.text.TextFieldAutoSize;

public class ScoreBoard extends Sprite 
{
    public static const RED_PLAYER :int = 1;
    public static const BLUE_PLAYER :int = 2;

    public function ScoreBoard (redPlayer :String, bluePlayer :String, gameEndedCallback :Function) 
    {
        _red = new Sprite();
        var redName :TextField = createTextField(redPlayer + ": ", Marble.RED, 
            TextFieldAutoSize.LEFT);
        _red.addChild(redName);
        _red.addChild(_redScoreField = createTextField(" 0", Marble.RED));
        _redScoreField.x = redName.width;
        addChild(_red);
        _redScore = 0;

        _blue = new Sprite();
        var blueName :TextField = createTextField(bluePlayer + ": ", Marble.BLUE,
            TextFieldAutoSize.LEFT);
        _blue.addChild(blueName);
        _blue.addChild(_blueScoreField = createTextField(" 0", Marble.BLUE));
        _blueScoreField.x = blueName.width;
        _blue.x = Locksmith.DISPLAY_WIDTH - _blue.width;
        _blue.y = Locksmith.DISPLAY_HEIGHT - _blue.height;
        addChild(_blue);
        _blueScore = 0;

        _gameEndedCallback = gameEndedCallback;
    }

    public function get redScore () :int
    {
        return _redScore;
    }

    public function set redScore (score :int) :void
    {
        updateScore(_redScore = score, _redScoreField);
        if (_redScore == Locksmith.WIN_SCORE) {
            _gameEndedCallback();
        }
    }
    
    public function get blueScore () :int
    {
        return _blueScore;
    }

    public function set blueScore (score :int) :void
    {
        updateScore(_blueScore = score, _blueScoreField);
        if (_blueScore == Locksmith.WIN_SCORE) {
            _gameEndedCallback();
        }
    }

    public function newTurn (currentPlayer :int) :void
    {
        setShadow(currentPlayer == RED_PLAYER, _red);
        setShadow(currentPlayer == BLUE_PLAYER, _blue);
    }

    protected function updateScore (score :int, field :TextField) :void
    {
        if (score < 10) {
            field.text = " " + score;
        } else {
            field.text = "" + score;
        }
    }

    protected function createTextField (text :String, color :int, autoSize :String = 
        TextFieldAutoSize.CENTER) :TextField
    {
        var field :TextField = new TextField();
        field.text = text;
        field.selectable = false;
        field.autoSize = autoSize;
        field.scaleX = field.scaleY = 2;
        field.textColor = color;
        return field;
    }

    protected function setShadow (doBlur :Boolean, label :Sprite) :void
    {
        var shadowIndex :int = -1;
        var ourFilters :Array = label.filters;
        if (ourFilters != null) {
            for (var ii :int = 0; ii < ourFilters.length; ii++) {
                if (ourFilters[ii] is DropShadowFilter) {
                    shadowIndex = ii;
                    break;
                }
            }
        }

        if (doBlur == (shadowIndex != -1)) {
            return;
        }

        if (doBlur) {
            if (ourFilters == null) {
                ourFilters = [];
            }
            var glow :DropShadowFilter = new DropShadowFilter();
            ourFilters.push(glow);
            label.filters = ourFilters;
        } else {
            ourFilters.splice(shadowIndex, 1);
            label.filters = ourFilters;
        }
    }

    protected var _red :Sprite;
    protected var _redScore :int;
    protected var _redScoreField :TextField;
    protected var _blue :Sprite;
    protected var _blueScore :int;
    protected var _blueScoreField :TextField;
    protected var _gameEndedCallback :Function;
}
}
