package popcraft.util {

import com.threerings.util.StringUtil;

public class XmlReader
{
    public static function hasChild (xml :XML, name :String) :Boolean
    {
        return xml.child(name).length() > 0;
    }

    public static function getSingleChild (xml :XML, name :String, defaultValue :XML = null) :XML
    {
        var child :XML = xml.child(name)[0];
        if (null == child) {
            if (null != defaultValue) {
                return defaultValue;
            } else {
                throw new XmlReadError("In node '" + String(xml.localName()) + "': error accessing child '" + name + "': child does not exist");
            }
        }

        return child;
    }

    public static function hasAttribute (xml :XML, name :String) :Boolean
    {
        return (null != xml.attribute(name)[0]);
    }

    public static function getAttributeAsEnum (xml :XML, name :String, stringMapping :Array, defaultValue :int = undefined) :int
    {
        return getAttributeAs(xml, name, defaultValue,
            function (attrString :String) :int {
                return parseEnum(attrString, stringMapping);
            });
    }

    public static function getAttributeAsUint (xml :XML, name :String, defaultValue :uint = undefined) :uint
    {
        return getAttributeAs(xml, name, defaultValue, StringUtil.parseUnsignedInteger);
    }

    public static function getAttributeAsInt (xml :XML, name :String, defaultValue :int = undefined) :int
    {
        return getAttributeAs(xml, name, defaultValue, StringUtil.parseInteger);
    }

    public static function getAttributeAsNumber (xml :XML, name :String, defaultValue :Number = undefined) :Number
    {
        return getAttributeAs(xml, name, defaultValue, StringUtil.parseNumber);
    }

    public static function getAttributeAsBoolean (xml :XML, name :String, defaultValue :Boolean = undefined) :Boolean
    {
        return getAttributeAs(xml, name, defaultValue, StringUtil.parseBoolean);
    }

    public static function getAttributeAsString (xml :XML, name :String, defaultValue :String = undefined) :String
    {
        return getAttributeAs(xml, name, defaultValue);
    }

    public static function getAttributeAs (xml :XML, name :String, defaultValue :*, parseFunction :Function = null) :*
    {
        var value :*;

        // read the attribute; throw an error if it doesn't exist (unless we have a default value)
        var attr :XML = xml.attribute(name)[0];
        if (null == attr) {
            if (undefined !== defaultValue) {
                return defaultValue;
            } else {
                throw new XmlReadError("In node '" + String(xml.localName()) + "': error reading attribute '" + name + "': attribute does not exist");
            }
        }

        // try to parse the attribute
        try {
            value = (null != parseFunction ? parseFunction(attr) : attr);
        } catch (e :ArgumentError) {
            throw new XmlReadError("In node '" + String(xml.localName()) + "': error reading attribute '" + name + "': " + e.message);
        }

        return value;
    }

    protected static function parseEnum (stringVal :String, stringMapping :Array) :int
    {
        var value :int;
        var foundValue :Boolean;

        // try to map the attribute value to one of the Strings in stringMapping
        for (var ii :int = 0; ii < stringMapping.length; ++ii) {
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
