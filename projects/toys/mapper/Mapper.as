package {

import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Matrix;
import flash.net.URLLoader;
import flash.net.URLRequest;

import com.yahoo.maps.api.YahooMap; 
import com.yahoo.maps.api.core.location.LatLon; 
import com.yahoo.maps.api.markers.SimpleMarker; 
import com.yahoo.maps.api.YahooMapEvent; 
import com.yahoo.maps.api.core.location.Address; 
import com.yahoo.maps.webservices.geocoder.GeocoderResult; 
import com.yahoo.maps.webservices.geocoder.events.GeocoderEvent; 

import com.threerings.util.Command;
import com.threerings.flash.FrameSprite;

import com.whirled.ControlEvent;
import com.whirled.EntityControl;
import com.whirled.ToyControl;

[SWF(width="500", height="375")]
public class Mapper extends FrameSprite
{
    public function Mapper ()
    {
        _map = new YahooMap();
        _map.addEventListener(YahooMapEvent.MAP_INITIALIZE, onMapInit);
        _map.init("iC3An9vV34GpX3xR3_n5L9o1ijOfAcsem_ORhjb7GmZ0Xi9FWRvunZ0jP5kB", 500, 375);
        _map.addCrosshair();
        _map.addTypeWidget();
        _map.addZoomWidget();

        // Ungh, this tries to poke the Stage
        //_map.addPanControl();

        _map.addEventListener(MouseEvent.MOUSE_DOWN, startPan);

        addChild(_map);
    }

    /**
     * No scaling. Yes, people can just check "Disable perspective" in the editor but since
     * this toy has UI that never looks right scaled, let's force this. Ideally it should scale
     * _map.mapWidth/Height to scale the map without resizing the UI, but it looks like Yahoo
     * made those attributes readonly.
     */
    override protected function handleFrame (... _) :void
    {
        var matrix :Matrix = this.transform.concatenatedMatrix;
        _map.scaleX = 1 / matrix.a;
        _map.scaleY = 1 / matrix.d;
    }

    protected function startPan (event :MouseEvent) :void
    {
        _pan = new Point(event.stageX, event.stageY);

        _map.addEventListener(MouseEvent.MOUSE_UP, stopPan);
        _map.addEventListener(MouseEvent.ROLL_OUT, stopPan);
    }

    protected function stopPan (event :MouseEvent) :void
    {
        _map.removeEventListener(MouseEvent.MOUSE_UP, stopPan);
        _map.removeEventListener(MouseEvent.ROLL_OUT, stopPan);
        _map.setCenterByPixels(new Point(event.stageX-_pan.x, event.stageY-_pan.y));
    }

    // Handy dandy
    protected function getMemberName (memberId :int) :String
    {
        for each (var id :String in _ctrl.getEntityIds()) {
            if (_ctrl.getEntityProperty(EntityControl.PROP_MEMBER_ID, id) == memberId) {
                return _ctrl.getEntityProperty(EntityControl.PROP_NAME, id) as String;
            }
        }

        throw new Error("Couldn't find name for memberId=" + memberId);
    }

    protected function onMapInit (event :YahooMapEvent) :void
    {
        _ctrl = new ToyControl(this);
        _ctrl.addEventListener(ControlEvent.MEMORY_CHANGED, onMemory);

        var mem :Object = _ctrl.getMemories();
        for (var i :String in _ctrl.getMemories()) {
            trace(i);
            updateMarker(int(i), mem[i]);
        }

        if (_ctrl.getInstanceId() != 0) {
            // Add/update our position on the map
            fetchLocation(function (lat :Number, lon :Number) :void {
                var memberId :int = _ctrl.getInstanceId();
                var memberName :String = getMemberName(memberId);
                _ctrl.setMemory(String(memberId), [memberName, lat, lon]);
            });
        }

        _map.zoomLevel = 14; // ???
        _map.centerLatLon = new LatLon(0, 0);
    } 

    /** Request use of the geo-IP location service. */
    protected function fetchLocation(callback :Function) :void
    {
        var loader :URLLoader = new URLLoader();
        Command.bind(loader, Event.COMPLETE, function () :void {
            var xml :XML = new XML(loader.data);
            callback(xml.latitude, xml.longitude);
        });

        loader.load(new URLRequest("http://iploc.mwudka.com/iploc/xml"));
    }

    protected function onMemory (event :ControlEvent) :void
    {
        var entry :Array = event.value as Array;
        updateMarker(int(event.name), entry);

        _map.panToLatLon(new LatLon(entry[1], entry[2]));
    }

    protected function updateMarker (memberId :int, entry :Array) :void
    {
        // Remove this member's previous markers
        for each (var m :PlayerMarker in _map.markerManager.markers) {
            if (m.memberId == memberId) {
                _map.markerManager.removeMarker(m);
            }
        }

        var marker :PlayerMarker = new PlayerMarker(memberId, entry[0]);
        marker.latlon = new LatLon(entry[1], entry[2]);
        //marker.buttonMode = true;

        _map.markerManager.addMarker(marker);
    }

    /** The point we started dragging. */
    protected var _pan :Point;

    protected var _ctrl :ToyControl;
    protected var _map :YahooMap;
}
}
