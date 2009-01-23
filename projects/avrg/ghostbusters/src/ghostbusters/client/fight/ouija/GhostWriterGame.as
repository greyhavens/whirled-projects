package ghostbusters.client.fight.ouija {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.objects.SimpleTimer;
import com.whirled.contrib.simplegame.tasks.*;
import com.whirled.contrib.simplegame.util.*;

import ghostbusters.client.fight.*;
import ghostbusters.client.fight.common.*;

public class GhostWriterGame extends MicrogameMode
{
    public static const GAME_NAME :String = "Ghost Writer";

    public function GhostWriterGame (difficulty :int, context :MicrogameContext)
    {
        super(difficulty, context);

        _settings = DIFFICULTY_SETTINGS[Math.min(difficulty, DIFFICULTY_SETTINGS.length - 1)];

        // choose a word
        var validWords :Array = WORDS.filter(
            function (word :String, index :int, array :Array) :Boolean {
                return (word.length >= _settings.minWordLength && word.length <= _settings.maxWordLength);
            });

        _word = validWords[Rand.nextIntRange(0, validWords.length, Rand.STREAM_COSMETIC)] as String;
    }

    override public function begin () :void
    {
        FightCtx.mainLoop.pushMode(this);
        FightCtx.mainLoop.pushMode(new IntroMode(GAME_NAME, "Spell '" + _word.toLocaleUpperCase() + "'!"));
    }

    override protected function get duration () :Number
    {
        return (_settings.timePerLetter * _word.length);
    }

    override protected function get timeRemaining () :Number
    {
        return (_done ? 0 : GameTimer.timeRemaining);
    }

    override public function get isDone () :Boolean
    {
        return _done;
    }

    override public function get isNotifying () :Boolean
    {
        return WinLoseNotification.isPlaying;
    }

    override public function get gameResult () :MicrogameResult
    {
        return _gameResult;
    }

    protected function gameOver (success :Boolean) :void
    {
        if (!_done) {
            GameTimer.uninstall();
            WinLoseNotification.create(success, WIN_STRINGS, LOSE_STRINGS, this.modeSprite);

            _gameResult = new MicrogameResult();
            _gameResult.success = (success ? MicrogameResult.SUCCESS : MicrogameResult.FAILURE);
            _gameResult.damageOutput = (success ? _settings.damageOutput : 0);

            _done = true;
        }
    }

    override protected function setup () :void
    {
        // create the board
        _board = new Board();
        this.addObject(_board, this.modeSprite);

        // progress text
        //_progressText = new ProgressText(_word.toLocaleUpperCase());
        //_board.displayObjectContainer.addChild(_progressText);
        _board.sprite.addChild(_statusText);

        // create the cursor
        _cursor = new Cursor(_board.sprite);
        this.addObject(_cursor, _board.sprite);
        _cursor.addEventListener(BoardSelectionEvent.NAME, boardSelectionChanged, false, 0, true);

        _cursor.selectionTargetIndex = Board.stringToSelectionIndex(_word.charAt(_nextWordIndex));

        // create the visual timer
        var boardTimer :BoardTimer = new BoardTimer(this.duration);
        this.addObject(boardTimer, _board.sprite);

        // install a failure timer
        GameTimer.install(this.duration, function () :void { gameOver(false) });
    }

    override public function update (dt :Number) :void
    {
        super.update(dt);
    }

    protected function boardSelectionChanged (e :BoardSelectionEvent) :void
    {
        if (_nextWordIndex < _word.length && e.selectionString == _word.charAt(_nextWordIndex)) {
            trace("saw " + _word.charAt(_nextWordIndex));

            // update the text
            _statusText.text = _word.substr(0, _nextWordIndex + 1).toLocaleUpperCase();
            //_progressText.advanceProgress();

            if (++_nextWordIndex >= _word.length) {

                GameTimer.uninstall();
                // delay for a moment before showing the game over screen
                this.addObject(new SimpleTimer(0.5, function () :void { gameOver(true) }));

            } else {
                _cursor.selectionTargetIndex = Board.stringToSelectionIndex(_word.charAt(_nextWordIndex));
            }
        }
    }

    public function get word () :String
    {
        return _word;
    }

    protected var _done :Boolean;
    protected var _gameResult :MicrogameResult;
    protected var _word :String;
    protected var _nextWordIndex :int;
    protected var _cursor :Cursor;
    protected var _board :Board;
    protected var _settings :GhostWriterSettings;

    protected var _statusText :StatusText = new StatusText();

    protected static const WORDS :Array = [

        "bogey",
        "abracadabra",
        "antediluvian",
        "astral",
        "beastly",
        "chthonic",
        "eldritch",
        "ethereal",
        "gnosis",
        "macabre",
        "medieval",
        "trance",
        "transcendent",
        "umbra",
        "weird",
        "necronomicon",
        "putrefaction",
        "noxious",
        "ectoplasm",
        "impure",
        "exorcise",
        "nemesis",
        "phantasmagoric",
        "petrify",
        "ghastly"

    ];

    protected static const DIFFICULTY_SETTINGS :Array = [
         new GhostWriterSettings(1, 7, 3, 0.25, 5),
         new GhostWriterSettings(7, 9, 2.2, 0.25, 10),
         new GhostWriterSettings(8, 999, 1.8, 0.15, 15),
         new GhostWriterSettings(8, 999, 1.4, 0.15, 20),
    ];

    protected static const WIN_STRINGS :Array = [
        "POW!",
        "BIFF!",
        "ZAP!",
        "SMACK!",
    ];

    protected static const LOSE_STRINGS :Array = [
        "oof",
        "ouch",
        "argh",
        "agh",
    ];
}

}
