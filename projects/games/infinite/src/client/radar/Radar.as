package client.radar
{
    import arithmetic.Vector;
    
    import client.player.Player;
    import client.player.PlayerEvent;
    
    import flash.events.EventDispatcher;
    import flash.utils.Dictionary;
    
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

        public function handleChangedLevel(event:PlayerEvent) :void
        {
            if (_player == null) {
                return;
            }
            
            announce("player "+event.player.name+" has moved to level "+event.player.levelNumber);
        }
        
        public function handlePathComplete(event:PlayerEvent) :void
        {
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
                directionChanged(event.player, current);
            }
        }
        
        protected function directionChanged (player:Player, direction:Vector) :void
        {
            announce("direction of "+player.name+" changed to "+direction);
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