//
// $Id$

package com.threerings.betthefarm {

import com.threerings.util.Hashable;
import com.threerings.util.StringUtil;

public class Question
    implements Hashable
{
    public static const EASY :int = 1;
    public static const MEDIUM :int = 2;
    public static const HARD :int = 3;
    public static const IMPOSSIBLE :int = 4;

    public var category :String;
    public var difficulty :int;
    public var question :String;

    public function Question (category :String, difficulty :int, question :String)
    {
        this.category = category;
        this.difficulty = difficulty;
        this.question = question;
    }

    public function hashCode () :int
    {
        return StringUtil.hashCode(question);
    }

    public function equals (other :Object) :Boolean
    {
        return question == other.question;
    }

    public function getCorrectAnswer () :String
    {
        throw new Error("Override Me");
    }
}
}
