package popcraft {

import com.whirled.contrib.simplegame.resource.ResourceManager;

[SWF(width="700", height="500", frameRate="30")]
public class PopCraft_Standalone extends PopCraft
{
    override public function loadResources (completeCallback :Function, errorCallback :Function) :void
    {
        queueLevelPackResources();
        super.loadResources(completeCallback, errorCallback);
    }

    /**
     * Queues resources that are normally loaded from level packs. This is purely a debug
     * convenience, to make it possible to test the game in the standalone flash player.
     */
    protected function queueLevelPackResources () :void
    {
        var rm :ResourceManager = ResourceManager.instance;

        rm.queueResourceLoad("swf", "multiplayer_lobby", { embeddedClass: SWF_MULTIPLAYER_LOBBY });
        rm.queueResourceLoad("image", "zombieBg", { embeddedClass: IMG_ZOMBIE_BG });

        rm.queueResourceLoad("swf", "prologue", { embeddedClass: SWF_PROLOGUE });
        rm.queueResourceLoad("swf", "epilogue", { embeddedClass: SWF_EPILOGUE });
        rm.queueResourceLoad("swf", "manual", { embeddedClass: SWF_MANUAL });
        rm.queueResourceLoad("swf", "boss", { embeddedClass: SWF_BOSS });
        rm.queueResourceLoad("image", "levelSelectOverlay", { embeddedClass: IMG_LEVEL_SELECT_OVERLAY });
        rm.queueResourceLoad("swf", "levelSelectUi", { embeddedClass: SWF_LEVEL_SELECT_UI });
        rm.queueResourceLoad("image", "portrait_iris", { embeddedClass: IMG_IRIS });
        rm.queueResourceLoad("image", "portrait_ivy", { embeddedClass: IMG_IVY });
        rm.queueResourceLoad("image", "portrait_jack", { embeddedClass: IMG_JACK });
        rm.queueResourceLoad("image", "portrait_pigsley", { embeddedClass: IMG_PIGSLEY });
        rm.queueResourceLoad("image", "portrait_ralph", { embeddedClass: IMG_RALPH });
        rm.queueResourceLoad("image", "portrait_weardd", { embeddedClass: IMG_WEARDD });

        rm.queueResourceLoad("sound", "mus_day", { embeddedClass: MUSIC_DAY });
        rm.queueResourceLoad("sound", "mus_night", { embeddedClass: MUSIC_NIGHT });
    }

    [Embed(source="../../rsrc/mp/multiplayer.swf", mimeType="application/octet-stream")]
    protected static const SWF_MULTIPLAYER_LOBBY :Class;
    [Embed(source="../../rsrc/mp/zombie_BG.jpg", mimeType="application/octet-stream")]
    protected static const IMG_ZOMBIE_BG :Class;

    [Embed(source="../../rsrc/sp/prologue.swf", mimeType="application/octet-stream")]
    protected static const SWF_PROLOGUE :Class;
    [Embed(source="../../rsrc/sp/epilogue.swf", mimeType="application/octet-stream")]
    protected static const SWF_EPILOGUE :Class;
    [Embed(source="../../rsrc/sp/manual.swf", mimeType="application/octet-stream")]
    protected static const SWF_MANUAL :Class;
    [Embed(source="../../rsrc/sp/weardd.swf", mimeType="application/octet-stream")]
    protected static const SWF_BOSS :Class;
    [Embed(source="../../rsrc/sp/splash.png", mimeType="application/octet-stream")]
    protected static const IMG_LEVEL_SELECT_OVERLAY :Class;
    [Embed(source="../../rsrc/sp/splash_UI.swf", mimeType="application/octet-stream")]
    protected static const SWF_LEVEL_SELECT_UI :Class;
    [Embed(source="../../rsrc/sp/iris.png", mimeType="application/octet-stream")]
    protected static const IMG_IRIS :Class;
    [Embed(source="../../rsrc/sp/ivy.png", mimeType="application/octet-stream")]
    protected static const IMG_IVY :Class;
    [Embed(source="../../rsrc/sp/jack.png", mimeType="application/octet-stream")]
    protected static const IMG_JACK :Class;
    [Embed(source="../../rsrc/sp/pigsley.png", mimeType="application/octet-stream")]
    protected static const IMG_PIGSLEY :Class;
    [Embed(source="../../rsrc/sp/RALPH.png", mimeType="application/octet-stream")]
    protected static const IMG_RALPH :Class;
    [Embed(source="../../rsrc/sp/weardd.png", mimeType="application/octet-stream")]
    protected static const IMG_WEARDD :Class;

    [Embed(source="../../rsrc/audio/music/popcraft_music_day.mp3")]
    protected static const MUSIC_DAY :Class;
    [Embed(source="../../rsrc/audio/music/popcraft_music_night.mp3")]
    protected static const MUSIC_NIGHT :Class;
}

}