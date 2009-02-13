package framework
{
    import flash.utils.Dictionary;
    
    public class FakeAVRGContext
    {
        public static var playerId :int = 1;
        public static var players :int = 2;
        public static var roomProps :Dictionary = new Dictionary();
        public static var msg :MessageManager = new MessageManager();

    }
}