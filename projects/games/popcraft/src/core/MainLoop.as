package core {
	
import com.threerings.util.Assert;

import flash.events.TimerEvent;
import flash.utils.Timer;
import flash.utils.getTimer;

public class MainLoop
{
	public function MainLoop ()
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
		// it's an error to call run() multiple times
		Assert.isFalse(_running);
		_running = true;
		
		var appSettings :CoreAppSettings = this.applicationSettings;
		
		// convert fps to update interval
		var updateInterval :Number = 1000.0 / Number(appSettings.frameRate);
		
		_mainTimer = new Timer(updateInterval, 0);
		_mainTimer.addEventListener(TimerEvent.TIMER, update);
		_mainTimer.start();
		
		_lastTime = getTimer();
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
		var initialTopMode :AppMode = this.topMode;
		
		function doDestroyMode (mode :AppMode) :void {
			Assert.isTrue(null != mode);
			
			// if the top mode is destroyed, make sure it's exited first
			if(mode == initialTopMode) {
				initialTopMode.exit();
				initialTopMode = null;
			}
			
			mode.destroy();
		}
		
		for each(var transition :* in _pendingModeTransitionQueue) {
			var type :uint = transition.transitionType as uint;
			var mode :AppMode = transition.mode as AppMode;
			
			switch(type) {
			case TRANSITION_PUSH:
				_modeStack.push(mode);
				mode.setup();
				break;
				
			case TRANSITION_POP:
				Assert.isTrue(_modeStack.length > 0);
				doDestroyMode(_modeStack.pop() as AppMode);
				break;
				
			case TRANSITION_CHANGE:
				// a pop followed by a push
				Assert.isTrue(_modeStack.length > 0);
				doDestroyMode(_modeStack.pop() as AppMode);
				_modeStack.push(mode);
				mode.setup();
				break;
				
			case TRANSITION_UNWIND:
				// pop modes until we find the one we're looking for
				while(_modeStack.length > 0 && this.topMode != mode) {
					doDestroyMode(_modeStack.pop() as AppMode);
				}
				
				Assert.isTrue(this.topMode == mode || _modeStack.length == 0);
				
				if(_modeStack.length == 0) {
					_modeStack.push(mode);
					mode.setup();
				}
				break;
			}
		}
		
		_pendingModeTransitionQueue = new Array();
		
		var topMode :AppMode = this.topMode;
		if(topMode != initialTopMode) {
			if(null != initialTopMode) {
				initialTopMode.exit();
			}
			
			if(null != topMode) {
				topMode.enter();
			}
		}
		
		// update the top mode
		var newTime :Number = getTimer();
		var dt :Number = newTime - _lastTime;
		if(null != topMode)
			topMode.update(dt);
		
		_lastTime = newTime;
	}
	
	protected static var g_defaultAppSettings :CoreAppSettings;
	
	protected var _running :Boolean = false;
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