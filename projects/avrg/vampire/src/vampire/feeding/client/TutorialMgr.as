package vampire.feeding.client {

import com.threerings.flash.Vector2;
import com.threerings.util.HashSet;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.objects.SimpleSceneObject;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.MovieClip;

import vampire.feeding.*;

public class TutorialMgr extends SimObject
{
    public function TutorialMgr ()
    {
        var delay :Number = 0;
        var sequenceTutorial :Function = function (type :int, after :Number) :void {
            if (timesShown(type) <= 2) {
                delay += after;
                addTask(After(delay, new FunctionTask(function () :void {
                    queueTutorial(type);
                })));
            }
        }

        // There are two tutorial to play when white cells explode. Play them in order.
        if (timesShown(Constants.TUT_DRAG_WHITE) <= 2) {
            _whiteCellTutorials.push(Constants.TUT_DRAG_WHITE);
        }
        if (timesShown(Constants.TUT_EXPLODE_WHITE) <= 2) {
            _whiteCellTutorials.push(Constants.TUT_EXPLODE_WHITE);
        }
        if (_whiteCellTutorials.length > 0) {
            registerListener(GameCtx.gameMode, GameEvent.WHITE_CELL_BURST, onWhiteCellBurst);
        }

        sequenceTutorial(Constants.TUT_RED_CELLS, 3);
        sequenceTutorial(Constants.TUT_CASCADE, 0.5);
        sequenceTutorial(Constants.TUT_CREATE_MULTIPLIER, 20);
        sequenceTutorial(Constants.TUT_GET_MULTIPLIER, 20);

        registerListener(GameCtx.specialCellSpawner, GameEvent.SPECIAL_CELL_SPAWNED,
            function (e :GameEvent) :void {
                if (timesShown(Constants.TUT_GET_SPECIAL) <= 2) {
                    queueTutorial(Constants.TUT_GET_SPECIAL);
                }
            });
    }

    protected function onWhiteCellBurst (...ignored) :void
    {
        if (++_whiteCellBursts >= 2 && !_playingTutorial && _whiteCellTutorials.length > 0) {
            queueTutorial(_whiteCellTutorials.shift() as int);
        }
    }

    override protected function update (dt :Number) :void
    {
        if (!_playingTutorial && _tutorialQueue.length > 0) {
            playNextTutorial();
        }
    }

    protected function queueTutorial (type :int) :void
    {
        // Don't show a given tutorial more than once per round
        if (_tutorialsThisRound.contains(type)) {
            return;
        }

        _tutorialQueue.push(type);
        if (!_playingTutorial) {
            playNextTutorial();
        }
    }

    protected function playNextTutorial () :void
    {
        var type :int = _tutorialQueue.shift();
        var movie :MovieClip = ClientCtx.instantiateMovieClip("blood", MOVIE_NAMES[type]);
        var obj :SimpleSceneObject = new SimpleSceneObject(movie);
        obj.x = START.x;
        obj.y = START.y;
        obj.addTask(new SerialTask(
            LocationTask.CreateSmooth(END.x, END.y, 1),
            new TimedTask(4),
            LocationTask.CreateSmooth(START.x, START.y, 1),
            new FunctionTask(function () :void {
                _playingTutorial = false;
            }),
            new SelfDestructTask()));
        GameCtx.gameMode.addSceneObject(obj, GameCtx.uiLayer);

        ClientCtx.playerData.incrementNumTimesPlayedTutorial(type);
        _tutorialsThisRound.add(type);
        _playingTutorial = true;
    }

    protected static function timesShown (tutorialType :int) :int
    {
        return ClientCtx.playerData.getNumTimesPlayedTutorial(tutorialType);
    }

    protected var _tutorialQueue :Array = [];
    protected var _playingTutorial :Boolean;
    protected var _whiteCellBursts :int;
    protected var _tutorialsThisRound :HashSet = new HashSet();

    protected var _whiteCellTutorials :Array = [];

    protected static const START :Vector2 = new Vector2(210, -23);
    protected static const END :Vector2 = new Vector2(210, 23);

    protected static const MOVIE_NAMES :Array = [
        "tip_red",
        "tip_cascade",
        "tip_send",
        "tip_multiplier",
        "tip_white",
        "tip_corrupt",
        "tip_type",
    ];
}

}
