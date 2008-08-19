package {

import com.threerings.util.StringUtil;

public class Parameter
{
    public static const OPTIONAL :int = 1;
    public static const NULLABLE :int = 2;

    public static function isDigit (char :String) :Boolean
    {
        return "0123456789".indexOf(char) >= 0;
    }

    public static function isAlpha (char :String) :Boolean
    {
        return "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_".indexOf(char) >= 0;
    }

    public static function isWhitespace (char :String) :Boolean
    {
        return StringUtil.isWhitespace(char);
    }

    public static function trim (str :String) :String
    {
        return StringUtil.trim(str);
    }

    public function Parameter (
        name :String, 
        type :Class, 
        flags :uint=0)
    {
        _name = name;
        _type = type;
        _flags = flags;
    }

    public function get name () :String
    {
        return _name;
    }
    
    public function get type () :Class
    {
        return _type;
    }

    public function get typeDisplay () :String
    {
        if (_type == String) {
            return "String";

        } else if (_type == int) {
            return "int";
        }

        return "" + _type;
    }

    public function parse (input :String) :Object
    {
        if (_type == String) {
            return input;

        } else if (_type == int) {
            return StringUtil.parseInteger(input);
        } else if (_type == Boolean) {
            input = input.toLowerCase();
            if (input == "t" || input == "true") {
                return true;
            } else if (input == "f" || input == "false") {
                return false;
            } else {
                throw new Error(input + " is not a Boolean");
            }
        }

        throw new Error("Parsing for parameter type " + type + 
            " not implemented");
    }

    public function get optional () :Boolean
    {
        return (_flags & OPTIONAL) != 0;
    }

    public function get nullable () :Boolean
    {
        return (_flags & NULLABLE) != 0;
    }

    protected var _name :String;
    protected var _type :Class;
    protected var _flags :uint;
}

}
