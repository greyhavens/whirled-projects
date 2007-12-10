package popcraft
{
    public class BoardTile
    {
        public var filename: String;
        public var obstacle :Boolean;

        public function BoardTile (filename_ :String = "", obstacle_ :Boolean = false)
        {
            filename = filename_;
            obstacle = obstacle_;
        }
    }
}
