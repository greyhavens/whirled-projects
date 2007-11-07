//
// $Id$
//
// weatherbox - a piece of furni for Whirled

package {

import flash.display.Sprite;

import flash.events.Event;
import flash.events.MouseEvent;

import flash.text.TextField;

import fl.data.DataProvider;
import fl.containers.ScrollPane;
import fl.controls.Button;

import com.bogocorp.weather.NOAAWeatherService;

import com.threerings.util.Config;

import com.whirled.FurniControl;
import com.whirled.ControlEvent;

/**
 * weatherbox is the coolest piece of Furni ever.
 */
[SWF(width="250", height="95")]
public class weatherbox extends Sprite
{
    public static const WIDTH :int = 250;
    public static const HEIGHT :int = 95;

    public function weatherbox ()
    {
        // listen for an unload event
        root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

        // instantiate and wire up our controls and configs
        _svc = new NOAAWeatherService();
        _config = new Config("weatherbox");
        _control = new FurniControl(this);
        _control.addEventListener(ControlEvent.MEMORY_CHANGED, handleMemoryChanged);

        setupUI();

        loadWeather(getStationURL(), true);
    }

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
        _timeLabel = addTextField(0, 75);

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
     * Called to configure our station and state.
     */
    public function configure (state :String, stationId :String) :void
    {
        if (stationId == _stationId) {
            return; // no change
        }

        _state = state;
        setConfigs("state", _state);
        _stationId = stationId;
        setConfigs("station_id", _stationId);
        _stationURL = (_stationId == null) ? null : _svc.getStationURL(_stationId);
        setConfigs("station_url", _stationURL);
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
        return getFromConfigs("station_id", _stationId);
    }

    public function getState () :String
    {
        return getFromConfigs("state", _state);
    }

    public function getStationURL () :String
    {
        return getFromConfigs("station_url", _stationURL);
    }

    protected function getFromConfigs (key :String, defval :String) :String
    {
        var value :String;
        if (_control.isConnected()) {
            value = _control.lookupMemory(key) as String;
            if (value != null) {
                return value;
            }
        }

        return _config.getValue(key, defval) as String;
    }

    protected function setConfigs (key :String, value :String) :void
    {
        if (_control.isConnected()) {
            _control.updateMemory(key, value);
        }
        _config.setValue(key, value);
    }

    protected function addTextField (x :int, y :int) :TextField
    {
        var tf :TextField = new TextField();
        tf.selectable = false;
        tf.width = 200;
        tf.x = x;
        tf.y = y;
        addChild(tf);
        return tf;
    }

    protected function loadWeather (stationURL :String, informLoading :Boolean = false) :void
    {
        if (stationURL != null) {
            _svc.getWeather(stationURL, gotWeatherData);

            if (informLoading) {
                _iconArea.source = null;
                _weatherLabel.text = "";
                _locationLabel.text = "";
                _tempLabel.text = "";
                _windLabel.text = "";
                _timeLabel.text = "Retrieving weather...";
            }

        } else {
            _weatherLabel.text = "Click the configure button to configure!";
        }
    }

    protected function gotWeatherData (data :XML) :void
    {
        _iconArea.source = String(data.icon_url_base) + data.icon_url_name;
        addChild(_iconArea);

        _weatherLabel.text = data.weather;
        _locationLabel.text = data.location;
        _tempLabel.text = data.temperature_string;
        _windLabel.text = "Wind: " + data.wind_string;
        _timeLabel.text = data.observation_time;

        //trace("weather: " + data);
    }

    protected function handleConfigClicked (event :MouseEvent) :void
    {
        if (_cfgPanel != null) {
            closeConfigPanel();
            return;
        }

        var connected :Boolean = _control.isConnected();
        _cfgPanel = new ConfigPanel(this, _svc, connected);
        if (connected) {
            _control.showPopup("Configure weather", _cfgPanel, _cfgPanel.width, _cfgPanel.height);

        } else {
            addChild(_cfgPanel);
        }
    }

    protected function handleMemoryChanged (event :ControlEvent) :void
    {
        if (event.name == "station_url") {
            // only show the new weather if we aren't already showing this station
            var newURL :String = event.value as String;
            if (_stationURL != newURL) {
                _stationURL = newURL;
                _state = _control.lookupMemory("state", null) as String;
                _stationId = _control.lookupMemory("station_id", null) as String;
                loadWeather(_stationURL);
            }
        }
    }

    /**
     * This is called when your furni is unloaded.
     */
    protected function handleUnload (event :Event) :void
    {
        // stop any sounds, clean up any resources that need it.  This specifically includes 
        // unregistering listeners to any events - especially Event.ENTER_FRAME
    }

    protected var _state :String = null;
    protected var _stationId :String = null;
    protected var _stationURL :String = null;

    protected var _iconArea :ScrollPane;
    protected var _weatherLabel :TextField;
    protected var _locationLabel :TextField;
    protected var _tempLabel :TextField;
    protected var _windLabel :TextField;
    protected var _timeLabel :TextField;

    protected var _configButton :Button;

    protected var _control :FurniControl;
    protected var _config :Config;
    protected var _svc :NOAAWeatherService;

    protected var _cfgPanel :ConfigPanel;
}
}
