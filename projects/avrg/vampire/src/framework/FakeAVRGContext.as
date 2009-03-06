package framework
{
    import flash.geom.Rectangle;
    import flash.utils.Dictionary;

    public class FakeAVRGContext
    {
        public static var playerId :int = 1;
        public static var players :int = 3;
        public static var playerIds :Array = [1, 2, 3];
        public static var entityIds :Array = ["R1:E1", "R1:E2", "R1:E3"];
        public static var roomProps :Dictionary = new Dictionary();
        public static var roomBounds :Array = [700, 500];
        public static var paintableArea :Rectangle = new Rectangle(0, 0, 750, 550);
        public static var msg :MessageManager = new MessageManager();

    }
}