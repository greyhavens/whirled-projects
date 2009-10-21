package vampire.combat.client
{
import aduros.net.RemoteProxy;

import com.threerings.flashbang.AppMode;
import com.threerings.flashbang.FlashbangApp;
import com.threerings.flashbang.GameObject;
import com.threerings.util.ClassUtil;
import com.threerings.util.Log;
import com.whirled.contrib.GameMode;
import com.whirled.contrib.GameModeStack;

import flash.display.Graphics;
import flash.display.Sprite;


public class CombatClient extends GameObject
{
    public function CombatClient(game :FlashbangApp, mode :AppMode, clientContext :GameInstance,
        gameService :RemoteProxy)
    {
        _game = clientContext;
        _game.game = game;
        _game.mode = mode;
        _game.mode.addObject(this);
        clientContext.client = this;
//        _ctx.rsrcs = _ctx.game.ctx.rsrcs;
//        ClientCtx.rsrcs = _ctx.game.ctx.rsrcs;
//        _ctx.baseLayer = new Sprite();
//        mode.modeSprite.addChild(_ctx.baseLayer);

        //Panel setup.  All created sceneobjects go here so they will be cleaned up
        _game.panel = new CombatPanel(_game);
        _game.mode.addSceneObject(_game.panel, mode.modeSprite);
        //Controller setup
        _game.controller = new CombatController(_game.panel.displayObject, _game, gameService);

        // load resources
//        ClientCtx.rsrcs.queueResourceLoad("swf", "blood", { embeddedClass: SWF_BLOOD });
//        ClientCtx.rsrcs.queueResourceLoad("image", "vamp1", { embeddedClass: IMG_VAMP1 });
//        ClientCtx.rsrcs.queueResourceLoad("image", "vamp2", { embeddedClass: IMG_VAMP2 });
//        ClientCtx.rsrcs.loadQueuedResources(
//            function () :void {
//                _resourcesLoaded = true;
//                maybeFinishInit();
//            },
//            onResourceLoadErr);

        _resourcesLoaded = true;
        maybeFinishInit();
    }

    override protected function update (dt:Number) :void
    {
        if (popModeOnUpdate) {
            popModeOnUpdate = false;
            trace("popping " + ClassUtil.tinyClassName(_game.modeStack.top()));
            _game.modeStack.pop();
        }
    }

    public function shutdown () :void
    {
        _game.panel.destroySelf();
//        DisplayUtil.detach(_ctx.baseLayer);
    }

    protected function onResourceLoadErr (err :String) :void
    {
    }

    protected function maybeFinishInit () :void
    {
        _game.targetReticle = new Sprite();
        var g :Graphics = _game.targetReticle.graphics;
        g.lineStyle(4, 0xff0000, 0.9);
        g.drawCircle(0, 0, 20);



        _game.locationHandler = new LocationHandler(_game);
        //Create a mode stack for cycling through game modes
        _game.modeStack = new GameModeStack(modeChangedCallback);
//        _ctx.mode.modeSprite.addChild(_ctx.baseLayer);
        _modeCycle = new ModeCycle(_game.modeStack);

        _game.modeStack.push(new ModeInitCombat(_game));
        _game.modeStack.pop();
        //Add the modes to a continuously running cycle
        _modeCycle.active = true;
        _game.modeStack.clear();
        var cycleStartMode :GameMode = _modeCycle.addMode(new ModeAIChooseActions(_game));
        _modeCycle.addMode(new ModePlayerChooseActions(_game));
        _modeCycle.addMode(new ModeResolveCombat(_game));

        _game.modeStack.push(cycleStartMode);
        //Now activate the modecycle
//        _modeCycle.active = true;
        _game.panel.modeLabel.text = ClassUtil.tinyClassName(_game.modeStack.top());




    }

    protected function beginRound () :void
    {

    }

    protected function modeChangedCallback (oldMode :GameMode, newMode :GameMode) :void
    {
        _modeCycle.modeChangedCallback(oldMode, newMode);
    }

    protected var _modeCycle :ModeCycle;

    protected var _game :GameInstance;
    protected var _inited :Boolean;
    protected var _resourcesLoaded :Boolean;
//    protected var _unitDisplays :HashMap = new HashMap();
    protected static var log :Log = Log.getLog(CombatClient);

    public var popModeOnUpdate :Boolean = false;


}
}
