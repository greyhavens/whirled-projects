package vampire.quest.client.npctalk {

public class BinaryCompExpr
    implements Expr
{
    public static const EQUALS :int = 0;
    public static const NOT_EQUALS :int = 1;
    public static const LT :int = 2;
    public static const LTE :int = 3;
    public static const GT :int = 4;
    public static const GTE :int = 5;

    public function BinaryCompExpr (lhs :Expr, rhs :Expr, type :int)
    {
        _lhs = lhs;
        _rhs = rhs;
        _type = type;
    }

    public function eval () :*
    {
        var lval :* = _lhs.eval();
        var rval :* = _rhs.eval();

        switch (_type) {
        case EQUALS:
            return lval == rval;

        case NOT_EQUALS:
            return lval != rval;

        case LT:
            return lval < rval;

        case LTE:
            return lval <= rval;

        case GT:
            return lval > rval;

        case GTE:
            return lval >= rval;

        default:
            throw new Error("Unrecognized comparison type " + _type);
        }
    }

    protected var _lhs :Expr;
    protected var _rhs :Expr;
    protected var _type :int;
}

}
