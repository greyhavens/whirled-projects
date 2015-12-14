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
    public static const GAME_NAME :String = "";//FactFinder";
    public static const GAME_DIRECTIONS :String = "Find the Revealing Quote!";

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
        return (_done && !WinLoseNotification.isPlaying);
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

        var boardSize :int = Math.max(MicrogameConstants.GAME_WIDTH, MicrogameConstants.GAME_HEIGHT) * 1.5 *_settings.ghostScale;
//        var ghostInstance :MovieClip = _context.ghostMovie;
        var ghostInstance :MovieClip = new MovieClip(); 
        ghostInstance.graphics.beginFill(0xffffff);
        ghostInstance.graphics.drawRect(0, 0, boardSize, boardSize);
        ghostInstance.graphics.endFill();
        
//        ghostInstance.gotoAndStop(1, "heartofdarkness");

//        ghostInstance.scaleX = _settings.ghostScale;
//        ghostInstance.scaleY = _settings.ghostScale;
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

//        this.modeSprite.addChild(_ghost);

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
//        var heartX :Number;
//        var heartY :Number;
//        for (var i :uint = 0; i < 20; ++i) {
//            heartX = Rand.nextIntRange(20, _ghostWidth - 20, Rand.STREAM_COSMETIC);
//            heartY = Rand.nextIntRange(20, _ghostHeight - 20, Rand.STREAM_COSMETIC);
//
//            var p :Point = _ghost.localToGlobal(new Point(heartX, heartY));
//
//            if (_ghost.hitTestPoint(p.x, p.y, true)) {
//                break;
//            }
//        }
//
//        _heart.x = heartX;
//        _heart.y = heartY;

        
        
        
        //Draw the clutter
//        var heart :DisplayObject = SwfResource.getSwfDisplayRoot("lantern.heart");
        
        var swf :SwfResource = (ResourceManager.instance.getResource("lantern.heart") as SwfResource);
        var clutterClass :Class = swf.getClass("clutter");


//        Rand.setup();
//        var heart :DisplayObject = new SimpleTextButton(REAL_CAMPAIGN_INFORMATION[ Rand.nextIntRange(0, REAL_CAMPAIGN_INFORMATION.length, 0) ]);

        //Clutter
        //About 5 clutters fit horizontally
        var numberOfCluttersThatFitHorizontally :int = boardSize/80;//4;
        var numberOfCluttersThatFitVertically :int = boardSize/60;//5;
        var leftGap :int = 40;//20;
        var spacingH :int = (boardSize - leftGap*2 ) / numberOfCluttersThatFitHorizontally;
        var spacingV :int = (boardSize - leftGap*2 ) / numberOfCluttersThatFitVertically;
//        var clutterNumber :int = 30;
//        while( clutterNumber > 0)
//        {
//            
//        }
        var slotsFilled :Array = new Array();
        
        
        var xSlot :int = Rand.nextIntRange(0, numberOfCluttersThatFitHorizontally, Rand.STREAM_COSMETIC);
        var ySlot :int = Rand.nextIntRange(0, numberOfCluttersThatFitVertically, Rand.STREAM_COSMETIC);
        
        
        _heart.x = leftGap + spacingH * (xSlot + 0.5) ;
        _heart.y = leftGap + spacingV * (ySlot + 0.5) ;
        
        
        slotsFilled.push( [xSlot, ySlot] );
