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

    public function update (dt :Number) :Number
    {
        // determine which statement to evaluate
        if (_statement == null) {
            for (var ii :int = 0; ii < _ifExprs.length; ++ii) {
                var expr :Expr = _ifExprs[ii];
                if (Boolean(expr.eval())) {
                    _statement = _ifStatements[ii];
                    break;
                }
            }

            if (_statement == null) {
                _statement = (_else != null ? _else : NoopStatement.INSTANCE);
            }
        }

        return _statement.update(dt);
    }

    protected var _ifExprs :Array = [];
    protected var _ifStatements :Array = [];
    protected var _else :Statement;

    // the statement we're actually evaluating
    protected var _statement :Statement;
}

}
