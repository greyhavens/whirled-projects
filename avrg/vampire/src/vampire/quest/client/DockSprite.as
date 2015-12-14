package vampire.quest.client {

import com.threerings.util.Log;
import com.threerings.flashbang.GameObjectRef;
import com.threerings.flashbang.objects.SceneObject;
import com.threerings.flashbang.tasks.*;

import flash.display.Sprite;
import flash.geom.Rectangle;

import vampire.quest.*;
import vampire.quest.activity.*;
import vampire.quest.client.npctalk.*;

public class DockSprite extends Sprite
{
    public function DockSprite (width :int, height :int)
    {
        _width = width;
        _height = height;
    }

    public function showQuestPanel () :void
    {
        var locPanel :SceneObject;
        var curPanel :SceneObject = this.dockedPanel;
        if (curPanel is QuestPanel) {
            locPanel = curPanel;

        } else {
            locPanel = new QuestPanel();
            locPanel.visible = false;
            ClientCtx.appMode.addSceneObject(locPanel, this);
        }

        dockPanel(locPanel);
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
            ClientCtx.appMode.addSceneObject(locPanel, this);
            _lastLoc = loc;
        }

        dockPanel(locPanel);
    }

    public function showLastLocationPanel () :void
    {
        if (_lastLoc != null) {
            showLocationPanel(_lastLoc);
        }
    }

    public function showNpcTalkPanel (program :Program, params :NpcTalkActivityParams) :void
    {
        var newPanel :NpcTalkPanel = new NpcTalkPanel(program, params);
        newPanel.visible = false;
        ClientCtx.appMode.addSceneObject(newPanel, this);

        dockPanel(newPanel);
    }

    public function showNpcTalkDialog (params :NpcTalkActivityParams) :void
    {
        var name :String = params.dialogName;
        var rsrc :NpcTalkResource = ClientCtx.rsrcs.getResource(name) as NpcTalkResource;
        if (rsrc == null) {
            log.warning("Can't show NpcTalkPanel; no resource named '" + name + "' exists.");
            return;
        }

        showNpcTalkPanel(rsrc.program, params);
    }

    public function hideDockedPanel (panel :SceneObject, destroy :Boolean) :void
    {
        if (panel == this.dockedPanel) {
            hidePanel(panel, 0, true, destroy);
        }
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

            var self :DockSprite = this;
            task.addTask(new VisibleTask(true));
            task.addTask(new LocationTask(panel.x, -panel.height));
            task.addTask(new FunctionTask(function () :void {
                // Add a scroll rect so that the top of the docked panel doesn't appear behind
                // the location panel while it slides down into place
                self.scrollRect = new Rectangle(0, 0, _width, panel.height);
            }));

            task.addTask(LocationTask.CreateEaseOut(panel.x, 0, PANEL_SLIDE_TIME));
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
            panel.y = 0;

            var task :SerialTask = new SerialTask();
            if (delay > 0) {
                task.addTask(new TimedTask(delay));
                totalTime += delay;
            }

            if (animate) {
                task.addTask(LocationTask.CreateEaseOut(panel.x, -panel.height, PANEL_SLIDE_TIME));
                totalTime += PANEL_SLIDE_TIME;
            }

            task.addTask(destroy ? new SelfDestructTask() : new VisibleTask(false));

            panel.addNamedTask("ShowHide", task, true);

        } else if (destroy) {
            panel.destroySelf();
        }

        return totalTime;
    }

    protected var _width :int;
    protected var _height :int;
    protected var _lastLoc :LocationDesc;
    protected var _dockedPanelRef :GameObjectRef = GameObjectRef.Null();

    protected static const PANEL_SLIDE_TIME :Number = 0.5;

    protected static var log :Log = Log.getLog(DockSprite);
}

}
