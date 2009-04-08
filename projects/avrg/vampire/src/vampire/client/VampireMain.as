package vampire.client {
import com.threerings.util.Log;
import com.whirled.avrg.AVRGameControl;
import com.whirled.contrib.EventHandlers;
import com.whirled.contrib.simplegame.Config;
import com.whirled.contrib.simplegame.SimpleGame;
import com.whirled.contrib.simplegame.resource.ResourceManager;

import flash.display.Sprite;
import flash.events.Event;

import vampire.data.VConstants;

[SWF(width="700", height="500")]
public class VampireMain extends Sprite
{
    public function VampireMain()
    {
        addEventListener(Event.ADDED_TO_STAGE, handleAdded);
        addEventListener(Event.REMOVED_FROM_STAGE, handleUnload);


        // instantiate MainLoop singleton, and load its resources.
        var gameSprite :Sprite = new Sprite();
        addChild(gameSprite);
        var config :Config = new Config();
        config.hostSprite = gameSprite;
        ClientContext.game = new SimpleGame(config);

        loadResources();
    }

    protected function loadResources () :void
    {
        var rm :ResourceManager = ClientContext.game.ctx.rsrcs;

        rm.queueResourceLoad("swf",   "HUD",         { embeddedClass: SWF_HUD });

        rm.loadQueuedResources(
            function () :void {
                _resourcesLoaded = true;
                maybeStartGame();
            },
            function (err :String) :void {
                log.error("Error loading resources: " + err);
            });
    }


    protected function maybeStartGame () :void
    {
        if (_addedToStage && _resourcesLoaded) {

            if(ClientContext.ctrl == null) {
                ClientContext.init(new AVRGameControl(this));
            }

            if(!ClientContext.ctrl.isConnected() && !VConstants.LOCAL_DEBUG_MODE) {
                log.error("Not connected and not test model");
                return;
            }

            //Init the controller with the root sprite.
            ClientContext.controller = new VampireController(this);

            if (VConstants.LOCAL_DEBUG_MODE) {
                ClientContext.game.ctx.mainLoop.pushMode(new MainGameMode());
            }
            else {
                //The main game mode.
                ClientContext.game.ctx.mainLoop.pushMode(new MainGameMode());

                //Check that the player is wearing the right avatar.
                ClientContext.game.ctx.mainLoop.pushMode(new WearingAvatarCheckMode());

                //Give the player an avatar if they don't have one
                ClientContext.game.ctx.mainLoop.pushMode(new ChooseAvatarMode());
            }


            //Start the game.
            ClientContext.game.run();

        }
    }

    protected function handleResourcesLoaded () :void
    {
        _resourcesLoaded = true;
        maybeStartGame();
    }

    protected function handleResourceLoadError (err :String) :void
    {
        log.warning("Resource load error: " + err);
    }

    protected function handleAdded (event :Event) :void
    {
        _addedToStage = true;
        maybeStartGame();
    }

    protected function handleUnload (event :Event) :void
    {
        log.info("Removed from stage - Unloading...");

        ClientContext.game.shutdown();
        EventHandlers.freeAllHandlers();
    }

    protected var _addedToStage :Boolean = false;
    protected var _resourcesLoaded :Boolean = false;

    protected static var log :Log = Log.getLog(VampireMain);

    [Embed(source="../../../rsrc/HUD.swf", mimeType="application/octet-stream")]
    protected static const SWF_HUD :Class;

    [Embed(source="../../../rsrc/JUICE___.TTF", fontFamily="JuiceEmbedded")]
    public const JuiceEmbeddedFont:Class;

}

}