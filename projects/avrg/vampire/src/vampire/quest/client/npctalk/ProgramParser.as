package vampire.quest.client.npctalk {

public class ProgramParser
{
    public static function parse (xml :XML) :Program
    {
        var program :Program = new Program();

        for each (var xmlRoutine :XML in xml.Routine) {
            program.addRoutine(parseRoutine(xmlRoutine));
        }

        if (!program.hasRoutine("main")) {
            throw new XmlReadError("Programs must have a 'main' routine");
        }

        return program;
    }

    protected static function parseRoutine (xml :XML) :Routine
    {
        return new Routine(
            XmlReader.getStringAttr(xml, "name"),
            parseSerialStatement(xml));
    }

    protected static function parseStatement (xml :XML) :Statement
    {
        var type :String = xml.name().localName;
        switch (type) {
        case "Block":
            return parseSerialStatement(xml);

        case "Conditional":
            return parseConditionalStatement(xml);

        case "Say":
            return parseSayStatement(xml);

        default:
            throw new XmlReadError("Unrecognized statement type '" + type + "'");
        }
    }

    protected static function parseSerialStatement (xml :XML) :SerialStatement
    {
        var statement :SerialStatement = new SerialStatement();
        for each (var xmlChild :XML in xml.children()) {
            statement.addStatement(parseStatement(xmlChild));
        }

        return statement;
    }

    protected static function parseConditionalStatement (xml :XML) :ConditionalStatement
    {
        // TODO
        return null;
    }

    protected static function parseSayStatement (xml :XML) :SayStatement
    {
        return new SayStatement(
            XmlReader.getStringAttr(xml, "speaker"),
            XmlReader.getStringAttr(xml, "text"));
    }
}

}
