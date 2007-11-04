//
// $Id$
//
// weatherbox - a piece of furni for Whirled

package {

import flash.display.Sprite;

import flash.events.Event;
import flash.events.TimerEvent;

import flash.text.TextField;

import fl.data.DataProvider;
import fl.containers.ScrollPane;
import fl.controls.ComboBox;

import com.bogocorp.weather.NOAAWeatherService;

import com.threerings.util.Config;

import com.whirled.FurniControl;
import com.whirled.ControlEvent;

/**
 * weatherbox is the coolest piece of Furni ever.
 */
[SWF(width="250", height="130")]
public class weatherbox extends Sprite
{
    public function weatherbox ()
    {
        // listen for an unload event
        root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

        // instantiate and wire up our control
        _control = new FurniControl(this);

        init();
    }

    protected function init () :void
    {
        _stateBox = new ComboBox();
        _stateBox.addEventListener(Event.CHANGE, handleStatePicked);
        addChild(_stateBox);
        _stationBox = new ComboBox();
        _stationBox.enabled = false;
        _stationBox.addEventListener(Event.CHANGE, handleStationPicked);
        _stationBox.width = 200;
        _stationBox.y = 25;
        addChild(_stationBox);

        _iconArea = new ScrollPane();
        _iconArea.y = 50;
        _iconArea.width = 55;
        _iconArea.height = 58;
        addChild(_iconArea);

        _weatherLabel = addTextField(60, 50);
        _locationLabel = addTextField(60, 65);
        _tempLabel = addTextField(60, 80);
        _windLabel = addTextField(60, 95);
        _timeLabel = addTextField(0, 110);

        _svc = new NOAAWeatherService();
        _svc.getDirectory(directoryReceived);

        _config = new Config("weatherbox");
    }

    protected function addTextField (x :int, y :int) :TextField
    {
        var tf :TextField = new TextField();
        tf.width = 200;
        tf.x = x;
        tf.y = y;
        addChild(tf);
        return tf;
    }

    protected function directoryReceived () :void
    {
        var states :Array = _svc.getStates();
        _stateBox.dataProvider = new DataProvider(states);

        var state :String = _config.getValue("state", null) as String;
        if (state != null) {
            for each (var o :Object in states) {
                if (o.label == state) {
                    _stateBox.selectedItem = o;
                    handleStatePicked(null);
                    break;
                }
            }
        }
    }

    protected function handleStatePicked (event :Event) :void
    {
        var state :String = String(_stateBox.selectedItem.label);
        _config.setValue("state", state);

        var stations :Array = _svc.getStations(state);
        _stationBox.dataProvider = new DataProvider(stations);
        _stationBox.enabled = true;

        if (_autoPick) {
            var station :String = _config.getValue("station_id", null) as String;
            if (station != null) {
                for each (var o :Object in stations) {
                    if (o.station == station) {
                        _stationBox.selectedItem = o;
                        handleStationPicked(null);
                        break;
                    }
                }
            }
        }
    }

    protected function handleStationPicked (event :Event) :void
    {
        var station :Object = _stationBox.selectedItem;
        _config.setValue("station_id", station.station);
        _autoPick = false;

        _svc.getWeather(station.station, gotWeatherData);
    }

    protected function gotWeatherData (data :XML) :void
    {
        _iconArea.source = String(data.icon_url_base) + data.icon_url_name;
        addChild(_iconArea);

        _weatherLabel.text = data.weather;
        _locationLabel.text = data.location;
        _tempLabel.text = data.temperature_string;
        _windLabel.text = data.wind_string;
        _timeLabel.text = data.observation_time;

        //trace("weather: " + data);
    }

    /**
     * This is called when your furni is unloaded.
     */
    protected function handleUnload (event :Event) :void
    {
        // stop any sounds, clean up any resources that need it.  This specifically includes 
        // unregistering listeners to any events - especially Event.ENTER_FRAME
    }

    protected var _stateBox :ComboBox;
    protected var _stationBox :ComboBox;

    protected var _iconArea :ScrollPane;

    protected var _weatherLabel :TextField;
    protected var _locationLabel :TextField;
    protected var _tempLabel :TextField;
    protected var _windLabel :TextField;
    protected var _timeLabel :TextField;

    protected var _control :FurniControl;

    protected var _svc :NOAAWeatherService;

    protected var _autoPick :Boolean = true;

    protected var _config :Config;
}
}
