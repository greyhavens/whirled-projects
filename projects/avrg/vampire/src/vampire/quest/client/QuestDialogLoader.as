package vampire.quest.client {

import com.whirled.contrib.simplegame.resource.ResourceManager;

public class QuestDialogLoader
{
    public static function loadQuestDialogs (onComplete :Function = null, onError :Function = null,
        fromDisk :Boolean = false) :void
    {
        var rm :ResourceManager = ClientCtx.rsrcs;
        for each (var desc :QuestDialogDesc in DESCS) {
            var loadParams :Object = {};
            if (fromDisk) {
                loadParams["url"] = "../../../../rsrc/quest/" + desc.filename;
            } else {
                loadParams["embeddedClass"] = desc.clazz;
            }

            rm.unload(desc.resourceName);
            rm.queueResourceLoad("npcTalk", desc.resourceName, loadParams);
        }

        rm.loadQueuedResources(onComplete, onError);
    }

    [Embed(source="../../../../rsrc/quest/LilithDialog.xml", mimeType="application/octet-stream")]
    protected static const LILITH_DIALOG :Class;

    protected static const DESCS :Array = [
        new QuestDialogDesc("LilithDialog.xml", LILITH_DIALOG),
    ];
}

}
