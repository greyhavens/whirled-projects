package ghostbusters.fight.plasma {

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.util.*;

import flash.display.Sprite;

[SWF(width="296", height="223", frameRate="30")]
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

class GameMode extends AppMode
{
    public static function beginGame () :void
    {
        MainLoop.instance.pushMode(new GameMode());
        
        MainLoop.instance.pushMode(new IntroMode("Clear the ectoplasm!"));
        MainLoop.instance.pushMode(new SplashMode("Spirit Shell"));
    }

    protected function endGame (success :Boolean) :void
    {
        MainLoop.instance.pushMode(new OutroMode(success, beginGame));
    }

    public function GameMode ()
    {
    }

    //override protected function setup () :void
    protected function doSetup () :void
    {
        // create the ghost
        var ghost :Ghost = new Ghost();
        this.addObject(ghost, this.modeSprite);
        
        var ghostWidth :int = ghost.width;
        var ghostHeight :int = ghost.height;
        
        // create the ectoplasm
        for (var i :uint = 0; i < ECTOPLASM_COUNT; ++i) {
            var ecto :Ectoplasm = new Ectoplasm();
            ecto.x = Rand.nextIntRange(0, ghostWidth, Rand.STREAM_COSMETIC);
            ecto.y = Rand.nextIntRange(0, ghostHeight, Rand.STREAM_COSMETIC);
            
            this.addObject(ecto, ghost.displayObjectContainer);
        }
        
        var plasmaHose :AppObject = new AppObject();
        plasmaHose.addTask(new RepeatingTask(
            new TimedTask(PLASMA_FIRE_DELAY),
            new FunctionTask(createNewPlasma)));
            
        this.addObject(plasmaHose);
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
        
        var totalTime :Number = (300 / PLASMA_SPEED);
        
        plasma.addTask(LocationTask.CreateEaseOut(launchVector.x, launchVector.y, totalTime));
        
        this.addObject(plasma, this.modeSprite);
    }
    
    override public function update (dt :Number) :void
    {
        if (!_hasSetup && !ResourceManager.instance.hasPendingResources) {
            this.doSetup();
            _hasSetup = true;
        }
        
        super.update(dt);
        
        var ectos :Array = this.getObjectsInGroup(Ectoplasm.GROUP_NAME);
        
        // handle plasmas
        var plasmas :Array = this.getObjectsInGroup(PlasmaBullet.GROUP_NAME);
        for each (var plasma :PlasmaBullet in plasmas) {
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
            for each (var e :Ectoplasm in ectos) {
                if (Collision.circlesIntersect(new Vector2(p.x, p.y), PlasmaBullet.RADIUS, new Vector2(e.x, e.y), Ectoplasm.RADIUS)) {
                    return e;
                }
            }
            
            return null;
        }
    }
    
    protected var _hasSetup :Boolean = false;
    
    protected static const ECTOPLASM_COUNT :uint = 60;
    protected static const PLASMA_FIRE_DELAY :Number = 0.1;
    protected static const PLASMA_LAUNCH_LOC :Vector2 = new Vector2(148, 215);
    protected static const PLASMA_SPEED :Number = 150; // pixels-per-second
    
}
