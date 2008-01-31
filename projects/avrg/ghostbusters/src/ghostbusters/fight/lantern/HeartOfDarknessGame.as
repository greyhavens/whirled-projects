package ghostbusters.fight.lantern {

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.resource.*;
import com.whirled.contrib.core.tasks.*;
import com.whirled.contrib.core.util.*;

import flash.display.Bitmap;
import flash.display.BlendMode;
import flash.display.Sprite;
import flash.events.MouseEvent;

import ghostbusters.fight.*;
import ghostbusters.fight.common.*;
import ghostbusters.fight.ouija.BoardTimer;

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
        // draw the background
        this.modeSprite.graphics.beginFill(0);
        this.modeSprite.graphics.drawRect(0, 0, MicrogameConstants.GAME_WIDTH, MicrogameConstants.GAME_HEIGHT);
        this.modeSprite.graphics.endFill();
        
        this.modeSprite.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
        
        // create the ghost
        _ghost = new Sprite();
        var ghostImage :ImageResourceLoader = ResourceManager.instance.getResource("ghost") as ImageResourceLoader;
        var ghostBitmap :Bitmap = ghostImage.createBitmap();
        ghostBitmap.scaleX = _settings.ghostScale;
        ghostBitmap.scaleY = _settings.ghostScale;
        
        _ghost.addChild(ghostBitmap);
        
        this.modeSprite.addChild(_ghost);
        
        // create the ghost heart
        _heart = new GhostHeart(_settings.heartRadius);
        _heart.x = Rand.nextIntRange(_heart.width, _ghost.width - _heart.width, Rand.STREAM_COSMETIC);
        _heart.y = Rand.nextIntRange(_heart.height, _ghost.height - _heart.height, Rand.STREAM_COSMETIC);
        this.addObject(_heart, _ghost);
        
        // draw the darkness that the lantern will cut through
        var darkness :Sprite = new Sprite();
        darkness.graphics.beginFill(0, 0.9);
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
        var timerObj :AppObject = new AppObject();
        timerObj.addTask(new SerialTask(
            new AnimateValueTask(_timeRemaining, 0, this.duration),
            new FunctionTask(
                function () :void { gameOver(false); }
            )));

        this.addObject(timerObj)
        
    }
    
    protected function onMouseMove (e :MouseEvent) :void
    {
        _ghost.x = (-e.localX * (_ghost.width - MicrogameConstants.GAME_WIDTH)) / MicrogameConstants.GAME_WIDTH;
        _ghost.y = (-e.localY * (_ghost.height - MicrogameConstants.GAME_HEIGHT)) / MicrogameConstants.GAME_HEIGHT;
    }
    
    protected var _settings :HeartOfDarknessSettings;
    
    protected var _done :Boolean = false;
    protected var _timeRemaining :Object;
    
    protected var _beam :LanternBeam;
    protected var _heart :GhostHeart;
    protected var _ghost :Sprite;
    
    protected static var g_assetsLoaded :Boolean;
    
    protected static const DIFFICULTY_SETTINGS :Array = [
        new HeartOfDarknessSettings(
            60,     // game time
            50,     // lantern radius
            10,     // heart radius
            4),     // ghost scale
    ];
    
    protected static const LIGHT_SOURCE :Vector2 = new Vector2(MicrogameConstants.GAME_WIDTH / 2, MicrogameConstants.GAME_HEIGHT - 10);
    
}

}

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.resource.*;
import com.whirled.contrib.core.tasks.*;
import com.whirled.contrib.core.util.*;

import ghostbusters.fight.lantern.*;

class LoadingMode extends AppMode
{
    public function LoadingMode ()
    {
    }
    
    override protected function setup () :void
    {
        ResourceManager.instance.pendResourceLoad("image", "heart", { embeddedClass: Content.IMAGE_HEART });
        ResourceManager.instance.pendResourceLoad("image", "ghost", { embeddedClass: Content.IMAGE_GHOST });
        
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
