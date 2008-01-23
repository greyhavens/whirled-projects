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

    override protected function setup () :void
    {
        // create the ghost
        var ghost :Ghost = new Ghost();
        this.addObject(ghost, this.modeSprite);
        
        // create the ectoplasm
        for (var i :uint = 0; i < ECTOPLASM_COUNT; ++i) {
            var ecto :Ectoplasm = new Ectoplasm();
            ecto.x = Rand.nextIntRange(0, ghost.width, Rand.STREAM_COSMETIC);
            ecto.y = Rand.nextIntRange(0, ghost.height, Rand.STREAM_COSMETIC);
            
            this.addObject(ecto, ghost.displayObjectContainer);
        }
    }
    
    protected static const ECTOPLASM_COUNT :uint = 60;
    
}
