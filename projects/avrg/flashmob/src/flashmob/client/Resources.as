package flashmob.client {

import com.whirled.contrib.simplegame.resource.*;

public class Resources
{
    public static function loadResources (loadCompleteCallback :Function = null,
        loadErrorCallback :Function = null) :void
    {
        var rm :ResourceManager = ResourceManager.instance;

        rm.queueResourceLoad("swf", "Spectacle_UI",  { embeddedClass: SWF_SPECTACLE_UI });
        rm.queueResourceLoad("swf", "can_can",  { embeddedClass: SWF_CAN_CAN });

        rm.queueResourceLoad("sound", "countdown",  { embeddedClass: SOUND_COUNTDOWN });
        rm.queueResourceLoad("sound", "snare_roll",  { embeddedClass: SOUND_SNARE_ROLL });
        rm.queueResourceLoad("sound", "cymbal_hit",  { embeddedClass: SOUND_CYMBAL_HIT });
        rm.queueResourceLoad("sound", "fail",  { embeddedClass: SOUND_FAIL });
        rm.queueResourceLoad("sound", "ding",  { embeddedClass: SOUND_DING });
        rm.queueResourceLoad("sound", "main_theme",  { embeddedClass: SOUND_SPECTACULAR_UI });

        rm.loadQueuedResources(loadCompleteCallback, loadErrorCallback);
    }

    [Embed(source="../../../rsrc/Spectacle_UI.swf", mimeType="application/octet-stream")]
    protected static const SWF_SPECTACLE_UI :Class;
    [Embed(source="../../../rsrc/can_can.swf", mimeType="application/octet-stream")]
    protected static const SWF_CAN_CAN :Class;

    [Embed(source="../../../rsrc/audio/countdown.mp3")]
    protected static const SOUND_COUNTDOWN :Class;
    [Embed(source="../../../rsrc/audio/snare_roll.mp3")]
    protected static const SOUND_SNARE_ROLL :Class;
    [Embed(source="../../../rsrc/audio/cymbal_hit.mp3")]
    protected static const SOUND_CYMBAL_HIT :Class;
    [Embed(source="../../../rsrc/audio/fail.mp3")]
    protected static const SOUND_FAIL :Class;
    [Embed(source="../../../rsrc/audio/ding.mp3")]
    protected static const SOUND_DING :Class;
    [Embed(source="../../../rsrc/audio/spectacular_UI.mp3")]
    protected static const SOUND_SPECTACULAR_UI :Class;
}

}
