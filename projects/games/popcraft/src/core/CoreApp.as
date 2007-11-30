package core {
	
import flash.display.Sprite;
import flash.events.TimerEvent;
import flash.utils.Timer;

import com.threerings.util.Assert;

public class CoreApp extends Sprite
{
	public function CoreApp ()
	{
	}
	
	public function get topMode () :AppMode
	{
		if(_modeStack.length == 0)
			return null;
		else
			return ((_modeStack[_modeStack.length - 1]) as AppMode);
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
		Assert.isTrue(null != mode);
		createModeTransition(mode, TRANSITION_PUSH);
	}
	
	public function popMode () :void
	{
		createModeTransition(null, TRANSITION_POP);
	}
	
	public function changeMode (mode :AppMode) :void
	{
		Assert.isTrue(null != mode);
		createModeTransition(mode, TRANSITION_CHANGE);
	}
	
	public function unwindToMode (mode :AppMode) :void
	{
		Assert.isTrue(null != mode);
		createModeTransition(mode, TRANSITION_UNWIND);
	}
	
	protected function createModeTransition (mode :AppMode, transitionType :uint) :void
	{
		var modeTransition :Object = new Object();
		modeTransition.mode = mode;
		modeTransition.transitionType = transitionType;
		_pendingModeTransitionQueue.push(modeTransition);
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
		// process mode transitions
		var topMode :AppMode = this.topMode;
		
		// TODO: finish this
		/*for each(var transition :* in _pendingModeTransitionQueue) {
			var type :uint = transition.transitionType as uint;
			var mode :AppMode = transition.mode as AppMode;
			
			switch(type) {
			case TRANSITION_PUSH:
				if(null != topMode) {
					topMode.exit();
					topMode = null;
				}
				
				mode.setup();
				_modeStack.push(mode);
				break;
				
			case TRANSITION_POP: {
				if(null != topMode) {
					topMode.exit();
					topMode = null;
				}
				
				Assert.isTrue(null != curTop);
				curTop.exit
			}
				
			}
			
		}*/
		var newTime :Number = new Date().getTime();
		var dt :Number = newTime - _lastTime;
		
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