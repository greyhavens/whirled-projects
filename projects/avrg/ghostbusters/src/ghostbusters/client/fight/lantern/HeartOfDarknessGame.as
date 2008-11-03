package ghostbusters.client.fight.lantern {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.tasks.*;
import com.whirled.contrib.simplegame.util.*;

import flash.display.BlendMode;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import ghostbusters.client.fight.*;
import ghostbusters.client.fight.common.*;
import ghostbusters.client.fight.ouija.BoardTimer;

public class HeartOfDarknessGame extends MicrogameMode
{
    public static const GAME_NAME :String = "Heart of Darkness";
    public static const GAME_DIRECTIONS :String = "Find the heart!";

    public function HeartOfDarknessGame (difficulty :int, context :MicrogameContext)
    {
        super(difficulty, context);

        _settings = DIFFICULTY_SETTINGS[Math.min(difficulty, DIFFICULTY_SETTINGS.length - 1)];
    }

    override public function begin () :void
    {
        MainLoop.instance.pushMode(this);
        MainLoop.instance.pushMode(new IntroMode(GAME_NAME, GAME_DIRECTIONS));
    }

    override protected function get duration () :Number
    {
        return (_settings.gameTime);
    }

    override protected function get timeRemaining () :Number
    {
        return GameTimer.timeRemaining;
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
        // draw the background
        this.modeSprite.graphics.beginFill(0);
        this.modeSprite.graphics.drawRect(0, 0, MicrogameConstants.GAME_WIDTH, MicrogameConstants.GAME_HEIGHT);
        this.modeSprite.graphics.endFill();

        this.modeSprite.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);

        // create the ghost
        _ghost = new Sprite();

        var ghostInstance :MovieClip = _context.ghostMovie;
        ghostInstance.gotoAndStop(1, "heartofdarkness");

        ghostInstance.scaleX = _settings.ghostScale;
        ghostInstance.scaleY = _settings.ghostScale;
        ghostInstance.x = 0;
        ghostInstance.y = 0;

        _ghost.addChild(ghostInstance);

        // align the ghost properly
        var ghostBounds :Rectangle = ghostInstance.getBounds(_ghost);
        ghostInstance.x = -ghostBounds.x;
        ghostInstance.y = -ghostBounds.y;

        // center on the screen
        _ghost.x = (MicrogameConstants.GAME_WIDTH / 2) - (_ghost.width / 2);
        _ghost.y = (MicrogameConstants.GAME_HEIGHT / 2) - (_ghost.height / 2);

        this.modeSprite.addChild(_ghost);

        // the ghost's width and height might change when the ghost's heart
        // is added. save the original values for panning purposes
        _ghostWidth = _ghost.width;
        _ghostHeight = _ghost.height;

        // create the ghost heart
        _heart = new GhostHeart(_settings.heartRadius, _settings.heartShineTime);

        // find a suitable location for the heart
        // randomly generate points on the sprite until we actually
        // intersect with it. This is a potential infinite loop,
        // so limit our searches to something reasonable
        var heartX :Number;
        var heartY :Number;
        for (var i :uint = 0; i < 20; ++i) {
            heartX = Rand.nextIntRange(20, _ghostWidth - 20, Rand.STREAM_COSMETIC);
            heartY = Rand.nextIntRange(20, _ghostHeight - 20, Rand.STREAM_COSMETIC);

            var p :Point = _ghost.localToGlobal(new Point(heartX, heartY));

            if (_ghost.hitTestPoint(p.x, p.y, true)) {
                break;
            }
        }

        _heart.x = heartX;
        _heart.y = heartY;

        this.addObject(_heart, _ghost);

        // draw the darkness that the lantern will cut through
        var darkness :Sprite = new Sprite();
        darkness.graphics.beginFill(0, 1);
        darkness.graphics.drawRect(0, 0, MicrogameConstants.GAME_WIDTH, MicrogameConstants.GAME_HEIGHT);
        darkness.graphics.endFill();
        darkness.blendMode = BlendMode.LAYER;
        this.modeSprite.addChild(darkness);

        // lantern beam
        _beam = new LanternBeam(_settings.lanternBeamRadius, LIGHT_SOURCE, darkness);
        this.addObject(_beam, darkness);

        // create the visual timer
        var boardTimer :BoardTimer = new BoardTimer(this.duration);
        this.addObject(boardTimer, this.modeSprite);

        // install a failure timer
        GameTimer.install(this.duration, function () :void { gameOver(false) });

    }

    protected function onMouseMove (e :MouseEvent) :void
    {
        if (_ghostWidth > MicrogameConstants.GAME_WIDTH) {
            _ghost.x = (-e.localX * (_ghostWidth - MicrogameConstants.GAME_WIDTH)) / MicrogameConstants.GAME_WIDTH;
        }

        if (_ghostHeight > MicrogameConstants.GAME_HEIGHT) {
            _ghost.y = (-e.localY * (_ghostHeight - MicrogameConstants.GAME_HEIGHT)) / MicrogameConstants.GAME_HEIGHT;
        }
    }

    override public function update (dt :Number) :void
    {
        super.update(dt);

        if (_done) {
            return;
        }

        // is the lantern beam over the heart?
        var heartLoc :Vector2 = Vector2.fromPoint(_heart.displayObject.localToGlobal(new Point(0, 0)));
        var beamLoc :Vector2 = Vector2.fromPoint(_beam.displayObject.localToGlobal(new Point(_beam.beamCenter.x, _beam.beamCenter.y)));

        if (Collision.circlesIntersect(heartLoc, _settings.heartRadius, beamLoc, _settings.lanternBeamRadius)) {
            //trace("collision");

            _heart.offsetHealth(-dt);

            if (_heart.health <= 0) {
                this.gameOver(true);
            }
        }
    }

    protected var _settings :HeartOfDarknessSettings;

    protected var _done :Boolean;
    protected var _gameResult :MicrogameResult;

    protected var _beam :LanternBeam;
    protected var _heart :GhostHeart;
    protected var _ghost :Sprite;

    protected var _ghostWidth :Number;
    protected var _ghostHeight :Number;

    protected static var g_assetsLoaded :Boolean;

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

    protected static const DIFFICULTY_SETTINGS :Array = [

        new HeartOfDarknessSettings(
            8,     // game time
            1,      // heart shine time
            50,     // lantern beam radius
            15,     // heart radius
            1.5,     // ghost scale
            5      // damage output
        ),

        new HeartOfDarknessSettings(
            10,     // game time
            1,      // heart shine time
            40,     // lantern beam radius
            8,     // heart radius
            2.5,     // ghost scale
            10    // damage output
        ),

        new HeartOfDarknessSettings(
            9,     // game time
            1,      // heart shine time
            30,     // lantern beam radius
            6,     // heart radius
            3.5,     // ghost scale
            15     // damage output
        ),

    ];

    protected static const LIGHT_SOURCE :Vector2 = new Vector2(MicrogameConstants.GAME_WIDTH / 2, MicrogameConstants.GAME_HEIGHT - 10);

}

}
