package vampire.quest.client {

import com.whirled.contrib.simplegame.SimObjectRef;
import com.whirled.contrib.simplegame.objects.DraggableObject;
import com.whirled.contrib.simplegame.objects.SceneObject;
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
import vampire.quest.activity.NpcTalkActivityParams;
import vampire.quest.client.npctalk.Program;

public class QuestPanel extends DraggableObject
{
    public function QuestPanel ()
    {
        _sprite = new Sprite();
        _dockedPanelLayer = new Sprite();
        _sprite.addChild(_dockedPanelLayer);

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
            [ "quest_name", "quest_description", "quest_progress" ],
            _panelMovie["button_up"],
            _panelMovie["button_down"]);

        updateQuests();
        updateQuestJuice();
    }

    public function showLocationPanel (loc :LocationDesc) :void
    {
        var locPanel :SceneObject;
        var curPanel :SceneObject = this.dockedPanel;
        if (curPanel is LocationPanel && LocationPanel(curPanel).loc == loc) {
            locPanel = curPanel;

        } else {
            locPanel = new LocationPanel(loc);
            locPanel.visible = false;
            locPanel.x = (_panelMovie.width - locPanel.width) * 0.5;
            ClientCtx.appMode.addSceneObject(locPanel, _dockedPanelLayer);
            _lastLoc = loc;
        }

        dockPanel(locPanel);
    }

    public function showNpcTalkPanel (program :Program, params :NpcTalkActivityParams) :void
    {
        var newPanel :NpcTalkPanel = new NpcTalkPanel(program, params);
        newPanel.visible = false;
        newPanel.x = (_panelMovie.width - newPanel.width) * 0.5;
        ClientCtx.appMode.addSceneObject(newPanel, _dockedPanelLayer);

        dockPanel(newPanel);
    }

    public function hideDockedPanel (destroy :Boolean) :void
    {
        var curPanel :SceneObject = this.dockedPanel;
        if (curPanel != null) {
            hidePanel(curPanel, 0, true, destroy);
        }
    }

    public function debugForceDisplayUpdate () :void
    {
        updateQuestJuice();
        updateQuests();
    }

    public function get lastDisplayedLocation () :LocationDesc
    {
        return _lastLoc;
    }

    protected function dockPanel (panel :SceneObject) :void
    {
        var curPanel :SceneObject = this.dockedPanel;
        if (curPanel == panel) {
            if (!curPanel.visible) {
                showPanel(curPanel, 0);
            }
            return;
        }

        var totalTime :Number = showPanel(panel, 0);
        if (curPanel != null) {
            hidePanel(curPanel, totalTime, false, true);
        }

        this.dockedPanel = panel;
    }

    protected function set dockedPanel (panel :SceneObject) :void
    {
        _dockedPanelRef = panel.ref;
    }

    protected function get dockedPanel () :SceneObject
    {
        return (_dockedPanelRef.isLive ? _dockedPanelRef.object as SceneObject : null);
    }

    protected function showPanel (panel :SceneObject, delay :Number) :Number
    {
        var totalTime :Number = 0;

        if (!panel.visible) {
            var task :SerialTask = new SerialTask();
            if (delay > 0) {
                task.addTask(new TimedTask(delay));
                totalTime += delay;
            }

            task.addTask(new VisibleTask(true));
            task.addTask(new LocationTask(panel.x, _panelMovie.height - panel.height));
            task.addTask(new FunctionTask(function () :void {
                // Add a scroll rect so that the top of the docked panel doesn't appear behind
                // the location panel while it slides down into place
                _dockedPanelLayer.scrollRect = new Rectangle(
                    0, 0,
                    _panelMovie.width,
                    _panelMovie.height + panel.height);
            }));

            task.addTask(LocationTask.CreateEaseOut(panel.x, _panelMovie.height,
                PANEL_SLIDE_TIME));
            panel.addNamedTask("ShowHide", task, true);

            totalTime += PANEL_SLIDE_TIME;
        }

        return totalTime;
    }

    protected function hidePanel (panel :SceneObject, delay :Number, animate :Boolean,
        destroy :Boolean) :Number
    {
        var totalTime :Number = 0;
        if (panel.visible) {
            panel.y = _panelMovie.height;

            var task :SerialTask = new SerialTask();
            if (delay > 0) {
                task.addTask(new TimedTask(delay));
                totalTime += delay;
            }

            if (animate) {
                task.addTask(LocationTask.CreateEaseOut(
                    panel.x,
                    _panelMovie.height - panel.height,
                    PANEL_SLIDE_TIME));
                totalTime += PANEL_SLIDE_TIME;
            }

            task.addTask(destroy ? new SelfDestructTask() : new VisibleTask(false));

            panel.addNamedTask("ShowHide", task, true);

        } else if (destroy) {
            panel.destroySelf();
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
        if (_dockedPanelRef.isLive) {
            _dockedPanelRef.object.destroySelf();
        }

        super.removedFromDB();
    }

    protected function updateQuests () :void
    {
        var listData :Array = [];
        for each (var quest :QuestDesc in ClientCtx.questData.activeQuests) {
            var entry :Object = {};
            entry["quest_name"] = quest.displayName;
            entry["quest_description"] = quest.description;
            entry["quest_progress"] = quest.getProgressText(ClientCtx.questProps);

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
    protected var _dockedPanelLayer :Sprite;
    protected var _panelMovie :MovieClip;
    protected var _draggable :MovieClip;
    protected var _questList :SimpleListController;
    protected var _lastLoc :LocationDesc;

    protected var _dockedPanelRef :SimObjectRef = SimObjectRef.Null();

    protected static const PANEL_SLIDE_TIME :Number = 0.5;
}

}
