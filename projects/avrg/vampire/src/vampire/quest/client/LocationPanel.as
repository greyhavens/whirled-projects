package vampire.quest.client {

import com.threerings.flash.SimpleTextButton;
import com.threerings.util.HashMap;
import com.whirled.contrib.ColorMatrix;
import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.resource.SwfResource;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.events.MouseEvent;
import flash.geom.Point;
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
        registerListener(btnClose, MouseEvent.CLICK,
            function (...ignored) :void {
                QuestClient.hideDockedPanel(false);
            });

        for (var ii :int = 0; ii < loc.activities.length; ++ii) {
            var activity :ActivityDesc = loc.activities[ii];
            var isAvailable :Boolean =
                !(activity.requiresUnlock) || ClientCtx.questData.isActivityUnlocked(activity);
            var button :MovieClip = createActivityButton(activity, isAvailable);
            var pt :Point = (ii < BUTTON_LOCS.length ? BUTTON_LOCS[ii] : new Point(0, 0));
            button.x = pt.x;
            button.y = pt.y;
            _panelMovie.addChild(button);

            _activityButtons.put(activity.id, button);
        }

        registerListener(ClientCtx.questData, ActivityEvent.ACTIVITY_ADDED, onActivityAdded);
    }

    public function get loc () :LocationDesc
    {
        return _loc;
    }

    protected function createActivityButton (activity :ActivityDesc, enabled :Boolean) :MovieClip
    {
        var siteMovie :MovieClip = ClientCtx.instantiateMovieClip("quest", "location");

        var buttonName :String;
        switch (activity.type) {
        case ActivityDesc.TYPE_NPC_TALK:
            buttonName = "site_lilith";
            break;

        case ActivityDesc.TYPE_FEEDING:
        default:
            buttonName = "site_pandora";
            break;
        }

        var button :SimpleButton = ClientCtx.instantiateButton("quest", buttonName);
        var buttonAttach :MovieClip = siteMovie["site_button"];
        buttonAttach.addChild(button);

        registerListener(button, MouseEvent.CLICK,
            function (...ignored) :void {
                QuestClient.beginActivity(activity);
            });

        if (enabled) {
            button.mouseEnabled = true;
            siteMovie.filters = [];
        } else {
            button.mouseEnabled = false;
            siteMovie.filters = [ new ColorMatrix().makeGrayscale().createFilter() ];
        }

        var tfName :TextField = siteMovie["site_name"];
        tfName.text = activity.displayName;
        var tfCost :TextField = siteMovie["action_cost"];
        tfCost.visible = (enabled && activity.juiceCost > 0);
        tfCost.text = (activity.juiceCost > 0 ? String(activity.juiceCost) : "");

        return siteMovie;
    }

    protected function onActivityAdded (e :ActivityEvent) :void
    {
        var buttonMovie :MovieClip = _activityButtons.get(e.activity.id) as MovieClip;
        if (buttonMovie != null) {
            buttonMovie.filters = [];

            var button :SimpleButton = buttonMovie["site_button"];
            button.mouseEnabled = true;

            var tfCost :TextField = buttonMovie["action_cost"];
            tfCost.visible = (tfCost.text.length > 0);
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
    protected var _activityButtons :HashMap = new HashMap(); // Map<activityId:int, buttonMovie>

    protected static const BUTTON_LOCS :Array = [
        new Point(106, 158), new Point(393, 88), new Point(290, 213), new Point(175, 93),
        new Point(374, 182), new Point(267, 100), new Point(205, 201),
    ];
}
}
