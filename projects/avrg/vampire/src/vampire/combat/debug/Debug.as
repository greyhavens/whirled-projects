package vampire.combat.debug
{
import aduros.net.RemoteProvider;
import aduros.net.RemoteProxy;
import aduros.util.F;

import com.whirled.contrib.MessageDelayer;
import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.Config;
import com.whirled.contrib.simplegame.SimpleGame;

import flash.display.Sprite;

import vampire.combat.client.CombatClient;
import vampire.combat.client.CombatGameCtx;
import vampire.combat.data.ProfileData;
import vampire.combat.data.Weapon;
import vampire.combat.server.CombatServer;

[SWF(width="1000", height="600")]
public class Debug extends Sprite
{
    public function Debug()
    {

        trace("damage=" + Weapon.damage(Weapon.SWORD));

        trace(Factory.createProfile(ProfileData.get(ProfileData.BASIC_VAMPIRE)));

        //Start a SimpleGame for testing
        var gameSprite :Sprite = new Sprite();
        addChild(gameSprite);
        var config :Config = new Config();
        config.hostSprite = gameSprite;
        var game :SimpleGame = new SimpleGame(config);
        var mode :AppMode = new AppMode();
        game.ctx.mainLoop.pushMode(mode);
        game.run();


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
        var ctx1 :CombatGameCtx = Factory.createBasicCtx();
        ctx1.init(1);
        var client :CombatClient = new CombatClient(game, mode, ctx1, gameServiceClient);
        //Plug the client into Bruno's nifty msg/proxy/magic
        new RemoteProvider(msgDelayer.clientDispatcher, "game", F.konst(ctx1.controller));

        //Test method
        gameServiceClient.doThing(2);
    }

}
}