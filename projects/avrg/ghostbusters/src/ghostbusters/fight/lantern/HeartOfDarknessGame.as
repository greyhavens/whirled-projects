package ghostbusters.fight.lantern {
    
import com.whirled.contrib.core.*;
import com.whirled.contrib.core.resource.*;
import com.whirled.contrib.core.tasks.*;
import com.whirled.contrib.core.util.*;

import flash.display.BlendMode;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

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
    
    override public function get gameResult () :MicrogameResult
    {
        return _gameResult;
    }
    
    protected function gameOver (success :Boolean) :void
    {
        if (!_done) {
            _gameResult = new MicrogameResult();
            _gameResult.success = (success ? MicrogameResult.SUCCESS : MicrogameResult.FAILURE);
            
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
        
        var ghostSwf :SwfResourceLoader = ResourceManager.instance.getResource("hod_ghost") as SwfResourceLoader;
        var ghostInstance :MovieClip = ghostSwf.displayRoot as MovieClip;
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
        _heart.x = Rand.nextIntRange(20, _ghost.width - 20, Rand.STREAM_COSMETIC);
        _heart.y = Rand.nextIntRange(20, _ghost.width - 20, Rand.STREAM_COSMETIC);
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
        
        // is the lantern beam over the heart?
        var heartLoc :Vector2 = Vector2.fromPoint(_heart.displayObject.localToGlobal(new Point(0, 0)));
        
        if (Collision.circlesIntersect(heartLoc, _settings.heartRadius, _beam.beamCenter, _settings.lanternBeamRadius)) {
            _heart.offsetHealth(-dt);
            
            if (_heart.health <= 0) {
                this.gameOver(true);
            }
        }
    }
    
    protected var _settings :HeartOfDarknessSettings;
    
    protected var _done :Boolean;
    protected var _gameResult :MicrogameResult;
    protected var _timeRemaining :Object;
    
    protected var _beam :LanternBeam;
    protected var _heart :GhostHeart;
    protected var _ghost :Sprite;
    
    protected var _ghostWidth :Number;
    protected var _ghostHeight :Number;
    
    protected static var g_assetsLoaded :Boolean;
    
    protected static const DIFFICULTY_SETTINGS :Array = [
    
        new HeartOfDarknessSettings(
            8,     // game time
            1,      // heart shine time
            50,     // lantern beam radius
            15,     // heart radius
            1.5),     // ghost scale
            
        new HeartOfDarknessSettings(
            12,     // game time
            1,      // heart shine time
            40,     // lantern beam radius
            8,     // heart radius
            2.5),     // ghost scale
            
        new HeartOfDarknessSettings(
            15,     // game time
            1,      // heart shine time
            35,     // lantern beam radius
            4,     // heart radius
            3.5),     // ghost scale
            
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
        ResourceManager.instance.pendResourceLoad("swf", "hod_heart", { embeddedClass: Content.SWF_HEART });
        ResourceManager.instance.pendResourceLoad("swf", "hod_ghost", { embeddedClass: Content.SWF_GHOST });
        
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
