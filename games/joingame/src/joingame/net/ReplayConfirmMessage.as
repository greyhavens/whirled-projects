package joingame.net
{
    import com.whirled.game.NetSubControl;
    
    import flash.utils.ByteArray;
    
    public class ReplayConfirmMessage extends JoinGameMessage
    {
        public function ReplayConfirmMessage( currentActivePlayers :Array = null, model :Array = null)
        {
            super(NetSubControl.TO_SERVER_AGENT);
            _currentActivePlayers = currentActivePlayers;
            _modelMemento = model;
        }
        
        override public function get name () :String
        {
           return NAME;     
        }
        
        override public function fromBytes (bytes :ByteArray) :void
        {
            super.fromBytes(bytes);
            _currentActivePlayers = bytes.readObject() as Array;
            _modelMemento = bytes.readObject() as Array;
        }
        
        override public function toBytes (bytes :ByteArray = null) :ByteArray
        {
            var bytes :ByteArray = super.toBytes(bytes);
            bytes.writeObject(_currentActivePlayers);
            bytes.writeObject(_modelMemento);
            return bytes;
        }
        
        
        
        public function get currentActivePlayers () :Array
        {
            return _currentActivePlayers;
        }
        
        public function get modelMemento () :Array
        {
            return _modelMemento;
        }
        
        protected var _currentActivePlayers :Array;
        protected var _modelMemento :Array;
        
        public static const NAME :String = "Server:Confirm Replay"; 
    }
}