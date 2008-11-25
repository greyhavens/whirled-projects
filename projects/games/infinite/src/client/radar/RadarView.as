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
        }
 
        protected function handleRadarUpdate (event:PlayerEvent) :void
        {
        	Log.debug("radar view received update");        	
            if (_localPlayer == null) {
            	Log.debug("radar view local player not set");
                return;
            }
            
            if (_tracking != null && _tracking.player != event.player) {
            	Log.debug("shutting down existing view");
                _tracking.stopTracking();
                removeChild(_tracking);
                _tracking = null;
            }
            
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
        
        public function set localPlayer (player:Player) :void
        {
            _localPlayer = player;
        }
        
        protected var _localPlayer:Player; 
        protected var _radar:Radar;
        protected var _tracking:RadarLine;        
    }
}