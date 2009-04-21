package vampire.quest.client.npctalk {

public class ConditionalStatement
    implements Statement
{
    public function addIf (expr :Expr, statement :Statement) :void
    {
        _ifExprs.push(expr);
        _ifStatements.push(statement);
    }

    public function setElse (statement :Statement) :void
    {
        _else = statement;
    }

    public function createState () :Object
    {
        return new ConditionalState();
    }

    public function update (dt :Number, state :Object) :Number
    {
        var cState :ConditionalState = ConditionalState(state);

        // determine which statement to evaluate
        if (cState.statement == null) {
            for (var ii :int = 0; ii < _ifExprs.length; ++ii) {
                var expr :Expr = _ifExprs[ii];
                if (Boolean(expr.eval())) {
                    cState.statement = _ifStatements[ii];
                    cState.statementState = cState.statement.createState();
                    break;
                }
            }

            if (cState.statement == null) {
                if (_else != null) {
                    cState.statement = _else;
                    cState.statementState = _else.createState();
                } else {
                    cState.statement = NoopStatement.INSTANCE;
                }
            }
        }

        return cState.statement.update(dt, cState.statementState);
    }

    public function isDone (state :Object) :Boolean
    {
        var cState :ConditionalState = ConditionalState(state);
        return cState.statement.isDone(cState.statementState);
    }

    protected var _ifExprs :Array = [];
    protected var _ifStatements :Array = [];
    protected var _else :Statement;
}

}

import vampire.quest.client.npctalk.Statement;

class ConditionalState
{
    public var statement :Statement;
    public var statementState :Object;
}
