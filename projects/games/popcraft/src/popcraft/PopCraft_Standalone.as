package popcraft {

import com.whirled.contrib.simplegame.resource.ResourceManager;

[SWF(width="700", height="500", frameRate="30")]
public class PopCraft_Standalone extends PopCraft
{
    public function PopCraft_Standalone ()
    {
        Constants.DEBUG_LOAD_LEVELS_FROM_DISK = true;
    }

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

        rm.queueResourceLoad("swf", "prologue", { embeddedClass: SWF_PROLOGUE });
        rm.queueResourceLoad("swf", "epilogue", { embeddedClass: SWF_EPILOGUE });
        rm.queueResourceLoad("swf", "boss", { embeddedClass: SWF_BOSS });

        rm.queueResourceLoad("sound", "mus_day", { embeddedClass: MUSIC_DAY });
        rm.queueResourceLoad("sound", "mus_night", { embeddedClass: MUSIC_NIGHT });
    }

    [Embed(source="../../rsrc/mp/multiplayer.swf", mimeType="application/octet-stream")]
    protected static const SWF_MULTIPLAYER_LOBBY :Class;

    [Embed(source="../../rsrc/sp/prologue.swf", mimeType="application/octet-stream")]
    protected static const SWF_PROLOGUE :Class;
    [Embed(source="../../rsrc/sp/epilogue.swf", mimeType="application/octet-stream")]
    protected static const SWF_EPILOGUE :Class;
    [Embed(source="../../rsrc/sp/weardd.swf", mimeType="application/octet-stream")]
    protected static const SWF_BOSS :Class;

    [Embed(source="../../rsrc/audio/music/popcraft_music_day.mp3")]
    protected static const MUSIC_DAY :Class;
    [Embed(source="../../rsrc/audio/music/popcraft_music_night.mp3")]
    protected static const MUSIC_NIGHT :Class;
}

}
