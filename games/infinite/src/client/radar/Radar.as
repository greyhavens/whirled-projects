package client.radar
{
    import arithmetic.Vector;
    
    import client.player.Player;
    import client.player.PlayerEvent;
    
    import flash.events.EventDispatcher;
    import flash.utils.Dictionary;
    
    /**
     * The radar is essentially a controller.  Currently it's function is to determine which player
     * the radar should be tracking.  The algorithm is to track the player who most recently
     * switched compass position relative to the local player.  The idea is that it shouldn't change
     * too rapidly, and that if you don't see an update in the radar for a given player, that player
     * is still in the same direction you think they are.
     */ 
    public class Radar extends EventDispatcher
    {
        /**
         * Construct a new radar.  The width and height are the widths and height of the central zone.  
         * These should be set to the width and height of the viewing area in cells.
         */
        public function Radar(width:int, height:int)
        {
            _width = width / 2;
            _height = height / 2;
        }
        
        public function set player (player:Player) :void
        {
            _player = player;
        }

        public function get player () :Player
        {
        	return _player;
        }

        public function handleChangedLevel(event:PlayerEvent) :void
        {
        	// if we're not tracking a local player, then do nothing
            if (_player == null) {
                return;
            }

            // otherwise redispatch the event so the view can respond            
            dispatchEvent(event);
        }
        
        public function handlePathComplete(event:PlayerEvent) :void
        {
            // dispatch the event for views that might be interested
            dispatchEvent(event);

            if (_player == null) {
                return;
            }
                        
            if (event.player == _player) {
                return;
            }
            
            if (event.player.levelNumber != _player.levelNumber) {
                return;
            }
            
            const found:Vector = _directions[event.player];
            const current:Vector = directionTo(event.player);
            
            Log.debug("current="+current+" found="+found);
            
            if (!current.equals(found)) {
                Log.debug("directions differ triggering event");
                _directions[event.player] = current;
                directionChanged(event.player);
            }            
        }
        
        protected function directionChanged (player:Player) :void
        {
            dispatchEvent(new PlayerEvent(PlayerEvent.RADAR_UPDATE, player));
        } 
        
        protected function announce (message:String) :void
        {
            Log.debug("RADAR: "+message);
        }
        
        protected function directionTo (other:Player) :Vector
        {
            const direction:Vector = _player.position.distanceTo(other.position);
            if (Math.abs(direction.dx) < _width) {
                direction.dx = 0;
            } else {
                direction.dx = direction.dx / direction.dx;
            }
            
            if (Math.abs(direction.dy) < _height) {
                direction.dy = 0;
            } else {
                direction.dy = direction.dy / direction.dy;
            }
            return direction;
        }
  
        protected var _width:int;
        
        protected var _height:int;
 
        protected var _directions:Dictionary = new Dictionary();
        
        protected var _player:Player;
    }
}