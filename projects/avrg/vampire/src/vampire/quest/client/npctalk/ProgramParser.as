package vampire.quest.client.npctalk {
    import vampire.quest.QuestDesc;
    import vampire.quest.Quests;


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
            parseBlockStatement(xml));
    }

    protected static function parseStatement (xml :XML) :Statement
    {
        var type :String = xml.name().localName;
        switch (type) {
        // Vampire-specific
        case "Say":
            return parseSayStatement(xml);

        case "WaitResponse":
            return parseWaitResponseStatement(xml);

        case "HandleResponse":
            return parseHandleResponseStatement(xml);

        case "GiveQuest":
            return parseGiveQuestStatement(xml);

        // Generic
        case "Block":
            return parseBlockStatement(xml);

        case "Conditional":
            return parseConditionalStatement(xml);

        case "CallRoutine":
            return parseCallRoutineStatement(xml);

        case "Exit":
            return parseExitStatement(xml);

        default:
            throw new XmlReadError("Unrecognized statement type '" + type + "'");
        }
    }

    protected static function parseBlockStatement (xml :XML) :BlockStatement
    {
        var statement :BlockStatement = new BlockStatement();
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

    protected static function parseSayStatement (xml :XML) :Statement
    {
        var sayStatement :SayStatement = new SayStatement(
            XmlReader.getStringAttr(xml, "speaker"),
            XmlReader.getStringAttr(xml, "text"));

        var hasResponse :Boolean;
        for each (var responseXml :XML in xml.Response) {
            sayStatement.addResponse(
                XmlReader.getStringAttr(responseXml, "id"),
                XmlReader.getStringAttr(responseXml, "text"));
            hasResponse = true;
        }

        // If there are any response statements, add a WaitResponseStatement
        // immediately after the SayStatement.
        if (hasResponse) {
            var blockStatement :BlockStatement = new BlockStatement();
            blockStatement.addStatement(sayStatement);
            blockStatement.addStatement(new WaitResponseStatement());
            return blockStatement;

        } else {
            return sayStatement;
        }
    }

    protected static function parseWaitResponseStatement (xml :XML) :WaitResponseStatement
    {
        return new WaitResponseStatement();
    }

    protected static function parseHandleResponseStatement (xml :XML) :Statement
    {
        // a "HandleResponse" statement is a Conditional
        var conditional :ConditionalStatement = new ConditionalStatement();

        for each (var responseXml :XML in xml.Response) {
            var responseId :String = XmlReader.getStringAttr(responseXml, "id");
            // If response = id, then
            conditional.addIf(
                new BinaryCompExpr(
                    new ResponseExpr(),
                    new ValueExpr(responseId),
                    BinaryCompExpr.EQUALS),
                parseBlockStatement(responseXml));
        }

        return conditional;
    }

    protected static function parseCallRoutineStatement (xml :XML) :CallRoutineStatement
    {
        return new CallRoutineStatement(XmlReader.getStringAttr(xml, "name"));
    }

    protected static function parseExitStatement (xml :XML) :ExitStatement
    {
        return new ExitStatement();
    }

    protected static function parseGiveQuestStatement (xml :XML) :GiveQuestStatement
    {
        return new GiveQuestStatement(getQuest(XmlReader.getStringAttr(xml, "name")));
    }

    protected static function parseExpr (xml :XML) :Expr
    {
        var type :String = xml.name().localName;
        switch (type) {
        // Vampire-specific
        case "Response":
            return parseResponseExpr(xml);

        case "IsActiveQuest":
            return parseHasQuestExpr(xml, HasQuestExpr.IS_ACTIVE);

        case "CompletedQuest":
            return parseHasQuestExpr(xml, HasQuestExpr.IS_COMPLETE);

        case "SeenQuest":
            return parseHasQuestExpr(xml, HasQuestExpr.EXISTS);

        // Generic
        case "And":
            return parseAndExpr(xml);

        case "Or":
            return parseOrExpr(xml);

        case "String":
            return parseStringExpr(xml);

        case "Number":
            return parseNumberExpr(xml);

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

    protected static function parseStringExpr (xml :XML) :ValueExpr
    {
        return new ValueExpr(XmlReader.getStringAttr(xml, "val"));
    }

    protected static function parseNumberExpr (xml :XML) :ValueExpr
    {
        return new ValueExpr(XmlReader.getNumberAttr(xml, "val"));
    }

    protected static function parseResponseExpr (xml :XML) :ResponseExpr
    {
        return new ResponseExpr();
    }

    protected static function parseHasQuestExpr (xml :XML, type :int) :HasQuestExpr
    {
        return new HasQuestExpr(getQuest(XmlReader.getStringAttr(xml, "name")), type);
    }

    protected static function parseBinaryCompExpr (xml :XML, type :int) :BinaryCompExpr
    {
        var children :XMLList = xml.children();
        if (children.length() != 2) {
            throw new XmlReadError("BinaryCompExprs must have two expression children");
        }

        return new BinaryCompExpr(parseExpr(children[0]), parseExpr(children[1]), type);
    }

    protected static function getQuest (questName :String) :QuestDesc
    {
        var quest :QuestDesc = Quests.getQuestByName(questName);
        if (quest == null) {
            throw new XmlReadError("No quest named '" + questName + "' exists");
        }
        return quest;
    }
}

}
