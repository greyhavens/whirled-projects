package vampire.fightproto {

import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.game.GameControl;
import com.whirled.game.SizeChangedEvent;

import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;

[SWF(width="700", height="500", frameRate="30")]
public class FightProto extends Sprite
{
    public function FightProto ()
    {
        ClientCtx.mainSprite = this;

        // initialize ClientCtx
        ClientCtx.gameCtrl = new GameControl(this, false);
        var isConnected :Boolean = ClientCtx.gameCtrl.isConnected();

        _events.registerListener(this, Event.REMOVED_FROM_STAGE, handleUnload);

        // draw a black background
        var g :Graphics = this.graphics;
        g.beginFill(0);
        g.drawRect(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);
        g.endFill();

        // set a clip rect
        this.scrollRect = new Rectangle(0, 0, Constants.SCREEN_SIZE.x, Constants.SCREEN_SIZE.y);

        // setup simplegame
        var config :Config = new Config();
        config.hostSprite = this;
        config.keyDispatcher = (isConnected ? ClientCtx.gameCtrl.local : this.stage);
        _sg = new SimpleGame(config);
        ClientCtx.mainLoop = _sg.ctx.mainLoop;
        ClientCtx.rsrcs = _sg.ctx.rsrcs;
        ClientCtx.audio = _sg.ctx.audio;

        // sound volume
        ClientCtx.audio.masterControls.volume(
            Constants.DEBUG_DISABLE_AUDIO ? 0 : Constants.SOUND_MASTER_VOLUME);

        if (ClientCtx.gameCtrl.isConnected()) {
            // if we're connected to Whirled, keep the game centered
            _events.registerListener(ClientCtx.gameCtrl.local, SizeChangedEvent.SIZE_CHANGED,
                handleSizeChanged)

            handleSizeChanged();
        }

        // Init game stuff
        Scenarios.init();

        // create the player
        var player :Player = new Player();
        player.level = PlayerLevel.LEVELS[0];
        player.health = 100;
        player.energy = 100;
        player.xp = 0;
        player.skills.push(PlayerSkill.BITE_1);
        player.scenarios.push(Scenarios.getScenario("intro"));
        ClientCtx.player = player;

        // Load resources
        var rm :ResourceManager = ClientCtx.rsrcs;
        rm.queueResourceLoad("image", "bite", { embeddedClass: IMG_BITE });
        rm.queueResourceLoad("image", "player", { embeddedClass: IMG_PLAYER });
        rm.queueResourceLoad("image", "werewolf", { embeddedClass: IMG_WEREWOLF });
        rm.queueResourceLoad("image", "background", { embeddedClass: IMG_BACKGROUND });
        rm.queueResourceLoad("image", "selection_arrow", { embeddedClass: IMG_SELECTION_ARROW });
        rm.queueResourceLoad("image", "heal", { embeddedClass: IMG_HEAL });
        rm.queueResourceLoad("image", "claw", { embeddedClass: IMG_CLAW });
        rm.loadQueuedResources(
            function () :void {
                ClientCtx.mainLoop.pushMode(new InterstitialMode());
            },
            function (err :String) :void {
                trace("Resource load error: " + err);
            });

        _sg.run();
    }

    protected function handleSizeChanged (...ignored) :void
    {
        var size :Point = ClientCtx.gameCtrl.local.getSize();
        ClientCtx.mainSprite.x = (size.x * 0.5) - (Constants.SCREEN_SIZE.x * 0.5);
        ClientCtx.mainSprite.y = (size.y * 0.5) - (Constants.SCREEN_SIZE.y * 0.5);
    }

    protected function handleUnload (...ignored) :void
    {
        _events.freeAllHandlers();
        _sg.shutdown();
    }

    protected var _sg :SimpleGame;
    protected var _events :EventHandlerManager = new EventHandlerManager();

    [Embed(source="../../../rsrc/fightproto/bite.png", mimeType="application/octet-stream")]
    protected static const IMG_BITE :Class;
    [Embed(source="../../../rsrc/fightproto/player.png", mimeType="application/octet-stream")]
    protected static const IMG_PLAYER :Class;
    [Embed(source="../../../rsrc/fightproto/werewolf.png", mimeType="application/octet-stream")]
    protected static const IMG_WEREWOLF :Class;
    [Embed(source="../../../rsrc/fightproto/background.png", mimeType="application/octet-stream")]
    protected static const IMG_BACKGROUND :Class;
    [Embed(source="../../../rsrc/fightproto/selection_arrow.png", mimeType="application/octet-stream")]
    protected static const IMG_SELECTION_ARROW :Class;
    [Embed(source="../../../rsrc/fightproto/heal.png", mimeType="application/octet-stream")]
    protected static const IMG_HEAL :Class;
    [Embed(source="../../../rsrc/fightproto/claw.png", mimeType="application/octet-stream")]
    protected static const IMG_CLAW :Class;
}

}
