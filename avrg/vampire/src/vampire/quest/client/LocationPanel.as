package vampire.quest.client {

import com.threerings.display.ColorMatrix;
import com.threerings.flashbang.objects.SceneObject;
import com.threerings.ui.SimpleTextButton;
import com.threerings.util.Map;
import com.threerings.util.Maps;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.text.TextField;

import vampire.quest.*;
import vampire.quest.activity.*;

public class LocationPanel extends SceneObject
{
    public function LocationPanel (loc :LocationDesc)
    {
        _loc = loc;

        _panelMovie = ClientCtx.instantiateMovieClip("quest", "location_panel");
        var contents :MovieClip = _panelMovie["draggable"];
        var tfName :TextField = contents["location_title"];
        tfName.text = loc.displayName;

        var btnClose :SimpleButton = _panelMovie["close"];
        var self :LocationPanel = this;
        registerListener(btnClose, MouseEvent.CLICK,
            function (...ignored) :void {
                ClientCtx.dockSprite.hideDockedPanel(self, false);
            });

        for (var ii :int = 0; ii < loc.activities.length; ++ii) {
            var activity :ActivityDesc = loc.activities[ii];
            var isAvailable :Boolean =
                !(activity.requiresUnlock) || ClientCtx.questData.isActivityUnlocked(activity);
            var buttonMovie :MovieClip = contents[activity.iconName];
            initActivityButton(buttonMovie, activity, isAvailable);
            _activityButtons.put(activity.id, buttonMovie);
        }

        registerListener(ClientCtx.questData, ActivityEvent.ACTIVITY_ADDED, onActivityAdded);
    }

    public function get loc () :LocationDesc
    {
        return _loc;
    }

    protected function initActivityButton (buttonMovie :MovieClip, activity :ActivityDesc,
        enabled :Boolean) :void
    {
        var button :SimpleButton = buttonMovie["site_button"];
        registerListener(button, MouseEvent.CLICK,
            function (...ignored) :void {
                QuestClient.beginActivity(activity);
            });

        if (enabled) {
            button.mouseEnabled = true;
            buttonMovie.filters = [];
        } else {
            button.mouseEnabled = false;
            buttonMovie.filters = [ new ColorMatrix().makeGrayscale().createFilter() ];
        }
    }

    protected function onActivityAdded (e :ActivityEvent) :void
    {
        var buttonMovie :MovieClip = _activityButtons.get(e.activity.id) as MovieClip;
        if (buttonMovie != null) {
            buttonMovie.filters = [];

            var button :SimpleButton = buttonMovie["site_button"];
            button.mouseEnabled = true;
        }
    }

    protected function makeActivityButton (activity :ActivityDesc) :SimpleButton
    {
        var btn :SimpleButton = new SimpleTextButton(activity.displayName);
        registerListener(btn, MouseEvent.CLICK,
            function (...ignored) :void {
                QuestClient.beginActivity(activity);
            });
        return btn;
    }

    override public function get displayObject () :DisplayObject
    {
        return _panelMovie;
    }

    protected var _loc :LocationDesc;

    protected var _panelMovie :MovieClip;
    protected var _activityButtons :Map = Maps.newMapOf(int); // Map<activityId:int, buttonMovie>
}
}
