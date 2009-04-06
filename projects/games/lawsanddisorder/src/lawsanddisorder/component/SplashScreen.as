package lawsanddisorder.component {

import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.ColorTransform;
import flash.text.TextField;

import lawsanddisorder.*;

/**
 * An introductory screen shown when the game starts, that allows players to choose between
 * single and multiplayer modes, pick single player options, and view instructions prior to
 * starting the game.
 */
public class SplashScreen extends Component
{
    /** Displays a help screen overlay - static singleton sprite */
    public static var helpScreen :Sprite;
    {
        helpScreen = new HELP_SCREEN();
        helpScreen.addEventListener(MouseEvent.CLICK, SplashScreen.helpScreenClicked);
        helpScreen.buttonMode = true;
    }
    
    /**
     * Constructor
     */
    public function SplashScreen (ctx :Context)
    {
        super(ctx);

        // show the splash screen over the entire board
        embedGraphics = new SPLASH_SCREEN();
        addChild(embedGraphics);
        
        var buttonSingle :SimpleButton = embedGraphics["button_singleplayer"];
        buttonSingle.addEventListener(MouseEvent.CLICK, splashSingleClicked);
        
        var buttonMulti :SimpleButton = embedGraphics["button_multiplayer"];
        buttonMulti.addEventListener(MouseEvent.CLICK, splashMultiClicked);
        
        var buttonHelp :SimpleButton = embedGraphics["button_help"];
        buttonHelp.addEventListener(MouseEvent.CLICK, splashHelpClicked);
        
        hookupSpeedHandler(Context.SPEED_SLOW_STRING);
        hookupSpeedHandler(Context.SPEED_NORMAL_STRING);
        hookupSpeedHandler(Context.SPEED_LIGHTSPEED_STRING);
        if (_ctx.aiDelaySeconds == Context.SPEED_SLOW) {
            highlightButton("button_aispeed_" + Context.SPEED_SLOW_STRING);
        } else if (_ctx.aiDelaySeconds == Context.SPEED_NORMAL) {
            highlightButton("button_aispeed_" + Context.SPEED_NORMAL_STRING);
        } else if (_ctx.aiDelaySeconds == Context.SPEED_LIGHTSPEED) {
            highlightButton("button_aispeed_" + Context.SPEED_LIGHTSPEED_STRING);
        }
        
        hookupLevelHandler(Context.LEVEL_DUMB_STRING);
        hookupLevelHandler(Context.LEVEL_DUMBER_STRING);
        hookupLevelHandler(Context.LEVEL_DUMBEST_STRING);
        if (_ctx.aiDumbnessFactor == Context.LEVEL_DUMB) {
            highlightButton("button_ailevel_" + Context.LEVEL_DUMB_STRING);
        } else if (_ctx.aiDumbnessFactor == Context.LEVEL_DUMBER) {
            highlightButton("button_ailevel_" + Context.LEVEL_DUMBER_STRING);
        } else if (_ctx.aiDumbnessFactor == Context.LEVEL_DUMBEST) {
            highlightButton("button_ailevel_" + Context.LEVEL_DUMBEST_STRING);
        }
        
        for (var ii:int = 1; ii <= 5; ii++) {
            hookupNumAIPlayersHandler(ii);
        }
        highlightButton("button_ainum_" + _ctx.numAIPlayers);
        
        hookupSoundHandler(Context.SOUND_ALL_STRING);
        hookupSoundHandler(Context.SOUND_SFX_STRING);
        hookupSoundHandler(Context.SOUND_NONE_STRING);
        if (Context.sfxEnabled && Context.musicEnabled) {
            highlightButton("button_sound_" + Context.SOUND_ALL_STRING);
        } else if (Context.sfxEnabled) {
            highlightButton("button_sound_" + Context.SOUND_SFX_STRING);
        } else {
            highlightButton("button_sound_" + Context.SOUND_NONE_STRING);
        }
    }
    
    /**
     * Connect a click handler to the appropriate ai level button.
     */
    protected function hookupLevelHandler (levelName :String) :void
    {
        var button :SimpleButton = embedGraphics["button_ailevel_" + levelName];
        button.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
	        	highlightButton(button.name);
	            _ctx.setAiLevel(levelName);
            });
    }
    
    /**
     * Connect a click handler to the appropriate speed button.
     */
    protected function hookupSpeedHandler (speedName :String) :void
    {
        var button :SimpleButton = embedGraphics["button_aispeed_" + speedName];
        button.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
	        	highlightButton(button.name);
	            _ctx.setAiSpeed(speedName);
            });
    }
    
    /**
     * Connect a click handler to the appropriate num ai button.
     */
    protected function hookupNumAIPlayersHandler (numAIPlayers :int) :void
    {
        var button :SimpleButton = embedGraphics["button_ainum_" + numAIPlayers];
        button.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
	        	highlightButton(button.name);
	            _ctx.setNumAIPlayers(String(numAIPlayers));
            });
    }
    
    /**
     * Connect a click handler to the appropriate sound button.
     */
    protected function hookupSoundHandler (soundName :String) :void
    {
        var button :SimpleButton = embedGraphics["button_sound_" + soundName];
        button.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
	            highlightButton(button.name);
	            Context.setSoundConfig(soundName);
            });
    }
    
    /**
     * Colors the give button to indicate it is selected, and un-select other buttons of the 
     * same group.
     */
    protected function highlightButton (buttonName :String) :void
    {
        if (buttonName.search("aispeed") != -1) {
            deHighlightButton("button_aispeed_" + Context.SPEED_SLOW_STRING);
            deHighlightButton("button_aispeed_" + Context.SPEED_NORMAL_STRING);
            deHighlightButton("button_aispeed_" + Context.SPEED_LIGHTSPEED_STRING);
        } else if (buttonName.search("ailevel") != -1) {
            deHighlightButton("button_ailevel_" + Context.LEVEL_DUMB_STRING);
            deHighlightButton("button_ailevel_" + Context.LEVEL_DUMBER_STRING);
            deHighlightButton("button_ailevel_" + Context.LEVEL_DUMBEST_STRING);
        } else if (buttonName.search("ainum") != -1) {
	        for (var ii:int = 1; ii <= 5; ii++) {
	            deHighlightButton("button_ainum_" + ii);
	        }
        } else if (buttonName.search("sound") != -1) {
            deHighlightButton("button_sound_" + Context.SOUND_ALL_STRING);
            deHighlightButton("button_sound_" + Context.SOUND_SFX_STRING);
            deHighlightButton("button_sound_" + Context.SOUND_NONE_STRING);
        }
        
        var button :SimpleButton = embedGraphics[buttonName];
        button.transform.colorTransform = new ColorTransform(1.6,1.6,1.5,1,0,0,0,0);
    }
    
    /**
     * Remove coloring on a button that is no longer selected.
     */
    protected function deHighlightButton (buttonName :String) :void
    {
        var button :SimpleButton = embedGraphics[buttonName];
        button.transform.colorTransform = new ColorTransform(1,1,1,1,0,0,0,0);
    }

    /**
     * Player clicked single player start on the splash screen.  Start the game in single
     * player mode.
     */
    protected function splashSingleClicked (event :MouseEvent) :void
    {
        _ctx.control.game.playerReady();
        parent.removeChild(this);
    }

    /**
     * Player clicked multiplayer start button.  Open the multiplayer lobby and close splash.
     */
    protected function splashMultiClicked (event :MouseEvent) :void
    {
        _ctx.control.local.showGameLobby(true);
        parent.removeChild(this);
    }

    /**
     * Player clicked help button on splash, open the help screen but leave splash.
     */
    protected function splashHelpClicked (event :MouseEvent) :void
    {
        if (!contains(helpScreen)) {
           addChild(helpScreen);
        }
    }

    /**
     * Player clicked the help screen; remove it from its parent.
     */
    protected static function helpScreenClicked (event :MouseEvent) :void
    {
    	if (helpScreen.parent != null) {
    		helpScreen.parent.removeChild(helpScreen);
    	}
    }

    /** Splash screen with settings displayed at start of game */
    [Embed(source="../../../rsrc/components.swf#splash")]
    protected static const SPLASH_SCREEN :Class;
    
    /** Instructions help screen */
    [Embed(source="../../../rsrc/components.swf#help")]
    protected static const HELP_SCREEN :Class;

    /** Displays a introductory splash screen overlay */
    protected var embedGraphics :Sprite;
}
}