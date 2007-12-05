package popcraft
{
    public class ResourceType
    {
        public function ResourceType (name :String, color :uint)
        {
            _name = name;
            _color = color;
        }

        public function get color () :uint
        {
            return _color;
        }

        public function get name () :String
        {
            return _name;
        }

        protected var _color :uint;
        protected var _name :String;
    }
}
