package ghostbusters.fight.ouija {

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.tasks.*;
import com.whirled.contrib.core.util.*;

import flash.geom.Matrix;

import ghostbusters.fight.*;
import ghostbusters.fight.common.*;

public class SpiritGuideGame extends MicrogameMode
{
    public static const GAME_NAME :String = "Spirit Guide";
    
    public function SpiritGuideGame (difficulty :int, playerData :Object)
    {
        super(difficulty, playerData);
        
        _settings = DIFFICULTY_SETTINGS[Math.min(difficulty, DIFFICULTY_SETTINGS.length - 1)];
        
        // randomly generate a selection to move to
        _selection = Board.getRandomSelectionString();
    }
    
    override public function begin () :void
    {
        MainLoop.instance.pushMode(this);
        MainLoop.instance.pushMode(new IntroMode(GAME_NAME, "Move to '" + _selection.toLocaleUpperCase() + "'!"));
    }
    
    override protected function get duration () :Number
    {
        return _settings.gameTime;
    }
    
    override protected function get timeRemaining () :Number
    {
        return (_done ? 0 : GameTimer.timeRemaining);
    }
    
    override public function get isDone () :Boolean
    {
        return (_done && !WinLoseNotification.isPlaying);
    }
    
    override public function get gameResult () :MicrogameResult
    {
        return _gameResult;
    }
    
    protected function gameOver (success :Boolean) :void
    {
        if (!_done) {
            GameTimer.uninstall();
            WinLoseNotification.create(success, this.modeSprite);
            
            _gameResult = new MicrogameResult();
            _gameResult.success = (success ? MicrogameResult.SUCCESS : MicrogameResult.FAILURE);
            _gameResult.damageOutput = (success ? _settings.damageOutput : 0);
            
            _done = true;
        }
    }

    override protected function setup () :void
    {
        var board :Board = new Board();
        this.addObject(board, this.modeSprite);

        // create the visual timer
        var boardTimer :BoardTimer = new BoardTimer(this.duration);
        this.addObject(boardTimer, board.displayObjectContainer);

        // status text
        var statusText :StatusText = new StatusText();
        statusText.text = "Move to '" + _selection.toLocaleUpperCase() + "'";
        board.displayObjectContainer.addChild(statusText);

        // install a failure timer
        GameTimer.install(this.duration, function () :void { gameOver(false) });
        
        // create the cursor
        var validTransforms :Array = MOUSE_TRANSFORMS[_settings.transformDifficulty];
        var mouseTransform :Matrix = validTransforms[Rand.nextIntRange(0, validTransforms.length, Rand.STREAM_COSMETIC)];
        var cursor :SpiritCursor = new SpiritCursor(board.interactiveObject, mouseTransform);

        cursor.selectionTargetIndex = Board.stringToSelectionIndex(_selection);
        cursor.addEventListener(BoardSelectionEvent.NAME, boardSelectionChanged, false, 0, true);

        this.addObject(cursor, board.displayObjectContainer);
    }

    protected function boardSelectionChanged (e :BoardSelectionEvent) :void
    {
        if (e.selectionString == _selection) {
            this.gameOver(true);
        }
    }

    protected var _done :Boolean;
    protected var _gameResult :MicrogameResult;
    protected var _selection :String;
    protected var _settings :SpiritGuideSettings;
    
    protected static const MOUSE_TRANSFORMS :Array = [
    
        // easy (inverted x/y/both)
        [
            new Matrix(-1, 0, 0, 1),
            new Matrix(1, 0, 0, -1),
            new Matrix(-1, 0, 0, -1),
        ],
        
        // hard (inverted and/or swapped x/y)
        [
            new Matrix(0, 1, 1, 0),
            new Matrix(0, -1, 1, 0),
            new Matrix(0, 1, -1, 0),
            new Matrix(0, -1, -1, 0),
        ],
        
        // expert (rotated)
        [
            new Matrix(0.5253219888177297, 0.8509035245341184, -0.8509035245341184, 0.5253219888177297),
            new Matrix(-0.9960878351411849, 0.08836868610400143, -0.08836868610400143, -0.9960878351411849),
            new Matrix(0.36731936773024515, -0.9300948780045254, 0.9300948780045254, 0.36731936773024515),
            new Matrix(0.6669156003948422, 0.7451332645574127, -0.7451332645574127, 0.6669156003948422),
        ],
    ];
    
    protected static const DIFFICULTY_SETTINGS :Array = [
        new SpiritGuideSettings(8, 0, 10),
        new SpiritGuideSettings(6, 1, 15),
        new SpiritGuideSettings(6, 2, 20),
        new SpiritGuideSettings(4, 2, 25),
    ];
}

}
