package ghostbusters.fight.plasma {

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.util.*;

import flash.display.Sprite;

[SWF(width="300", height="226", frameRate="30")]
public class SpiritShellGame extends Sprite
{
    public function SpiritShellGame ()
    {
        var mainLoop :MainLoop = new MainLoop(this);
        mainLoop.run();
        
        ResourceManager.instance.loadFromClass("image_ghost", Content.IMAGE_GHOST);
        ResourceManager.instance.loadFromClass("image_ectoplasm", Content.IMAGE_ECTOPLASM);
        ResourceManager.instance.loadFromClass("image_plasma", Content.IMAGE_PLASMA);

        GameMode.beginGame();
    }
}

}

import com.threerings.util.ArrayUtil;

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.tasks.*;
import com.whirled.contrib.core.util.*;

import ghostbusters.fight.plasma.*;
import ghostbusters.fight.common.*;

import flash.display.Sprite;
import flash.display.Shape;
import flash.display.DisplayObject;
import flash.display.Bitmap;

import flash.events.MouseEvent;

import ghostbusters.fight.ouija.BoardTimer;
import com.whirled.contrib.GameMode;
import flash.geom.Point;

class GameMode extends AppMode
{
    public static function beginGame () :void
    {
        MainLoop.instance.pushMode(new GameMode(Rand.nextIntRange(0, DIFFICULTY_SETTINGS.length, Rand.STREAM_COSMETIC)));
        
        MainLoop.instance.pushMode(new IntroMode("Clear the ectoplasm!"));
        MainLoop.instance.pushMode(new SplashMode("Spirit Shell"));
    }

    protected function endGame (success :Boolean) :void
    {
        MainLoop.instance.pushMode(new OutroMode(success, beginGame));
    }

    public function GameMode (difficulty :uint)
    {
        difficulty = Math.min(difficulty, DIFFICULTY_SETTINGS.length - 1);
        _settings = DIFFICULTY_SETTINGS[difficulty];
    }
    
    protected function moveGhost (ghost :Ghost) :void
    {
        // only move the ghost if it is capable of moving
        if (_settings.ghostSpeed <= 0) {
            return;
        }
        
        var distance :Number = _settings.ghostWanderDist.next();
        var direction :Number = Rand.nextNumberRange(0, Math.PI * 2, Rand.STREAM_COSMETIC);
        
        var start :Vector2 = new Vector2(ghost.x, ghost.y);
        var dest :Vector2 = Vector2.fromAngleRadians(direction, distance);
        dest.add(start);
        
        // clamp dest
        dest.x = Math.max(dest.x, 0);
        dest.x = Math.min(dest.x, 300 - ghost.width); // board width - ghost width
        dest.y = Math.max(dest.y, 0);
        dest.y = Math.min(dest.y, 226 - ghost.height); // board height - ghost height
        
        // what's the actual distance we're moving?
        distance = dest.getSubtract(start).length;
        
        var totalTime :Number = distance / _settings.ghostSpeed;
        
        var moveTask :SerialTask = new SerialTask();
        moveTask.addTask(LocationTask.CreateSmooth(dest.x, dest.y, totalTime));
        moveTask.addTask(new TimedTask(_settings.ghostWanderDelay.next()));
        moveTask.addTask(new FunctionTask(function () :void { moveGhost(ghost); }));
        
        ghost.addTask(moveTask);
    }

    //override protected function setup () :void
    protected function doSetup () :void
    {
        // create the ghost
        var ghost :Ghost = new Ghost();
        ghost.x = Rand.nextIntRange(0, 300 - ghost.width, Rand.STREAM_COSMETIC);
        ghost.y = GHOST_START_LOC.y;
        this.addObject(ghost, this.modeSprite);
        
        var ghostWidth :int = ghost.width;
        var ghostHeight :int = ghost.height;
        
        // create the ectoplasm
        for (var i :uint = 0; i < _settings.ectoplasmCount; ++i) {
            var ecto :Ectoplasm = new Ectoplasm();
            ecto.x = Rand.nextIntRange(0, ghostWidth, Rand.STREAM_COSMETIC);
            ecto.y = Rand.nextIntRange(0, ghostHeight, Rand.STREAM_COSMETIC);
            
            this.addObject(ecto, ghost.displayObjectContainer);
        }
        
        // move the ghost
        this.moveGhost(ghost);
        
        // blink the ghost
        if (_settings.ghostBlink) {
            var blinkTask :RepeatingTask = new RepeatingTask();
            blinkTask.addTask(new AlphaTask(0, 0.5));
            blinkTask.addTask(new TimedTask(0.5));
            blinkTask.addTask(new AlphaTask(1, 0.5));
            
            ghost.addTask(blinkTask);
        }
        
        var plasmaHose :AppObject = new AppObject();
        plasmaHose.addTask(new RepeatingTask(
            new TimedTask(_settings.plasmaFireDelay),
            new FunctionTask(createNewPlasma)));
            
        this.addObject(plasmaHose);

        // create the visual timer
        var boardTimer :BoardTimer = new BoardTimer(_settings.gameTime);
        this.addObject(boardTimer, this.modeSprite);

        // install a failure timer
        var timerObj :AppObject = new AppObject();
        timerObj.addTask(new SerialTask(
            new TimedTask(_settings.gameTime),
            new FunctionTask(
                function () :void { endGame(false); }
            )));

        this.addObject(timerObj);
    }
    
