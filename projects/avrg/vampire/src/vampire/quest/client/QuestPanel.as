package vampire.quest.client {

import com.whirled.contrib.simplegame.objects.DraggableObject;

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;

import vampire.client.SimpleListController;
import vampire.quest.*;

public class QuestPanel extends DraggableObject
{
    public function QuestPanel ()
    {
        _panelMovie = ClientCtx.instantiateMovieClip("quest", "quest_panel");
        _draggable = _panelMovie["draggable"];

        var closeBtn :SimpleButton = _panelMovie["close"];
        registerListener(closeBtn, MouseEvent.CLICK,
            function (...ignored) :void {
                QuestClient.showQuestPanel(false);
            });

        registerListener(ClientCtx.questData, PlayerJuiceEvent.QUEST_JUICE_CHANGED,
            function (e :PlayerJuiceEvent) :void {
                updateQuestJuice();
            });
        registerListener(ClientCtx.questData, PlayerQuestEvent.QUEST_ADDED,
            function (e :PlayerQuestEvent) :void {
                updateQuests();
            });
        registerListener(ClientCtx.questData, PlayerQuestEvent.QUEST_COMPLETED,
            function (e :PlayerQuestEvent) :void {
                showQuestCompleted(e.quest);
                updateQuests();
            });

        // Player list
        _questList = new SimpleListController(
            [],
            _draggable,
            "quest_",
            [ "quest_name", "quest_description" ],
            _panelMovie["button_up"],
            _panelMovie["button_down"]);

        updateQuests();
    }

    override protected function addedToDB () :void
    {
        super.addedToDB();
        this.db.addObject(_questList);
    }

    override protected function removedFromDB () :void
    {
        _questList.destroySelf();
    }

    protected function updateQuests () :void
    {
        var listData :Array = [];
        for each (var quest :QuestDesc in ClientCtx.questData.activeQuests) {
            var entry :Object = {};
            entry["quest_name"] = quest.displayName;
            entry["quest_description"] = quest.description;

            listData.push(entry);
        }

        _questList.data = listData;
    }

    protected function updateQuestJuice () :void
    {
        var tfJuice :TextField = _draggable["juice_total"];
        tfJuice.text = String(ClientCtx.questData.questJuice);
    }

    protected function showQuestCompleted (quest :QuestDesc) :void
    {

    }

    override public function get displayObject () :DisplayObject
    {
        return _panelMovie;
    }

    override protected function get draggableObject () :InteractiveObject
    {
        return _draggable;
    }

    protected var _panelMovie :MovieClip;
    protected var _draggable :MovieClip;
    protected var _questList :SimpleListController;
}

}
