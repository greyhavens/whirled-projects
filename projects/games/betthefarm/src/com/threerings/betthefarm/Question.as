//
// $Id$

package com.threerings.betthefarm {

import com.threerings.util.Hashable;

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
        // this can be pretty simple for now
        return question.length +
            43 * (question.charCodeAt(question.length/4) +
                  43 * question.charCodeAt(question.length/2));
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
