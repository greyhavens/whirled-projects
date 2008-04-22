package popcraft.sp {

import com.threerings.util.StringUtil;

public class XmlReader
{
    public static function getAttributeAsEnum (xml :XML, name :String, stringMapping :Array, defaultValue :* = null) :uint
    {
        return getAttributeAs(xml, name, defaultValue,
            function (attrString :String) :uint {
                return parseEnum(attrString, stringMapping);
            });
    }

    public static function getAttributeAsUint (xml :XML, name :String, defaultValue :* = null) :uint
    {
        return getAttributeAs(xml, name, defaultValue, StringUtil.parseUnsignedInteger);
    }

    public static function getAttributeAsInt (xml :XML, name :String, defaultValue :* = null) :int
    {
        return getAttributeAs(xml, name, defaultValue, StringUtil.parseInteger);
    }

    public static function getAttributeAsNumber (xml :XML, name :String, defaultValue :* = null) :Number
    {
        return getAttributeAs(xml, name, defaultValue, StringUtil.parseNumber);
    }

    public static function getAttributeAsBoolean (xml :XML, name :String, defaultValue :* = null) :Boolean
    {
        return getAttributeAs(xml, name, defaultValue, StringUtil.parseBoolean);
    }

    public static function getAttributeAsString (xml :XML, name :String, defaultValue :String = null) :String
    {
        return getAttributeAs(xml, name, defaultValue);
    }

    public static function getAttributeAs (xml :XML, name :String, defaultValue :*, parseFunction :Function = null) :*
    {
        var value :*;

        var required :Boolean = (null == defaultValue);

        try {
            var attrVal :String = getAttribute(xml, name);
            value = (null != parseFunction ? parseFunction(attrVal) : attrVal);

        } catch (e :ArgumentError) {
            if (required) {
                throw new XmlReadError("Error reading attribute '" + name + "': " + e.message);
            } else {
                value = defaultValue;
            }
        }

        return value;
    }

    protected static function getAttribute (xml :XML, name :String) :String
    {
        var attr :XMLList = xml.attribute(name);
        if (attr.length() == 0) {
            throw new ArgumentError("attribute does not exist");
        }

        return attr[0];
    }

    protected static function parseEnum (stringVal :String, stringMapping :Array) :uint
    {
        var value :uint;
        var foundValue :Boolean;

        // try to map the attribute value to one of the Strings in stringMapping
        for (var ii :uint = 0; ii < stringMapping.length; ++ii) {
            if (String(stringMapping[ii]) == stringVal) {
                value = ii;
                foundValue = true;
                break;
            }
        }

        if (!foundValue) {
            // we couldn't perform the mapping - generate an appropriate error string
            var errString :String = "could not convert '" + stringVal + "' to the correct value (must be one of: ";
            for (ii = 0; ii < stringMapping.length; ++ii) {
                errString += String(stringMapping[ii]);
                if (ii < stringMapping.length - 1) {
                    errString += ", ";
                }
            }
            errString += ")";

            throw new ArgumentError(errString);
        }

        return value;
    }
}

}
