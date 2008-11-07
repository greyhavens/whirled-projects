package joingame.net
{
    import flash.utils.ByteArray;
    
    public class ModelConfirmMessage extends JoinGameMessage
    {
        public function ModelConfirmMessage(playerId:int = -1, model :Array = null)
        {
            super(playerId);
            _model = model;
        }
        
        override public function get name () :String
        {
           return NAME;     
        }
        
        override public function fromBytes (bytes :ByteArray) :void
        {
            super.fromBytes(bytes);
            _model = bytes.readObject() as Array;
        }
        
        override public function toBytes (bytes :ByteArray = null) :ByteArray
        {
            var bytes :ByteArray = super.toBytes(bytes);
            bytes.writeObject(_model);
            return bytes;
        }
        
        
        public function get model () :Array
        { 
            return _model; 
        }
        
        protected var _model :Array;
        
        public static const NAME :String = "Server:Model Confirm";
        
    }
}