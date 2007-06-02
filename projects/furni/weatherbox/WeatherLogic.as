package {

import flash.events.Event;

import mx.containers.HBox;
import mx.controls.ComboBox;

import com.threerings.util.Config;

import com.bogocorp.weather.NOAAWeatherService;

/**
 * Application logic for WeatherBox.
 */
public class WeatherLogic
{
    /**
     * Init- called by the UI after it is ready to go.
     */
    public function init (box :WeatherBox) :void
    {
        _box = box;

        _box.stateBox.addEventListener(Event.CHANGE, handleStatePicked);
        _box.stationBox.addEventListener(Event.CHANGE, handleStationPicked);

        _svc = new NOAAWeatherService();
        _svc.getDirectory(directoryReceived);

        _config = new Config("weatherbox");
    }

    protected function directoryReceived () :void
    {
        _box.stateBox.dataProvider = _svc.getStates();

        var state :String = _config.getValue("state", null) as String;
        if (state != null) {
            _box.stateBox.selectedItem = state;
            handleStatePicked(null); // FUCKING HELL, this shouldn't be necessary
        }
    }

    protected function handleStatePicked (event :Event) :void
    {
        var state :String = String(_box.stateBox.selectedItem);
        _config.setValue("state", state);

        var stations :Array = _svc.getStations(state);
        _box.stationBox.dataProvider = stations;
        _box.stationBox.enabled = true;

        if (_autoPick) {
            var station :String = _config.getValue("station_id", null) as String;
            if (station != null) {
                for each (var o :Object in stations) {
                    if (o.station == station) {
                        _box.stationBox.selectedItem = o;
                        handleStationPicked(null); // FUCKING HELL, this shouldn't be necessary
                        break;
                    }
                }
            }
        }
    }

    protected function handleStationPicked (event :Event) :void
    {
        var station :Object = _box.stationBox.selectedItem;
        _config.setValue("station_id", station.station);
        _autoPick = false;

        _svc.getWeather(station.station, gotWeatherData);
    }

    protected function gotWeatherData (data :XML) :void
    {
        _box.iconArea.source = String(data.icon_url_base) + data.icon_url_name;
        _box.weatherLabel.text = data.weather;
        _box.locationLabel.text = data.location;
        _box.tempLabel.text = data.temperature_string;
        _box.windLabel.text = "Wind: " + data.wind_string;
        _box.timestampLabel.text = data.observation_time;

        //trace("weather: " + data);
    }

    protected var _svc :NOAAWeatherService;

    protected var _box :WeatherBox;

    protected var _autoPick :Boolean = true;

    protected var _config :Config;
}
}