    protected function createNewPlasma () :void
    {
        var plasma :PlasmaBullet = new PlasmaBullet();
        plasma.x = PLASMA_LAUNCH_LOC.x;
        plasma.y = PLASMA_LAUNCH_LOC.y;
        
        // shoot the plasma in the direction of the cursor
        var cursorLoc :Vector2 = new Vector2(this.modeSprite.mouseX, this.modeSprite.mouseY);
        
        var launchVector :Vector2 = cursorLoc.getSubtract(PLASMA_LAUNCH_LOC);
        launchVector.length = 300;
        launchVector.add(PLASMA_LAUNCH_LOC);
        
        var totalTime :Number = (300 / _settings.plasmaSpeed);
        
        plasma.addTask(LocationTask.CreateEaseOut(launchVector.x, launchVector.y, totalTime));
        
        this.addObject(plasma, this.modeSprite);
    }
    
    override public function update (dt :Number) :void
    {
        var thisGameMode :GameMode = this; // store this for getEctoCollision() local function
        
        if (!_hasSetup && !ResourceManager.instance.hasPendingResources) {
            this.doSetup();
            _hasSetup = true;
        }
        
        super.update(dt);
        
        var ectos :Array = this.getObjectsInGroup(Ectoplasm.GROUP_NAME);
        
        if (ectos.length == 0) {
            this.endGame(true);
        }
        
        // handle plasma-ectoplasm collision detection.
        // we inefficiently check every plasma against every ectoplasm.
        var plasmas :Array = this.getObjectsInGroup(PlasmaBullet.GROUP_NAME);
        for each (var plasmaId :uint in plasmas) {
            
            var plasma :PlasmaBullet = this.getObject(plasmaId) as PlasmaBullet;
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
            for each (var ectoId :uint in ectos) {
                var e :Ectoplasm = thisGameMode.getObject(ectoId) as Ectoplasm;
                
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
    
    protected var _hasSetup :Boolean = false;
    protected var _settings :SpiritShellSettings;
    
    protected static const DIFFICULTY_SETTINGS :Array = [
    
        new SpiritShellSettings(
            6,      // gameTime
            15,     // ectoplasmCount
            5,      // ghostSpeed
            new NumRange(15, 20, Rand.STREAM_COSMETIC),   // ghostWanderDist
            new NumRange(0, 0, Rand.STREAM_COSMETIC),   // ghostWanderDelay
            false,  // ghostBlink
            150,    // plasmaSpeed
            0.1     // plasmaFireDelay
        ),
        
        new SpiritShellSettings(
            6,      // gameTime
            25,     // ectoplasmCount
            30,      // ghostSpeed
            new NumRange(30, 40, Rand.STREAM_COSMETIC),   // ghostWanderDist
            new NumRange(0.3, 1, Rand.STREAM_COSMETIC),   // ghostWanderDelay
            false,  // ghostBlink
            150,    // plasmaSpeed
            0.1     // plasmaFireDelay
        ),
        
        new SpiritShellSettings(
            8,      // gameTime
            35,     // ectoplasmCount
            40,      // ghostSpeed
            new NumRange(70, 80, Rand.STREAM_COSMETIC),   // ghostWanderDist
            new NumRange(0.1, 0.1, Rand.STREAM_COSMETIC),   // ghostWanderDelay
            true,  // ghostBlink
            150,    // plasmaSpeed
            0.1     // plasmaFireDelay
        ),
        
    ];
    
    protected static const PLASMA_LAUNCH_LOC :Vector2 = new Vector2(148, 215);
    protected static const GHOST_START_LOC :Vector2 = new Vector2(148, 12);
    
}
