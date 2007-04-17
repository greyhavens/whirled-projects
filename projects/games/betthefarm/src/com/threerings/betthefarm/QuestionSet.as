//
// $Id$

package com.threerings.betthefarm {

import com.threerings.util.ArrayUtil;

import com.threerings.util.HashMap;

public class QuestionSet
{
    public function QuestionSet ()
    {
        _questions = new Array();
        _categories = new Object();
    }

    public function addQuestion (question :Question) :void
    {
        var category :String = question.category.toLowerCase();
        var arr :Array = _categories[category];
        if (!arr) {
            arr = _categories[category] = new Array();
        }
        arr.push(_questions.length);
        _questions.push(question);
    }

    public function getQuestion (ix :int) :Question
    {
        return _questions[ix];
    }

    public function getQuestionCount () :int
    {
        return _questions.length;
    }

    public function getCategoryIxSet (category :String) :Array
    {
        return _categories[category];
    }

    public function getCategories () :Array
    {
        var map :HashMap = new HashMap();
        for (var ii :int = 0; ii < _questions.length; ii ++) {
            map.put(_questions[ii].category, true);
        }
        return map.keys();
    }

    public function removeQuestion (ix :int) :void
    {
        var question :Question = _questions[ix];
        if (!question) {
            throw new Error("Unknown question [ix=" + ix + "]");
        }
        var category :String = question.category.toLowerCase();
        if (!ArrayUtil.removeFirst(_categories[category], ix)) {
            throw new Error(
                "Can't find index in category [ix=" + ix + ", category=" + category + "]");
        }

        _questions.splice(ix, 1);
    }

    protected var _questions :Array;
    protected var _categories :Object;
}
}
