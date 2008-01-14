package popcraft
{
    public class ResourceType
    {
        public function ResourceType (name :String, color :uint, relativeWeight :Number)
        {
            _name = name;
            _color = color;
            _relativeWeight = relativeWeight;
        }

        public function get color () :uint
        {
            return _color;
        }

        public function get name () :String
        {
            return _name;
        }

        public function get relativeWeight () :Number
        {
            return _relativeWeight;
        }

        protected var _color :uint;
        protected var _name :String;
        protected var _relativeWeight :Number;
    }
}
