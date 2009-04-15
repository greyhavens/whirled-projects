package vampire.quest.client {

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

        if (ClientCtx.questData.curLocation != null) {
            movedToLocation(ClientCtx.questData.curLocation);
        }
    }

    protected function setupLocButton (loc :LocationDesc) :void
    {
        registerListener(getLocButton(loc), MouseEvent.CLICK,
            function (...ignored) :void {
                ClientCtx.questData.curLocation = loc;
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
    }

    override public function get displayObject () :DisplayObject
    {
        return _map;
    }

    protected var _map :MovieClip;
    protected var _locMarker :MovieClip;
}

}
