package vampire.quest.client {

import flash.display.MovieClip;
import flash.display.SimpleButton;

import vampire.client.SimpleListController;
import vampire.quest.*;

public class QuestListController extends SimpleListController
{
    public function QuestListController (listParent :MovieClip,
                                         upButton:SimpleButton = null,
                                         downButton :SimpleButton = null)
    {
        super(listParent, "quest_", COLUMN_NAMES, upButton, downButton);

        // A custom handler for the quest progress bar
        addCustomColumnHandler("quest_progress_bar", progressBarHandler);

        _events.registerListener(ClientCtx.questData, PlayerQuestEvent.QUEST_ADDED,
            function (e :PlayerQuestEvent) :void {
                updateQuests();
            });
        _events.registerListener(ClientCtx.questData, PlayerQuestEvent.QUEST_COMPLETED,
            function (e :PlayerQuestEvent) :void {
                updateQuests();
            });
        _events.registerListener(ClientCtx.questProps, QuestPropEvent.PROP_CHANGED,
            function (e :QuestPropEvent) :void {
                updateQuests();
            });

        updateQuests();
    }

    protected function updateQuests () :void
    {
        var listData :Array = [];
        for each (var quest :QuestDesc in ClientCtx.questData.activeQuests) {
            var entry :Object = {};
            entry["quest_name"] = quest.displayName;
            entry["quest_description"] = quest.description;
            entry["quest_progress_text"] = quest.getProgressText(ClientCtx.questProps);
            entry["quest_progress_bar"] = quest.getProgress(ClientCtx.questProps);

            listData.push(entry);
        }

        this.data = listData;
    }

    protected static function progressBarHandler (progressBar :MovieClip, data :Object) :void
    {
        var numFrames :int = progressBar.totalFrames;
        var frame :int = (Number(data) * Number(numFrames)) + 1;
        frame = Math.max(frame, 1);
        frame = Math.min(frame, numFrames);
        progressBar.gotoAndStop(frame);
    }

    protected static const COLUMN_NAMES :Array = [
        "quest_name", "quest_description", "quest_progress_text", "quest_progress_bar"
    ];
}

}
