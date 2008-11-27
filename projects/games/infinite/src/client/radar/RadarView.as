package client.radar
{
    import client.player.Player;
    import client.player.PlayerEvent;
    
    import flash.display.Sprite;

    public class RadarView extends Sprite
    {
        public function RadarView(radar:Radar)
        {         
            super();
            _radar = radar;
            _radar.addEventListener(PlayerEvent.RADAR_UPDATE, handleRadarUpdate);
            _radar.addEventListener(PlayerEvent.CHANGED_LEVEL, handleLevelChanged);
        }
 
        /**
         * A player has changed level.  Check whether we're tracking that player and stop if they
         * have moved off the level of the local player.
         */
        protected function handleLevelChanged (event:PlayerEvent) :void
        {
        	// do nothing if we don't know about a local player, or we aren't tracking anyone
        	// yet.
        	if (_localPlayer == null || _tracking == null) {
        		return;
        	}        
        	
        	// if the player who changed level is the local player, then
        	// we should stop tracking them
        	if (event.player == _localPlayer) {
        		stopTracking();
        		return;
        	}
        	
        	// if the player we are tracking has changed level to a different level from the local
        	// player, then stop tracking them.
        	if (_tracking != null && _tracking.player == event.player 
        	       && event.player.levelNumber != _localPlayer.levelNumber) {
        		stopTracking();
        	}
        }
 
        protected function handleRadarUpdate (event:PlayerEvent) :void
        {
        	Log.debug("radar view received update");        	
            if (_localPlayer == null) {
            	Log.debug("radar view local player not set");
                return;
            }
            
            // The view is already tracking one of the players but not the one to whom the event
            // refers, so we shut down the existing tracking line.  
            if (_tracking != null && _tracking.player != event.player) {
            	stopTracking();
            }
            
            // Add the tracking line for the player referred to by the event.
            if (_tracking == null) {
            	Log.debug("radar view tracking player "+event.player);
                _tracking = new RadarLine(event.player, _localPlayer);
                _tracking.startTracking();
                
                addChild(_tracking);
                _tracking.x = 0;
                _tracking.y = 0;
                
                Log.debug("adding the tracking line: "+_tracking+" at "+_tracking.x+", "+_tracking.y);
                
            } else {
            	Log.debug("radar is already tracking player +"+event.player);
            }
        }
        
        protected function stopTracking () :void
        {
            Log.debug("shutting down existing view");
            _tracking.stopTracking();
            removeChild(_tracking);
            _tracking = null;        	
        }
        
        public function set localPlayer (player:Player) :void
        {
            _localPlayer = player;
        }
        
        protected var _localPlayer:Player; 
        protected var _radar:Radar;
        protected var _tracking:RadarLine;        
    }
}