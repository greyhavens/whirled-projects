package ghostbusters.fight.common {
    
import com.threerings.flash.DisplayUtil;

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.objects.*;
import com.whirled.contrib.core.resource.*;
import com.whirled.contrib.core.tasks.*;

import flash.display.MovieClip;
import flash.events.Event;
import flash.text.TextField;

public class IntroMode extends AppMode
{
    public function IntroMode (gameName :String, text :String)
    {
        _gameName = gameName;
        _text = text;
        
        if (g_resourcesLoaded) {
            this.createScreen();
        } else {
            ResourceManager.instance.pendResourceLoad("swf", "introOutroScreen", { embeddedClass: CommonContent.SWF_INTROOUTROSCREEN });
            ResourceManager.instance.addEventListener(ResourceLoadEvent.LOADED, onResourcesLoaded, false, 0, true);
            
            ResourceManager.instance.load();
            
            g_resourcesLoaded = true;
        }
    }
    
    protected function onResourcesLoaded (e :Event) :void
    {
        this.createScreen();
    }
    
    protected function createScreen () :void
    {
        var swf :SwfResourceLoader = (ResourceManager.instance.getResource("introOutroScreen") as SwfResourceLoader);
        var movieRoot :MovieClip = swf.displayRoot as MovieClip;
        
        this.modeSprite.addChild(movieRoot);
        
        // fill in the text
        //var directions :MovieClip = movieRoot.gameDirections;
        
        //trace(DisplayUtil.dumpHierarchy(directions));
        
        // automatically dismiss the screen after a short while
        
        var timerObj :AppObject = new AppObject();
        timerObj.addTask(new SerialTask(
            new TimedTask(SCREEN_TIME),
            new FunctionTask(MainLoop.instance.popMode)));
            
        this.addObject(timerObj);
    }
    
    protected var _gameName :String;
    protected var _text :String;
    
    protected static var g_resourcesLoaded :Boolean;
    
    protected static const SCREEN_TIME :Number = 1;
}

}

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.objects.*;
import com.whirled.contrib.core.tasks.*;

import ghostbusters.fight.common.*;

import flash.display.Sprite;
import flash.display.Shape;
import flash.display.DisplayObject;
import flash.text.TextField;

class IntroObject extends SceneObject
{
    public function IntroObject (introText :String)
    {
        // create a rectangle
        var rect :Shape = new Shape();
        rect.graphics.beginFill(0x000000);
        rect.graphics.drawRect(0, 0, MicrogameConstants.GAME_WIDTH, MicrogameConstants.GAME_HEIGHT);
        rect.graphics.endFill();

        _sprite.addChild(rect);

        // create the "Spell 'xyz'" text
        var textField :TextField = new TextField();
        textField.textColor = 0xFFFFFF;
        textField.defaultTextFormat.size = 20;
        textField.text = introText;
        textField.width = textField.textWidth + 5;
        textField.height = textField.textHeight + 3;

        // center it
        textField.x = (rect.width / 2) - (textField.width / 2);
        textField.y = (rect.height / 2) - (textField.height / 2);

        _sprite.addChild(textField);

        // fade the object and pop the mode
        var task :SerialTask = new SerialTask();
        task.addTask(new TimedTask(SHOW_TEXT_TIME));
        task.addTask(new AlphaTask(0, FADE_TIME));
        task.addTask(new FunctionTask(MainLoop.instance.popMode));
        this.addTask(task);
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _sprite :Sprite = new Sprite();

    protected static const SHOW_TEXT_TIME :Number = 1;
    protected static const FADE_TIME :Number = 0.25;
}

