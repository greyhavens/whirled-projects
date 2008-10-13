package ghostbusters.client.fight.plasma {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.objects.SimpleSceneObject;
import com.whirled.contrib.simplegame.objects.SimpleTimer;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.tasks.*;
import com.whirled.contrib.simplegame.util.*;

import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.MouseEvent;

import ghostbusters.client.fight.*;
import ghostbusters.client.fight.common.*;
import ghostbusters.client.fight.ouija.BoardTimer;

public class SpiritShellGame extends MicrogameMode
{
    public static const GAME_NAME :String = "";//"Spirit Shell";
    public static const GAME_DIRECTIONS :String = "Fire Questions!";

    public function SpiritShellGame (difficulty :int, context :MicrogameContext)
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
        success = success || _gameWon;
        if (!_done) {
            _plasmaHose.destroySelf();

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
        var swf :SwfResource = ResourceManager.instance.getResource("spiritshell.board") as SwfResource;

        // draw the background
        var bgClass :Class = swf.getClass("BG");
        var bg :MovieClip = new bgClass();
        bg.x = (bg.width * 0.5);
        bg.y = (bg.height * 0.5);
        this.modeSprite.addChild(bg);

        // create the ghost
        var ghostClass :Class = swf.getClass("Ghost");
        _ghostDisplay = new ghostClass() as MovieClip;
        _ghostDisplay.gotoAndStop(1);
        _ghostDisplay.width = 97;
        _ghostDisplay.height = 111;
        _ghostDisplay.x = (_ghostDisplay.width * 0.5);
        _ghostDisplay.y = (_ghostDisplay.height * 0.5);
        var ghostSprite :Sprite = new Sprite();
        ghostSprite.addChild(_ghostDisplay);
        var ghost :SceneObject = new SimpleSceneObject(ghostSprite);
        ghost.x = Rand.nextIntRange(70 + (ghost.width * 0.5), MicrogameConstants.GAME_WIDTH - (ghost.width * 0.5) - 70, Rand.STREAM_COSMETIC);
//        ghost.x = MicrogameConstants.GAME_WIDTH - (ghost.width * 0.5) - 70;
        ghost.y = GHOST_START_LOC.y;
        this.addObject(ghost, this.modeSprite);

        var ghostWidth :int = ghost.width;
        var ghostHeight :int = ghost.height;

        // create the ectoplasm
        var ectoClasses :Array = [
            swf.getClass("swirlspin"),
            swf.getClass("squirrely"),
            swf.getClass("cloud"),
            swf.getClass("cloud2"),
            swf.getClass("triwhirl"),
            swf.getClass("maverick"),
            swf.getClass("lapel_pin")
        ];

        for (var i :uint = 0; i < _settings.ectoplasmCount; ++i) {
            var ectoClass :Class = ectoClasses[Rand.nextIntRange(0, ectoClasses.length, Rand.STREAM_COSMETIC)];
            var ecto :Ectoplasm = new Ectoplasm(ectoClass);
            ecto.x = Rand.nextIntRange(0, ghostWidth + 15, Rand.STREAM_COSMETIC);
            ecto.y = Rand.nextIntRange(0, ghostHeight + 15, Rand.STREAM_COSMETIC);
//            ecto.alpha = Rand.nextNumberRange(0.5, 0.8, Rand.STREAM_COSMETIC);

            this.addObject(ecto, ghost.displayObject as DisplayObjectContainer);
        }

        // move the ghost
        this.moveGhost(ghost);

        // blink the ghost
//        if (_settings.ghostBlink) {
//            var blinkTask :RepeatingTask = new RepeatingTask();
//            blinkTask.addTask(new AlphaTask(0, 0.5));
//            blinkTask.addTask(new TimedTask(0.5));
//            blinkTask.addTask(new AlphaTask(1, 0.5));
//
//            ghost.addTask(blinkTask);
//        }

        // create the plasma gun
        var blasterClass :Class = swf.getClass("gun_rotates");
        _blaster = new SimpleSceneObject(new blasterClass());
        _blaster.x = 147.1;
        _blaster.y = 210.6;
        this.addObject(_blaster, this.modeSprite);


        _plasmaClass = swf.getClass("energyball");
        _plasmaHose = new SimObject();
        _plasmaHose.addTask(new RepeatingTask(
            new TimedTask(_settings.plasmaFireDelay),
            new FunctionTask(createNewPlasma)));

        this.addObject(_plasmaHose);

        // create the visual timer
        var boardTimer :BoardTimer = new BoardTimer(this.duration);
        this.addObject(boardTimer, this.modeSprite);

        // install a failure timer
        GameTimer.install(this.duration, function () :void { gameOver(false) });

        this.modeSprite.addEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
    }

    override protected function destroy () :void
    {
        this.modeSprite.removeEventListener(MouseEvent.MOUSE_MOVE, handleMouseMove);
    }

    protected function handleMouseMove (e :MouseEvent) :void
    {
        var direction :Vector2 = new Vector2(this.modeSprite.mouseX, this.modeSprite.mouseY).subtractLocal(BLASTER_LOC);

        _blasterAngle = direction.angle + (Math.PI * 0.5);

        // map radians on the unit circle to degrees in our scene
        var angle :Number = (_blasterAngle * (180 / Math.PI));// + 180;

        _blaster.rotation = angle;
    }

    protected function moveGhost (ghost :SceneObject) :void
    {
        // only move the ghost if it is capable of moving
        if (_settings.ghostSpeed <= 0) {
            return;
        }

        var distance :Number = _settings.ghostWanderDist.next();
        var direction :Number = Rand.nextNumberRange(0, Math.PI * 2, Rand.STREAM_COSMETIC);

        var start :Vector2 = new Vector2(ghost.x, ghost.y);
        var dest :Vector2 = Vector2.fromAngle(direction, distance).addLocal(start);
        // clamp dest
        var borderWidth :int = 70;
        dest.x = Math.max(dest.x, ghost.width);
        dest.x = Math.min(dest.x, 300 - ghost.width); // board width - ghost width
        dest.y = Math.max(dest.y, ghost.height);
        dest.y = Math.min(dest.y, (226 - ghost.height)); // board height - ghost height
//        dest.x = 300 - ghost.width;
//        dest.y = 226 - ghost.height;
//        // what's the actual distance we're moving?
        distance = dest.subtract(start).length;

        var totalTime :Number = distance / _settings.ghostSpeed;

        var moveTask :SerialTask = new SerialTask();
        moveTask.addTask(LocationTask.CreateSmooth(dest.x, dest.y, totalTime));
        moveTask.addTask(new TimedTask(_settings.ghostWanderDelay.next()));
        moveTask.addTask(new FunctionTask(function () :void { moveGhost(ghost); }));

        ghost.addTask(moveTask);
    }

    protected function createNewPlasma () :void
    {
        var plasma :PlasmaBullet = new PlasmaBullet(_plasmaClass);

        // determine the launch location
        var offset :Vector2 = PLASMA_LAUNCH_OFFSET.rotate(_blasterAngle);
        plasma.x = BLASTER_LOC.x + offset.x;
        plasma.y = BLASTER_LOC.y + offset.y;

        // shoot the plasma in the direction of the cursor
        var cursorLoc :Vector2 = new Vector2(this.modeSprite.mouseX, this.modeSprite.mouseY);

        var launchVector :Vector2 = Vector2.fromAngle(_blasterAngle - (Math.PI * 0.5), 300);
        launchVector.addLocal(BLASTER_LOC);

        var totalTime :Number = (300 / _settings.plasmaSpeed);

        plasma.addTask(LocationTask.CreateEaseOut(launchVector.x, launchVector.y, totalTime));

        this.addObject(plasma, this.modeSprite);
    }

    override public function update (dt :Number) :void
    {
        super.update(dt);

        if (_done) {
            return;
        }

        var thisGameMode :SpiritShellGame = this; // store this for getEctoCollision() local function

        var ectos :Array = this.getObjectRefsInGroup(Ectoplasm.GROUP_NAME);

        if (ectos.length == 0) {
            _gameWon = true;
            if( _ghostDisplay.currentFrame <= 1) {
                _ghostDisplay.gotoAndPlay(2);
            }
            MainLoop.instance.topMode.addObject( new SimpleTimer(2.0, function () :void { gameOver(true) } ));
//            this.gameOver(true);
        }

        // handle plasma-ectoplasm collision detection.
        // we inefficiently check every plasma against every ectoplasm.
        var plasmas :Array = this.getObjectRefsInGroup(PlasmaBullet.GROUP_NAME);
        for each (var plasmaRef :SimObjectRef in plasmas) {

            var plasma :PlasmaBullet = plasmaRef.object as PlasmaBullet;
            if (null == plasma) {
                continue;
            }

            if (plasma.x < -PlasmaBullet.RADIUS ||
                plasma.x > 296 + PlasmaBullet.RADIUS ||
                plasma.y < -PlasmaBullet.RADIUS ||
                plasma.y > 223 + PlasmaBullet.RADIUS) {
                    plasma.destroySelf();
                    continue;
            }

            var ecto :Ectoplasm = getEctoCollision(plasma);
            if (null != ecto) {
                plasma.destroySelf();
                ecto.destroySelf();
            }
        }

        function getEctoCollision (p :PlasmaBullet) :Ectoplasm
        {
            for each (var ectoRef :SimObjectRef in ectos) {
                var e :Ectoplasm = ectoRef.object as Ectoplasm;

                if (null == e) {
                    continue;
                }

                if (Collision.circularDisplayObjectsIntersect(
                        new Vector2(p.x, p.y),
                        PlasmaBullet.RADIUS,
                        p.displayObject,
                        new Vector2(e.x, e.y),
                        Ectoplasm.RADIUS,
                        e.displayObject)) {
                    return e;
                }
            }

            return null;
        }
    }

    protected var _ghostDisplay :MovieClip;
    protected var _done :Boolean = false;
    protected var _gameResult :MicrogameResult;
    protected var _settings :SpiritShellSettings;
    protected var _plasmaClass :Class;
    protected var _plasmaHose :SimObject;
    protected var _blaster :SceneObject;
    protected var _blasterAngle :Number = 0;

    protected static const GHOST_START_LOC :Vector2 = new Vector2(148, 40);
    protected static const BLASTER_LOC :Vector2 = new Vector2(147.1, 210.6);
    protected static const PLASMA_LAUNCH_OFFSET :Vector2 = new Vector2(0, -30);

    protected static const DIFFICULTY_SETTINGS :Array = [

        new SpiritShellSettings(
            6,      // gameTime
            15,     // ectoplasmCount
            5,      // ghostSpeed
            new NumRange(15, 20, Rand.STREAM_COSMETIC),   // ghostWanderDist
            new NumRange(0.3, 0, Rand.STREAM_COSMETIC),   // ghostWanderDelay
            false,  // ghostBlink
            150,    // plasmaSpeed
            0.1,     // plasmaFireDelay
            5       // damage output
        ),
        
        new SpiritShellSettings(
            6,      // gameTime
            25,     // ectoplasmCount
            30,      // ghostSpeed
            new NumRange(15, 30, Rand.STREAM_COSMETIC),   // ghostWanderDist
            new NumRange(0.2, 0, Rand.STREAM_COSMETIC),   // ghostWanderDelay
            false,  // ghostBlink
            150,    // plasmaSpeed
            0.1,     // plasmaFireDelay
            5       // damage output
        ),
        
        new SpiritShellSettings(
            6,      // gameTime
            30,     // ectoplasmCount
            70,      // ghostSpeed
            new NumRange(15, 50, Rand.STREAM_COSMETIC),   // ghostWanderDist
            new NumRange(0.1, 0, Rand.STREAM_COSMETIC),   // ghostWanderDelay
            false,  // ghostBlink
            150,    // plasmaSpeed
            0.1,     // plasmaFireDelay
            5       // damage output
        ),

        new SpiritShellSettings(
            6,      // gameTime
            35,     // ectoplasmCount
            90,//30,      // ghostSpeed
            new NumRange(50, 100, Rand.STREAM_COSMETIC),   // ghostWanderDist
            new NumRange(0, 0, Rand.STREAM_COSMETIC),   // ghostWanderDelay
            false,  // ghostBlink
            150,    // plasmaSpeed
            0.1,     // plasmaFireDelay
            5       // damage output
        ),

        new SpiritShellSettings(
            8,      // gameTime
            47,     // ectoplasmCount
            140,//40,      // ghostSpeed
            new NumRange(90, 100, Rand.STREAM_COSMETIC),   // ghostWanderDist
            new NumRange(0, 0, Rand.STREAM_COSMETIC),   // ghostWanderDelay
            true,  // ghostBlink
            150,    // plasmaSpeed
            0.1,     // plasmaFireDelay
            5       // damage output
        )

    ];

    protected static const WIN_STRINGS :Array = [
        "TRUE\nCOLORS!",
//        "\nDISCOVERED!",
        "\nREVEALED!",
        "\nINCISIVE!",
        "\nUNCOVERED!" 
    ];

    protected static const LOSE_STRINGS :Array = [
        "\nbush-whacked!",
        "\nNeo-conned!",
        "\n4 more years!",
        "\nright winged!",

    ];

}

}
