//
// $Id$

package com.threerings.betthefarm {

public class Question
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

    public function getCorrectAnswer () :String
    {
        throw new Error("Override Me");
    }
}
}
