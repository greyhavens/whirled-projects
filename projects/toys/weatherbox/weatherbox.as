//
// $Id$
//
// WeatherBox - a piece of furni for Whirled

package {

import flash.display.Sprite;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;

import flash.text.TextField;

import flash.utils.Timer;

import fl.data.DataProvider;
import fl.containers.ScrollPane;
import fl.controls.Button;

import fl.skins.DefaultButtonSkins;
import fl.skins.DefaultScrollPaneSkins;

import com.bogocorp.weather.NOAAWeatherService;

import com.threerings.util.Config;
import com.threerings.util.StringUtil;

import com.whirled.FurniControl;
import com.whirled.ControlEvent;

/**
 * WeatherBox is a 'toy' that displays weather data for a configured station.
 */
[SWF(width="250", height="95")]
public class WeatherBox extends Sprite
{
    public static const WIDTH :int = 250;
    public static const HEIGHT :int = 95;

    // static references to skin classes
    DefaultScrollPaneSkins;
    DefaultButtonSkins;

    public function WeatherBox ()
    {
        // instantiate and wire up our controls and configs
        _svc = new NOAAWeatherService();
        _config = new Config("WeatherBox");
        _control = new FurniControl(this);
        _control.addEventListener(ControlEvent.MEMORY_CHANGED, handleMemoryChanged);

        _timer = new Timer(1, 1);
        _timer.addEventListener(TimerEvent.TIMER, handleTimerExpired);

        // listen for an unload event
        root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

        setupUI();

        _altLoc = getAltLocation();
        loadWeather(getStationURL(), true);
    }

    /**
     * Build the user interface.
     */
    protected function setupUI () :void
    {
        // draw our background
        graphics.beginFill(0xFFFFFF, .75);
        graphics.drawRect(0, 0, WIDTH, HEIGHT);

        _iconArea = new ScrollPane();
        _iconArea.y = 17;
        _iconArea.width = 55;
        _iconArea.height = 58;
        addChild(_iconArea);

        _locationLabel = addTextField(0, 0);
        _weatherLabel = addTextField(60, 15);
        _tempLabel = addTextField(60, 30);
        _windLabel = addTextField(60, 45);
        _statusLabel = addTextField(0, 75);

        trace("StatusLabel.width: " + _statusLabel.width);
        _statusLabel.scaleX = .5;
        trace("StatusLabel.width: " + _statusLabel.width);

        // if we're in-whirled, only show the config button to room editors
        var showConfigButton :Boolean = !_control.isConnected() || _control.canEditRoom();
        if (showConfigButton) {
            _configButton = new Button();
            _configButton.label = "Config";
            _configButton.addEventListener(MouseEvent.CLICK, handleConfigClicked);
            _configButton.x = 199;
            _configButton.y = 70;
            _configButton.setSize(50, 22);
            addChild(_configButton);
        }
    }

    /**
     * Helper method for building the UI.
     */
    protected function addTextField (x :int, y :int) :TextField
    {
        var tf :TextField = new TextField();
        tf.selectable = false;
        tf.width = WIDTH - x;
        tf.x = x;
        tf.y = y;
        addChild(tf);
        return tf;
    }

    /**
     * Called to configure our station and state.
     */
    public function configure (state :String, stationId :String, altLocation :String) :void
    {
        var altLocWasUsed :Boolean = (_altLoc != null)
        _altLoc = StringUtil.isBlank(altLocation) ? null : altLocation;
        setConfigs(ALT_LOC_KEY, _altLoc);
        if (_altLoc != null) {
            _locationLabel.text = _altLoc;
        }

        if (stationId == _stationId) {
            if (altLocWasUsed && _altLoc == null) {
                // we need to reset the location label
                loadWeather(_stationURL, true);
            }
            return; // no change
        }

        _state = state;
        setConfigs(STATE_KEY, _state);
        _stationId = stationId;
        setConfigs(STATION_ID_KEY, _stationId);
        _stationURL = (_stationId == null) ? null : _svc.getStationURL(_stationId);
        setConfigs(STATION_URL_KEY, _stationURL);
        loadWeather(_stationURL, true);
    }

    /**
     * May be called to close the config panel without updating the configured values.
     */
    public function closeConfigPanel () :void
    {
        if (_cfgPanel == null) {
            return;
        }
        if (_control.isConnected()) {
            _control.clearPopup();

        } else {
            removeChild(_cfgPanel);
        }
        _cfgPanel = null;
    }

    /**
     * Return the configured station id.
     */
    public function getStation () :String
    {
        return getFromConfigs(STATION_ID_KEY, _stationId);
    }

    /**
     * Return the configured state.
     */
    public function getState () :String
    {
        return getFromConfigs(STATE_KEY, _state);
    }

    /**
     * Return the configured url for retrieving weather data.
     */
    public function getStationURL () :String
    {
        return getFromConfigs(STATION_URL_KEY, _stationURL);
    }

    /**
     * Return the alternate location to display.
     */
    public function getAltLocation () :String
    {
        var s :String = getFromConfigs(ALT_LOC_KEY, _altLoc);
        return (s == null) ? "" : s;
    }

    /**
     * Helper method to retrieve a configured value.
     */
    protected function getFromConfigs (key :String, defval :String) :String
    {
        if (_control.isConnected()) {
            var value :String = _control.getMemory(key) as String;
            return (value != null) ? value : defval;

        } else {
            return _config.getValue(key, defval) as String;
        }
    }

    /**
     * Store a configured value.
     */
    protected function setConfigs (key :String, value :String) :void
    {
        if (_control.isConnected()) {
            _control.setMemory(key, value);

        } else {
            _config.setValue(key, value);
        }
    }

    /**
     * Load weather data from the specified stationURL.
     */
    protected function loadWeather (stationURL :String, informLoading :Boolean = false) :void
    {
        if (stationURL != null) {
            if (informLoading) {
                _iconArea.source = null;
                _weatherLabel.text = "";
                _locationLabel.text = "";
                _tempLabel.text = "";
                _windLabel.text = "";
                _statusLabel.text = "Retrieving weather...";
            }
            _timer.stop();
            _svc.getWeather(stationURL, gotWeatherData);

        } else {
            _statusLabel.text = "Click the configure button to configure!";
        }
    }

    /**
     * A callback called when weather data is received.
     */
    protected function gotWeatherData (data :XML) :void
    {
        // if we hear back asynchronously, make sure we care
        if (_unloaded) {
            return;
        }

        //trace("weather: " + data);

        _iconArea.source = String(data.icon_url_base) + data.icon_url_name;
        addChild(_iconArea);

        _weatherLabel.text = data.weather;
        _locationLabel.text = StringUtil.isBlank(_altLoc) ? data.location : _altLoc;
        _tempLabel.text = data.temperature_string;
        _windLabel.text = "Wind: " + data.wind_string;
        _statusLabel.text = data.observation_time;

        _timer.delay = computeNextPickup(data);
        _timer.reset();
        _timer.start();
    }

    /**
     * Compute the time until the next pickup for the specified weather data.
     *
     * @return a delay, in milliseconds.
     */
    protected function computeNextPickup (data :XML) :int
    {
        var suggested :String = String(data.suggested_pickup);

        // see if it matches a pattern we see all the time
        var afterHour :RegExp = /(\d+) minutes after the hour/i;
        var result :Object = afterHour.exec(suggested);
        if (result != null) {
            var pickupMinutes :int = int(result[1]);
            var now :Date = new Date();
            if (now.minutes < pickupMinutes) {
                // if the pickupMinutes is 15 and the current time is 10mins40secs,
                // we want to schedule the pickup for 4 minutes and 20 seconds
                return ((((pickupMinutes - 1) - now.minutes) * 60) + (60 - now.seconds)) * 1000;

            } else {
                // if the pickupMinutes is 15 and the current time is 30mins20secs,
                // we want to schedule the pickup for 44 minutes and 40 seconds
                return (((pickupMinutes + (59 - now.minutes)) * 60) + (60 - now.seconds)) * 1000;
            }
        }

        // otherwise just check again in 30 minutes.
        return 30 * 60 * 1000;
    }

    /**
     * Handle a click on the config button.
     */
    protected function handleConfigClicked (event :MouseEvent) :void
    {
        if (_cfgPanel != null) {
            closeConfigPanel();
            return;
        }

        _timer.stop();
        var connected :Boolean = _control.isConnected();
        _cfgPanel = new ConfigPanel(this, _svc, connected);
        if (connected) {
            _control.showPopup("Configure weather", _cfgPanel, _cfgPanel.width, _cfgPanel.height);

        } else {
            addChild(_cfgPanel);
        }
    }

    /**
     * Handle a memory change in-whirled.
     */
    protected function handleMemoryChanged (event :ControlEvent) :void
    {
        if (event.name == STATION_URL_KEY) {
            // only show the new weather if we aren't already showing this station
            var newURL :String = event.value as String;
            if (_stationURL != newURL) {
                _stationURL = newURL;
                _state = _control.getMemory(STATE_KEY, null) as String;
                _stationId = _control.getMemory(STATION_ID_KEY, null) as String;
                loadWeather(_stationURL);
            }
        }
    }

    /**
     * Handle our refresh timer expiring.
     */
    protected function handleTimerExpired (event :TimerEvent) :void
    {
        loadWeather(getStationURL());
    }

    /**
     * This is called when the toy is unloaded.
     */
    protected function handleUnload (event :Event) :void
    {
        _timer.stop();
        _unloaded = true;
    }

    protected var _state :String = null;
    protected var _stationId :String = null;
    protected var _stationURL :String = null;
    protected var _altLoc :String = null;

    protected var _iconArea :ScrollPane;
    protected var _weatherLabel :TextField;
    protected var _locationLabel :TextField;
    protected var _tempLabel :TextField;
    protected var _windLabel :TextField;
    protected var _statusLabel :TextField;

    protected var _configButton :Button;

    protected var _control :FurniControl;
    protected var _config :Config;
    protected var _svc :NOAAWeatherService;

    protected var _timer :Timer;

    /** Tracks whether we've been unloaded. */
    protected var _unloaded :Boolean = false;

    protected var _cfgPanel :ConfigPanel;

    protected static const STATE_KEY :String = "state";
    protected static const STATION_ID_KEY :String = "station_id";
    protected static const STATION_URL_KEY :String = "station_url";
    protected static const ALT_LOC_KEY :String = "loc";
}
}
