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
        var children :XMLList = xml.children();
        if (children.length() == 0) {
            throw new XmlReadError("Conditionals must have an If statement");
        }

        var statement :ConditionalStatement = new ConditionalStatement();

        for (var ii :int = 0; ii < children.length(); ++ii) {
            var xmlChild :XML = children[ii];
            var name :String = xmlChild.name().localName;
            if (ii == 0 && name != "If") {
                throw new XmlReadError("An If statement must appear first in a Conditional");
            }
            if (name == "Else" && ii != children.length() - 1) {
                throw new XmlReadError("Else must be the last statement in a Conditional");
            }

            if (name == "If" || name == "ElseIf") {
                var ifChildren :XMLList = xmlChild.children();
                if (ifChildren.length() != 2) {
                    throw new XmlReadError(
                        "If and ElseIf statements must have 1 Expr and 1 statement");
                }

                statement.addIf(
                    parseExpr(ifChildren[0]),
                    parseStatement(ifChildren[1]));

            } else if (name == "Else") {
                var elseChildren :XMLList = xmlChild.children();
                if (elseChildren.length() != 1) {
                    throw new XmlReadError("Else statements must have 1 statement");
                }

                statement.setElse(parseStatement(elseChildren[0]));
            }
        }

        return statement;
    }

    protected static function parseSayStatement (xml :XML) :SayStatement
    {
        return new SayStatement(
            XmlReader.getStringAttr(xml, "speaker"),
            XmlReader.getStringAttr(xml, "text"));
    }

    protected static function parseExpr (xml :XML) :Expr
    {
        var type :String = xml.name().localName;
        switch (type) {
        case "And":
            return parseAndExpr(xml);

        case "Or":
            return parseOrExpr(xml);

        case "Value":
            return parseValueExpr(xml);

        case "Equals":
            return parseBinaryCompExpr(xml, BinaryCompExpr.EQUALS);

        case "Less":
            return parseBinaryCompExpr(xml, BinaryCompExpr.LT);

        case "LessEqual":
            return parseBinaryCompExpr(xml, BinaryCompExpr.LTE);

        case "Greater":
            return parseBinaryCompExpr(xml, BinaryCompExpr.GT);

        case "GreaterEqual":
            return parseBinaryCompExpr(xml, BinaryCompExpr.GTE);

        default:
            throw new XmlReadError("Unrecognized Expr type '" + type + "'");
        }
    }

    protected static function parseAndExpr (xml :XML) :AndExpr
    {
        var expr :AndExpr = new AndExpr();
        for each (var xmlChild :XML in xml.children()) {
            expr.addExpr(parseExpr(xmlChild));
        }
        return expr;
    }

    protected static function parseOrExpr (xml :XML) :OrExpr
    {
        var expr :OrExpr = new OrExpr();
        for each (var xmlChild :XML in xml.children()) {
            expr.addExpr(parseExpr(xmlChild));
        }
        return expr;
    }

    protected static function parseValueExpr (xml :XML) :ValueExpr
    {
        return new ValueExpr(XmlReader.getNumberAttr(xml, "val"));
    }

    protected static function parseBinaryCompExpr (xml :XML, type :int) :BinaryCompExpr
    {
        var children :XMLList = xml.children();
        if (children.length() != 2) {
            throw new XmlReadError("BinaryCompExprs must have two expression children");
        }

        return new BinaryCompExpr(parseExpr(children[0]), parseExpr(children[1]), type);
    }
}

}
