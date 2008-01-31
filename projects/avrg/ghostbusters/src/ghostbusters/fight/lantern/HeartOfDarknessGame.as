package ghostbusters.fight.lantern {

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.resource.*;
import com.whirled.contrib.core.tasks.*;
import com.whirled.contrib.core.util.*;

import ghostbusters.fight.*;
import ghostbusters.fight.common.*;

public class HeartOfDarknessGame extends MicrogameMode
{
    public function HeartOfDarknessGame (difficulty :int, playerData :Object)
    {
        super(difficulty, playerData);
        
        _settings = DIFFICULTY_SETTINGS[Math.min(difficulty, DIFFICULTY_SETTINGS.length - 1)];
         
        _timeRemaining = { value: this.duration };
    }
    
    override public function begin () :void
    {
        MainLoop.instance.pushMode(this);
        
        if (!g_assetsLoaded) {
            MainLoop.instance.pushMode(new LoadingMode());
            g_assetsLoaded = true;
        }
        
        MainLoop.instance.pushMode(new IntroMode("Find the heart!"));
    }
    
    override protected function get duration () :Number
    {
        return (_settings.gameTime);
    }
    
    override protected function get timeRemaining () :Number
    {
        return (_done ? 0 : _timeRemaining.value);
    }
    
    override public function get isDone () :Boolean
    {
        return _done;
    }
    
    protected function gameOver (success :Boolean) :void
    {
        if (!_done) {
            //MainLoop.instance.pushMode(new OutroMode(success));
            _done = true;
        }
    }

    override protected function setup () :void
    {
        
    }
    
    protected var _done :Boolean = false;
    protected var _timeRemaining :Object;
    protected var _settings :HeartOfDarknessSettings;
    
    protected static var g_assetsLoaded :Boolean;
    
    protected static const DIFFICULTY_SETTINGS :Array = [
        new HeartOfDarknessSettings(60),
    ];
    
}

}

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.resource.*;
import com.whirled.contrib.core.tasks.*;
import com.whirled.contrib.core.util.*;

import ghostbusters.fight.plasma.*;

class LoadingMode extends AppMode
{
    public function LoadingMode ()
    {
    }
    
    override protected function setup () :void
    {
        ResourceManager.instance.pendResourceLoad("image", "heart", { embeddedClass: Content.IMAGE_HEART });
        ResourceManager.instance.pendResourceLoad("image", "bg", { embeddedClass: Content.IMAGE_BG });
        
        ResourceManager.instance.load();
    }
    
    override public function update (dt:Number) :void
    {
        super.update(dt);
        
        if (!ResourceManager.instance.isLoading) {
            MainLoop.instance.popMode();
        }
    }
}
