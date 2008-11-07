package joingame.net
{
    import com.whirled.game.NetSubControl;
    
    import flash.utils.ByteArray;
    
    public class AllPlayersReadyMessage extends JoinGameMessage
    {
        public function AllPlayersReadyMessage(model :Array = null)
        {
            super(NetSubControl.TO_SERVER_AGENT);
            _modelMemento = model;
        }
        
        
        override public function get name () :String
        {
           return NAME;     
        }
        
        override public function fromBytes (bytes :ByteArray) :void
        {
            super.fromBytes(bytes);
            _modelMemento = bytes.readObject() as Array;
        }
        
        override public function toBytes (bytes :ByteArray = null) :ByteArray
        {
            var bytes :ByteArray = super.toBytes(bytes);
            bytes.writeObject( _modelMemento);
            return bytes;
        }
        
        
        public function get model() :Array
        {
            return _modelMemento;
        }
        protected var _modelMemento :Array;
        
        public static const NAME :String = "Server:All Players Ready";
        
    }
}