//        trace("heartslot=" + [xSlot, ySlot]);
        
        var alternator :Boolean = true;
        var randomSpacing :int = 25;
        for( var k :int = 0; k < numberOfCluttersThatFitHorizontally; k++) {
            for( var j :int = 0; j < numberOfCluttersThatFitVertically; j++) { 
                
//                var o :DisplayObject = DisplayUtil.findInHierarchy(_inventory, name);
                alternator = !alternator;
                var clutter :MovieClip = new clutterClass();
                MovieClip(clutter.sub).gotoAndStop(Rand.nextIntRange(0, 14, Rand.STREAM_COSMETIC));
                
                xSlot = k;//Rand.nextIntRange(0, numberOfCluttersThatFitHorizontally, Rand.STREAM_COSMETIC);
                ySlot = j;//Rand.nextIntRange(0, numberOfCluttersThatFitHorizontally, Rand.STREAM_COSMETIC);
                
                var newSlot :Array = [xSlot, ySlot];
                    
                function missing(element:*, index:int, arr:Array):Boolean {
                    return !(element[0] == newSlot[0] && element[1] == newSlot[1]);
                }
    
    
                if( !slotsFilled.every( missing ) ||  alternator) {
//                    trace("heat slot areached, continuing " + [k, j]);
//                    alternator = !alternator;
                    continue;
                }
                
                
                
                slotsFilled.push( newSlot );
                
                
                
                
                
                clutter.scaleX = _heart.scaleX*0.7;
                clutter.scaleY = _heart.scaleY*0.7;
//                clutter.scaleX = _heart;
//                clutter.scaleY = 0.45;
                
//                clutter.graphics.beginFill(0x000000);
//                clutter.graphics.drawEllipse(-25, -25, 50, 50);
//                clutter.graphics.endFill();
                
                clutter.x = leftGap + spacingH * (xSlot + 0.5) + Rand.nextIntRange(-randomSpacing, randomSpacing, Rand.STREAM_COSMETIC);
                clutter.y = leftGap + spacingV * (ySlot + 0.5) + Rand.nextIntRange(-randomSpacing-10, randomSpacing+10, Rand.STREAM_COSMETIC);
                clutter.rotation = clutter.rotation + Rand.nextIntRange(-10, 10, Rand.STREAM_COSMETIC);
                
//                this.modeSprite.addChild(clutter);
                _ghost.addChild(clutter);
            }
        }
        
//        this.addObject(_heart, this.modeSprite);
        this.addObject(_heart,_ghost);
        this.modeSprite.addChild(_ghost);
        
//        _heart.x = 100;
//        _heart.y = 100;
        
        
        
        
        
        
        

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
            _heart.showBorder();
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
        "\nREVEALING!",
        "GOOD\nTO KNOW!",
        "\nREALLY!",
        "\nIS THAT SO!",
    ];

    protected static const LOSE_STRINGS :Array = [
        "\ntalking points",
        "\nsoundbites",
        "\ndistractions",
        "\nspin",
    ];

    protected static const DIFFICULTY_SETTINGS :Array = [

//        new HeartOfDarknessSettings(
//            8,     // game time
//            3,      // heart shine time
//            80,     // lantern beam radius
//            20,     // heart radius
//            1.2,     // ghost scale
//            5      // damage output
//        ),
//        
//        new HeartOfDarknessSettings(
//            8,     // game time
//            3,      // heart shine time
//            80,     // lantern beam radius
//            20,     // heart radius
//            1.3,     // ghost scale
//            5      // damage output
//        ),
        
        new HeartOfDarknessSettings(
            8,     // game time
            3,      // heart shine time
            120,     // lantern beam radius
            20,     // heart radius
            1.5,     // ghost scale
            testing ? 500 : 7      // damage output
        ),
        
        new HeartOfDarknessSettings(
            8,     // game time
            3,      // heart shine time
            120,     // lantern beam radius
            20,     // heart radius
            1.7,     // ghost scale
            testing ? 500 : 12      // damage output
        ),
        
        new HeartOfDarknessSettings(
            8,     // game time
            3,      // heart shine time
            120,     // lantern beam radius
            20,     // heart radius
            2.0,     // ghost scale
            testing ? 500 : 20      // damage output
        )

        

    ];

    protected static const LIGHT_SOURCE :Vector2 = new Vector2(MicrogameConstants.GAME_WIDTH / 2, MicrogameConstants.GAME_HEIGHT - 10);
    private static const testing :Boolean = false;

}

}
