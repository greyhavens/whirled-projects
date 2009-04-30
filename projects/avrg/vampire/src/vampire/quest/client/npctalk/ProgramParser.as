package vampire.quest.client.npctalk {

import com.whirled.contrib.XmlReadError;
import com.whirled.contrib.XmlReader;

import vampire.quest.*;

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

        case "AddResponse":
            return parseAddResponseStatement(xml);

        case "HandleResponse":
            return parseHandleResponseStatement(xml);

        case "GiveQuest":
            return parseGiveQuestStatement(xml);

        case "GiveActivity":
            return parseGiveActivityStatement(xml);

        case "SetProp":
            return parseSetPropStatement(xml);

        case "ClearProp":
            return parseClearPropStatement(xml);

        // Generic
        case "Block":
            return parseBlockStatement(xml);

        case "Conditional":
            return parseConditionalStatement(xml);

        case "CallRoutine":
            return parseCallRoutineStatement(xml);

        case "Wait":
            return parseWaitStatement(xml);

        case "Exit":
            return parseExitStatement(xml);

        case "SetValue":
            return parseSetVarStatement(xml);

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

        var childStatements :BlockStatement;
        if (xml.children().length() > 0) {
            childStatements = parseBlockStatement(xml);

        } else if (XmlReader.hasAttribute(xml, "response")) {
            // add an implicit AddResponse statement
            childStatements = new BlockStatement();
            childStatements.addStatement(
                new AddResponseStatement("", XmlReader.getStringAttr(xml, "response"), 0));
        }

        // If SayStatement has any children, they execute immediately after the Say, and we
        // add an implicit WaitResponseStatement at the end
        if (childStatements != null) {
            childStatements.addStatement(sayStatement, 0);
            childStatements.addStatement(new WaitResponseStatement());
            return childStatements;
        } else {
            return sayStatement;
        }
    }

    protected static function parseAddResponseStatement (xml :XML) :AddResponseStatement
    {
        return new AddResponseStatement(
            XmlReader.getStringAttr(xml, "id", ""),
            XmlReader.getStringAttr(xml, "text"),
            XmlReader.getUintAttr(xml, "juiceCost", 0));
    }

    protected static function parseHandleResponseStatement (xml :XML) :Statement
    {
        // a "HandleResponse" statement is a Conditional
        var conditional :ConditionalStatement = new ConditionalStatement();
        var responseId :String = XmlReader.getStringAttr(xml, "id");
        conditional.addIf(
            new BinaryCompExpr(
                new ResponseExpr(),
                new ValueExpr(responseId),
                BinaryCompExpr.EQUALS),
            parseBlockStatement(xml));

        return conditional;
    }

    protected static function parseCallRoutineStatement (xml :XML) :CallRoutineStatement
    {
        return new CallRoutineStatement(XmlReader.getStringAttr(xml, "name"));
    }

    protected static function parseWaitStatement (xml :XML) :WaitStatement
    {
        return new WaitStatement(XmlReader.getNumberAttr(xml, "seconds"));
    }

    protected static function parseExitStatement (xml :XML) :ExitStatement
    {
        return new ExitStatement();
    }

    protected static function parseSetVarStatement (xml :XML) :SetVarStatement
    {
        var name :String = XmlReader.getStringAttr(xml, "name");
        var expr :Expr;
        if (XmlReader.hasAttribute(xml, "number")) {
            expr = new ValueExpr(XmlReader.getNumberAttr(xml, "number"));
        } else if (XmlReader.hasAttribute(xml, "string")) {
            expr = new ValueExpr(XmlReader.getStringAttr(xml, "string"));
        } else {
            expr = new ValueExpr(true);
        }

        return new SetVarStatement(name, expr);
    }

    protected static function parseGiveQuestStatement (xml :XML) :GiveQuestStatement
    {
        return new GiveQuestStatement(getQuest(XmlReader.getStringAttr(xml, "name")));
    }

    protected static function parseGiveActivityStatement (xml :XML) :GiveActivityStatement
    {
        return new GiveActivityStatement(getActivity(XmlReader.getStringAttr(xml, "name")));
    }

    protected static function parseSetPropStatement (xml :XML) :SetQuestPropStatement
    {
        var propName :String = XmlReader.getStringAttr(xml, "name");
        var expr :Expr;
        if (XmlReader.hasAttribute(xml, "number")) {
            expr = new ValueExpr(XmlReader.getNumberAttr(xml, "number"));
        } else if (XmlReader.hasAttribute(xml, "string")) {
            expr = new ValueExpr(XmlReader.getStringAttr(xml, "string"));
        } else {
            expr = new ValueExpr(true);
        }

        return new SetQuestPropStatement(propName, expr);
    }

    protected static function parseClearPropStatement (xml :XML) :ClearQuestPropStatement
    {
        return new ClearQuestPropStatement(XmlReader.getStringAttr(xml, "name"));
    }

    protected static function parseExpr (xml :XML) :Expr
    {
        var type :String = xml.name().localName;
        switch (type) {
        // Vampire-specific
        case "HasQuest":
            return parseHasQuestExpr(xml, HasQuestExpr.IS_ACTIVE);

        case "CompletedQuest":
            return parseHasQuestExpr(xml, HasQuestExpr.IS_COMPLETE);

        case "SeenQuest":
            return parseHasQuestExpr(xml, HasQuestExpr.EXISTS);

        case "HasActivity":
            return parseHasActivityExpr(xml);

        case "HasProp":
            return parseHasPropExpr(xml);

        case "PropValue":
            return parsePropValueExpr(xml);

        // Generic
        case "And":
            return parseAndExpr(xml);

        case "Or":
            return parseOrExpr(xml);

        case "Not":
            return parseNotExpr(xml);

        case "String":
            return parseStringExpr(xml);

        case "Number":
            return parseNumberExpr(xml);

        case "Equals":
            return parseBinaryCompExpr(xml, BinaryCompExpr.EQUALS);

        case "NotEquals":
            return parseBinaryCompExpr(xml, BinaryCompExpr.NOT_EQUALS);

        case "Less":
            return parseBinaryCompExpr(xml, BinaryCompExpr.LT);

        case "LessEqual":
            return parseBinaryCompExpr(xml, BinaryCompExpr.LTE);

        case "Greater":
            return parseBinaryCompExpr(xml, BinaryCompExpr.GT);

        case "GreaterEqual":
            return parseBinaryCompExpr(xml, BinaryCompExpr.GTE);

        case "Value":
            return parseVarExpr(xml);

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

    protected static function parseNotExpr (xml :XML) :NotExpr
    {
        var xmlChildren :XMLList = xml.children();
        if (xmlChildren.length() != 1) {
            throw new XmlReadError("NotExpr requires 1 expression child");
        }

        return new NotExpr(parseExpr(xmlChildren[0]));
    }

    protected static function parseStringExpr (xml :XML) :ValueExpr
    {
        return new ValueExpr(XmlReader.getStringAttr(xml, "val"));
    }

    protected static function parseNumberExpr (xml :XML) :ValueExpr
    {
        return new ValueExpr(XmlReader.getNumberAttr(xml, "val"));
    }

    protected static function parseHasQuestExpr (xml :XML, type :int) :HasQuestExpr
    {
        return new HasQuestExpr(getQuest(XmlReader.getStringAttr(xml, "name")), type);
    }

    protected static function parseHasActivityExpr (xml :XML) :HasActivityExpr
    {
        return new HasActivityExpr(getActivity(XmlReader.getStringAttr(xml, "name")));
    }

    protected static function parseHasPropExpr (xml :XML) :HasQuestPropExpr
    {
        return new HasQuestPropExpr(XmlReader.getStringAttr(xml, "name"));
    }

    protected static function parsePropValueExpr (xml :XML) :QuestPropValExpr
    {
        return new QuestPropValExpr(XmlReader.getStringAttr(xml, "name"));
    }

    protected static function parseBinaryCompExpr (xml :XML, type :int) :BinaryCompExpr
    {
        var children :XMLList = xml.children();
        if (children.length() != 2) {
            throw new XmlReadError("BinaryCompExprs must have two expression children");
        }

        return new BinaryCompExpr(parseExpr(children[0]), parseExpr(children[1]), type);
    }

    protected static function parseVarExpr (xml :XML) :VarExpr
    {
        return new VarExpr(XmlReader.getStringAttr(xml, "name"));
    }

    protected static function getQuest (questName :String) :QuestDesc
    {
        var quest :QuestDesc = Quests.getQuestByName(questName);
        if (quest == null) {
            throw new XmlReadError("No quest named '" + questName + "' exists");
        }

        return quest;
    }

    protected static function getLoc (locName :String) :LocationDesc
    {
        var loc :LocationDesc = Locations.getLocationByName(locName);
        if (loc == null) {
            throw new XmlReadError("No location named '" + locName + "' exists");
        }

        return loc;
    }

    protected static function getActivity (activityName :String) :ActivityDesc
    {
        var activity :ActivityDesc = Activities.getActivityByName(activityName);
        if (activity == null) {
            throw new XmlReadError("No activity named '" + activityName + "' exists");
        }

        return activity;
    }
}

}
