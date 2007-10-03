// $Id$

package {

import flash.display.Sprite;

import flash.filters.DropShadowFilter;

import flash.text.TextField;
import flash.text.TextFieldAutoSize;

public class ScoreBoard extends Sprite 
{
    public static const MOON_PLAYER :int = 1;
    public static const SUN_PLAYER :int = 2;

    public function ScoreBoard (moonPlayer :String, sunPlayer :String, gameEndedCallback :Function) 
    {
        _moon = new Sprite();
        var moonName :TextField = createTextField(moonPlayer + ": ", TextFieldAutoSize.LEFT);
        _moon.addChild(moonName);
        _moon.addChild(_moonScoreField = createTextField(" 0"));
        _moonScoreField.x = moonName.width;
        addChild(_moon);
        _moonScore = 0;

        _sun = new Sprite();
        var sunName :TextField = createTextField(sunPlayer + ": ", TextFieldAutoSize.LEFT);
        _sun.addChild(sunName);
        _sun.addChild(_sunScoreField = createTextField(" 0"));
        _sunScoreField.x = sunName.width;
        _sun.x = Locksmith.DISPLAY_WIDTH - _sun.width;
        _sun.y = Locksmith.DISPLAY_HEIGHT - _sun.height;
        addChild(_sun);
        _sunScore = 0;

        _gameEndedCallback = gameEndedCallback;
    }

    public function get moonScore () :int
    {
        return _moonScore;
    }

    public function set moonScore (score :int) :void
    {
        updateScore(_moonScore = score, _moonScoreField);
        if (_moonScore == Locksmith.WIN_SCORE) {
            _gameEndedCallback();
        }
    }
    
    public function get sunScore () :int
    {
        return _sunScore;
    }

    public function set sunScore (score :int) :void
    {
        updateScore(_sunScore = score, _sunScoreField);
        if (_sunScore == Locksmith.WIN_SCORE) {
            _gameEndedCallback();
        }
    }

    public function newTurn (currentPlayer :int) :void
    {
        setShadow(currentPlayer == MOON_PLAYER, _moon);
        setShadow(currentPlayer == SUN_PLAYER, _sun);
    }

    protected function updateScore (score :int, field :TextField) :void
    {
        if (score < 10) {
            field.text = " " + score;
        } else {
            field.text = "" + score;
        }
    }

    protected function createTextField (text :String, 
        autoSize :String = TextFieldAutoSize.CENTER) :TextField
    {
        var field :TextField = new TextField();
        field.text = text;
        field.selectable = false;
        field.autoSize = autoSize;
        field.scaleX = field.scaleY = 2;
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

    protected var _moon :Sprite;
    protected var _moonScore :int;
    protected var _moonScoreField :TextField;
    protected var _sun :Sprite;
    protected var _sunScore :int;
    protected var _sunScoreField :TextField;
    protected var _gameEndedCallback :Function;
}
}
