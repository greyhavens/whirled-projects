package vampire.quest.client {

import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.objects.DraggableObject;
import com.whirled.contrib.simplegame.tasks.*;

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.text.TextField;

import vampire.client.SimpleListController;
import vampire.quest.*;

public class QuestPanel extends DraggableObject
{
    public function QuestPanel ()
    {
        _sprite = new Sprite();
        _locationPanelLayer = new Sprite();
        _sprite.addChild(_locationPanelLayer);

        _panelMovie = ClientCtx.instantiateMovieClip("quest", "quest_panel");
        _sprite.addChild(_panelMovie);

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
        registerListener(ClientCtx.questProps, QuestPropEvent.PROP_CHANGED,
            function (e :QuestPropEvent) :void {
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
        updateQuestJuice();
    }

    public function showLocationPanel (loc :LocationDesc) :void
    {
        var delay :Number = 0;
        if (_locationPanel == null || _locationPanel.loc != loc) {
            if (_locationPanel != null) {
                delay = hideLocationPanelInternal(true);
            }

            _locationPanel = new LocationPanel(loc);
            _locationPanel.visible = false;
            _locationPanel.x = (_panelMovie.width - _locationPanel.width) * 0.5;
            AppMode(this.db).addSceneObject(_locationPanel, _locationPanelLayer);
        }

        if (_locationPanelLayer.scrollRect == null) {
            _locationPanelLayer.scrollRect =
                new Rectangle(0, 0, _panelMovie.width, _panelMovie.height + _locationPanel.height);
        }

        if (!_locationPanel.visible) {
            _locationPanel.visible = true;
            _locationPanel.y = _panelMovie.height - _locationPanel.height;

            var task :SerialTask = new SerialTask();
            if (delay > 0) {
                task.addTask(new TimedTask(delay));
            }

            task.addTask(LocationTask.CreateEaseOut(
                _locationPanel.x,
                _panelMovie.height,
                PANEL_SLIDE_TIME));
            _locationPanel.addNamedTask("ShowHide", task, true);
        }
    }

    public function hideLocationPanel () :void
    {
        hideLocationPanelInternal(false);
    }

    protected function hideLocationPanelInternal (destroy :Boolean) :Number
    {
        var totalTime :Number = 0;

        if (_locationPanel != null) {
            if (_locationPanel.visible) {
                _locationPanel.y = _panelMovie.height;

                var task :SerialTask = new SerialTask();
                task.addTask(LocationTask.CreateEaseOut(
                    _locationPanel.x,
                    _panelMovie.height - _locationPanel.height,
                    PANEL_SLIDE_TIME));
                task.addTask(destroy ? new SelfDestructTask() : new VisibleTask(false));

                totalTime = PANEL_SLIDE_TIME;

                _locationPanel.addNamedTask("ShowHide", task, true);

            } else {
                _locationPanel.visible = false;
                if (destroy) {
                    _locationPanel.destroySelf();
                    _locationPanel = null;
                }
            }
        }

        return totalTime;
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
            entry["quest_description"] =
                quest.description + " " + quest.getProgressText(ClientCtx.questProps);

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
        return _sprite;
    }

    override protected function get draggableObject () :InteractiveObject
    {
        return _draggable;
    }

    protected var _sprite :Sprite;
    protected var _locationPanelLayer :Sprite;
    protected var _panelMovie :MovieClip;
    protected var _draggable :MovieClip;
    protected var _questList :SimpleListController;

    protected var _locationPanel :LocationPanel;

    protected static const PANEL_SLIDE_TIME :Number = 0.5;
}

}
