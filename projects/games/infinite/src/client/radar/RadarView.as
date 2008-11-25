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
            if (_localPlayer == null) {
                return;
            }
            
            if (_tracking != null && _tracking.player != event.player) {
                _tracking.stopTracking();
                removeChild(_tracking);
                _tracking = null;
            }
            
            if (_tracking == null) {
                _tracking = new RadarLine(event.player, _localPlayer);
                _tracking.startTracking();
                addChild(_tracking);
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