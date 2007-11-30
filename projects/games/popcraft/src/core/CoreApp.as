package core {
	
import flash.display.Sprite;
import flash.events.TimerEvent;
import flash.utils.Timer;

public class CoreApp extends Sprite
{
	public function CoreApp ()
	{
	}
	
	public function run () :void
	{
		var appSettings :CoreAppSettings = this.applicationSettings;
		
		// convert fps to update interval
		var updateInterval :Number = 1000.0 / Number(appSettings.frameRate);
		
		_mainTimer = new Timer(updateInterval, 0);
		_mainTimer.addEventListener(TimerEvent.TIMER, update);
		_mainTimer.start();
		
		_lastTime = new Date().getTime();
	}
	
	public function pushMode (mode :AppMode) :void
	{
		
	}
	
	public function get applicationSettings () :CoreAppSettings
	{
		if(null == g_defaultAppSettings) {
			g_defaultAppSettings = new CoreAppSettings();
		}
			
		return g_defaultAppSettings;
	}
	
	protected function update (e:TimerEvent) :void
	{
		var newTime :Number = new Date().getTime();
		var dt :Number = newTime - _lastTime;
		
		trace(dt);
		
		_lastTime = newTime;
	}
	
	protected static var g_defaultAppSettings :CoreAppSettings;
	
	protected var _mainTimer :Timer;
	protected var _lastTime :Number;
	protected var _modeStack :Array = new Array();
	protected var _pendingModeTransitionQueue :Array = new Array();
	
	// mode transition constants
	internal static const TRANSITION_PUSH :uint = 0;
	internal static const TRANSITION_POP :uint = 1;
	internal static const TRANSITION_CHANGE :uint = 2;
	internal static const TRANSITION_UNWIND :uint = 3; 
}

}