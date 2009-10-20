package vampire.combat.debug
{
import aduros.net.RemoteProvider;
import aduros.net.RemoteProxy;
import aduros.util.F;

import com.threerings.util.Log;
import com.whirled.contrib.MessageDelayer;
import com.threerings.flashbang.AppMode;
import com.threerings.flashbang.Config;
import com.threerings.flashbang.FlashbangApp;

import flash.display.Sprite;

import vampire.combat.client.ClientCtx;
import vampire.combat.client.CombatClient;
import vampire.combat.client.GameInstance;
import vampire.combat.server.CombatServer;

[SWF(width="1000", height="600")]
public class Debug extends Sprite
{
    public function Debug()
    {
        Log.setLevel("", Log.DEBUG);
//        Log.setLevel("vampire.combat.UnitRecord", Log.DEBUG);
        //Start a FlashbangApp for testing
        var gameSprite :Sprite = new Sprite();
        addChild(gameSprite);
        var config :Config = new Config();
//        config.hostSprite = gameSprite;
        var game :FlashbangApp = new FlashbangApp(config);
        var mode :AppMode = new AppMode();
        game.ctx.mainLoop.pushMode(mode);
        game.run(gameSprite);
        ClientCtx.rsrcs = game.ctx.rsrcs;

        // load resources
        ClientCtx.rsrcs.queueResourceLoad("swf", "blood", { embeddedClass: SWF_BLOOD });
//        ClientCtx.rsrcs.queueResourceLoad("image", "vamp1", { embeddedClass: IMG_VAMP1 });
//        ClientCtx.rsrcs.queueResourceLoad("image", "vamp2", { embeddedClass: IMG_VAMP2 });
        ClientCtx.rsrcs.loadQueuedResources(
            function () :void {
                begin(game, mode);
            },
            onResourceLoadErr);


    }

    protected function onResourceLoadErr (err :String) :void
    {
    }

    protected function begin (game :FlashbangApp, mode :AppMode) :void
    {
        //We can test the game with arbitrarily lag times.
        var msgDelayer :MessageDelayer = new MessageDelayer(100);

        //This lives on the server
        var gameServiceServer :RemoteProxy = new RemoteProxy(msgDelayer.serverSubControl, "game");
        //Here's the server, running locally
        var server :CombatServer = new CombatServer(gameServiceServer);
        //Plug the server into Bruno's nifty msg/proxy/magic
        new RemoteProvider(msgDelayer.serverDispatcher, "game", F.konst(server));

        //This lives on the client
        var gameServiceClient :RemoteProxy = new RemoteProxy(msgDelayer.createClientMessageSubControl(1), "game");
        //The client
        //Create a context with our playerId
        var ctx1 :GameInstance = Factory.createBasicGameData(1);
        ctx1.init(1);
        var client :CombatClient = new CombatClient(game, mode, ctx1, gameServiceClient);
        //Plug the client into Bruno's nifty msg/proxy/magic
        new RemoteProvider(msgDelayer.clientDispatcher, "game", F.konst(ctx1.controller));

        //Test method
//        gameServiceClient.doThing(2);

    }

    [Embed(source="../../../../rsrc/feeding/blood.swf", mimeType="application/octet-stream")]
    protected static const SWF_BLOOD :Class;

//    [Embed(source="../../../../tempsrc/blade_TraciLords2sm.jpg", mimeType="application/octet-stream")]
//    protected static const IMG_VAMP1 :Class;
//
//    [Embed(source="../../../../tempsrc/images.jpg", mimeType="application/octet-stream")]
//    protected static const IMG_VAMP2 :Class;

}
}
