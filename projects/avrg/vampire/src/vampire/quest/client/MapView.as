package vampire.quest.client {

import com.whirled.contrib.simplegame.AppMode;
import com.whirled.contrib.simplegame.objects.SceneObject;

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.SimpleButton;
import flash.events.MouseEvent;

import vampire.quest.*;

public class MapView extends SceneObject
{
    public function MapView ()
    {
        _map = ClientCtx.instantiateMovieClip("map", "map");
        _locMarker = ClientCtx.instantiateMovieClip("map", "cur_loc_marker");
        _locMarker.mouseEnabled = false;
        _locMarker.mouseChildren = false;

        for each (var loc :LocationDesc in Locations.getLocationList()) {
            setupLocButton(loc);
        }

        registerListener(ClientCtx.questData, PlayerLocationEvent.LOCATION_ADDED,
            function (e :PlayerLocationEvent) :void {
                updateView();
            });
        registerListener(ClientCtx.questData, PlayerLocationEvent.MOVED_TO_LOCATION,
            function (e :PlayerLocationEvent) :void {
                movedToLocation(e.location);
            });

        updateView();
    }

    override protected function addedToDB () :void
    {
        super.addedToDB();

        if (ClientCtx.questData.curLocation != null) {
            movedToLocation(ClientCtx.questData.curLocation);
        }
    }

    protected function setupLocButton (loc :LocationDesc) :void
    {
        registerListener(getLocButton(loc), MouseEvent.CLICK,
            function (...ignored) :void {
                var cost :int = ClientCtx.questData.curLocation.getMovementCost(loc);
                if (cost >= 0 && cost <= ClientCtx.questData.questJuice) {
                    ClientCtx.questData.curLocation = loc;
                    ClientCtx.questData.questJuice -= cost;
                }
            });
    }

    protected function updateView () :void
    {
        for each (var loc :LocationDesc in Locations.getLocationList()) {
            var button :SimpleButton = getLocButton(loc);
            var available :Boolean = ClientCtx.questData.isAvailableLocation(loc);
            button.visible = available;
            for each (var connectedLoc :LocationConnection in loc.connectedLocs) {
                var connectionMovie :MovieClip = getConnectionView(loc, connectedLoc.loc);
                connectionMovie.visible =
                    (available && ClientCtx.questData.isAvailableLocation(connectedLoc.loc));
            }
        }
    }

    protected function getLocButton (loc :LocationDesc) :SimpleButton
    {
        return _map["loc_" + loc.name];
    }

    protected function getConnectionView (a :LocationDesc, b :LocationDesc) :MovieClip
    {
        var view :MovieClip = _map[a.name + "_to_" + b.name];
        if (view == null) {
            view = _map[b.name + "_to_" + a.name];
        }
        return view;
    }

    protected function movedToLocation (loc :LocationDesc) :void
    {
        if (_locMarker.parent == null) {
            _map.addChild(_locMarker);
        }

        var button :SimpleButton = getLocButton(loc);
        _locMarker.x = button.x;
        _locMarker.y = button.y;

        if (_activityView != null) {
            _activityView.destroySelf();
            _activityView = null;
        }

        _activityView = new LocationActivityView(loc);
        _activityView.x = button.x + 20;
        _activityView.y = button.y;
        (this.db as AppMode).addSceneObject(_activityView, _map);
    }

    override public function get displayObject () :DisplayObject
    {
        return _map;
    }

    protected var _map :MovieClip;
    protected var _locMarker :MovieClip;
    protected var _activityView :LocationActivityView;
}

}

import com.whirled.contrib.simplegame.objects.SceneObject;
import flash.display.Sprite;

import vampire.quest.*;
import vampire.quest.client.*;
import flash.text.TextField;
import flash.display.SimpleButton;
import com.threerings.flash.SimpleTextButton;
import flash.events.MouseEvent;
import flash.display.Graphics;
import flash.display.DisplayObject;

class LocationActivityView extends SceneObject
{
    public function LocationActivityView (loc :LocationDesc)
    {
        _loc = loc;

        var layout :Sprite = new Sprite();
        if (loc.activities.length == 0) {
            var tf :TextField = TextBits.createText("Nothing to do here.", 1.2, 0, 0xffffff);
            tf.x = -tf.width * 0.5;
            layout.addChild(tf);

        } else {
            for each (var activity :ActivityDesc in loc.activities) {
                var btn :SimpleButton = makeActivityButton(activity);
                btn.x = -btn.width * 0.5;
                btn.y = layout.height;
                layout.addChild(btn);
            }
        }

        layout.x = layout.width * 0.5;
        layout.y = 0;
        _sprite = new Sprite();
        _sprite.addChild(layout);
        var g :Graphics = _sprite.graphics;
        g.beginFill(0);
        g.drawRect(0, 0, _sprite.width, _sprite.height);
        g.endFill();
    }

    protected function makeActivityButton (activity :ActivityDesc) :SimpleButton
    {
        var btn :SimpleButton = new SimpleTextButton(activity.displayName);
        registerListener(btn, MouseEvent.CLICK,
            function (...ignored) :void {
                doActivity(activity);
            });
        return btn;
    }

    protected function doActivity (activity :ActivityDesc) :void
    {

    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _loc :LocationDesc;

    protected var _sprite :Sprite;
}
