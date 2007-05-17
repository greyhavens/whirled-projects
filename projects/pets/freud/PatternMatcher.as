package {

import flash.events.TimerEvent;

public class PatternMatcher
{
    // Main patterns
    
    /** Pattern definitions. */
    public static const PATTERNS :Array = [
        [ "hello", [ "hi there!", "hello there" ] ],
        [ "freud", "hello, $name" ],
        [ "repeat (WORDS)", "here you go: $1" ],

        // Statements about people
        [ "(he|she) WORDS NICEADJ", [ "is $1 special to you?",
                                      "what else is $1 like?",
                                      "$1 means a lot to you?",
                                      "what does it mean to you when $1 is in your life?" ] ],
        [ "(he|she) WORDS BADADJ",  [ "is $1 someone you dislike?",
                                      "does $1 ever do anything you appreciate?",
                                      "what does $1 mean to you?",
                                      "would you prefer if $1 were not around you?" ] ],
        [ "(he|she) is WORDS", [ "what else $2 $1 like?",
                                 "is there something about $1 you really like?",
                                 "is $1 someone you look up to?",
                                 "does it annoy you?" ] ],

        // Statements about unknown topic
        [ "i (NICEVERB) (WORDS)", [ "you feel strongly about $2",
                                    "why do you $1 $2?",
                                    "is $2 special to you?",
                                    "how much do you $1 $2?" ] ],
        [ "i (BADVERB) (WORDS)",  [ "is there anything positive about it?",
                                    "does it make you feel energized to talk about it?",
                                    "do you like $2 even one bit?" ] ],

        // Catch-alls
        [ "i am", [ "how often?", "do you wish you weren't?", "how do you feel about that?",
                    "are you really?", "you are?" ] ],
        
        ];

    /** Shortcut definitions. */
    public static const SHORTCUTS :Array = [
        [ "PRONOUN_POSSESSIVE", "(?:my|your|his|her|its|our|their)" ],
        [ "PRONOUN_ACCUSATIVE", "(?:me|you|him|her|it|us|them)" ],
        [ "PRONOUN", "(?:I|you|he|she|it|we|they)" ],
        [ "COPULA", "is|are" ],
        [ "WORDS", "(?:\\w+\\s*)+" ],
        [ "WORD", "\\w+" ],
        [ "NICEADJ", "(?:nice|sweet|lovely|pretty|cool|awesome|cheer)" ],
        [ "BADADJ", "(?:bad|horrible|mean|boring|stupid|dumb)" ],
        [ "NICEVERB", "(?:like|enjoy|love|hug|lub|heart)s?" ],
        [ "BADVERB", "(?:dislike|hate|despise|loathe)s?" ],
        [ "NICESTUFF", ".*(?:NICEADJ|love|neat)" ],
        ];


    // Helpers

    /** Preprocessing. */
    public static const PREPROCESSING :Array = [
        // unwrap contractions
        [ "'m", " am" ],
        [ "'re", " are" ],
        [ "'s", " is" ],
        // remove filler words
        [ "//b(?:so|really|frankly|actually)//b", "" ],
        // remove punctuation
        [ "[!?.,;:'\"\\-=_+]", "" ],
        [ "  ", " " ],
        ];
    
    /** Point of view reversals. */
    public static const POV :Array = [
        // since all replacements are applied in one pass, the temp values are here to
        // guard against an early replacement getting undone by a later one. such kluge! :)
        [ "\\byou\\b", "me___" ],
        [ "\\byour\\b", "me___" ],
        [ "\\byours\\b", "me___" ],
        [ "\\bi\\b", "you" ],
        [ "\\bme\\b", "you" ],
        [ "\\bmy\\b", "your" ],
        [ "\\bmine\\b", "yours" ],
        [ "___", "" ],
        ];

    /** Agreement post-processing. */
    public static const POSTPROCESSING :Array = [
        [ "\\b(i|you) does\\b", "$1 do" ],
        [ "\\bdoes (i|you)\\b", "do $1" ],
        [ "\\b(he|she|it) do\\b", "$1 does" ],
        [ "\\bdo (he|she|it)\\b", "does $1" ],
        
        [ "\\b(i|you) has\\b", "$1 have" ],
        [ "\\bhas (i|you)\\b", "have $1" ],
        [ "\\b(he|she|it) have\\b", "$1 has" ],
        [ "\\bhas (he|she|it)\\b", "has $1" ],

        [ "\\b(he|she|it) (am|are)\\b", "$1 is" ],
        [ "\\b(am|are) (he|she|it)\\b", "is $2" ],
        [ "\\byou (am|is)\\b", "you are" ],
        [ "\\b(am|is) you\\b", "are you" ],
        [ "\\bi (are|is)\\b", "i am" ],
        [ "\\b(are|is) i\\b", "am i" ],
        ];

    public function PatternMatcher ()
    {
        _regexps = PATTERNS.map(function (pair :Array, i :int, a :Array) :Array {
                var pattern :String = pair[0];
                var response :String = pair[1];

                // fix up the pattern
                pattern = replace(pattern, SHORTCUTS);
               
                // now add to the list of regexps
                return [ new RegExp(pattern, "i"), response ];
            });
    }

    /** Performs substitution of the first available pattern. */
    public function findResponse (speaker :String, text :String) :String
    {
        var response :String;
        var t :String = replace(text.toLocaleLowerCase(), PREPROCESSING);
        
        _regexps.some(function (pair :Array, i :int, a :Array) :Boolean {
                return (response = processPattern(pair[0], pair[1], t, speaker)) != null;
            });

        return response;
    }

    /** Performs matching and substitution on one pattern. */
    public function processPattern (re :RegExp, response :*, input :String, speaker :String)
        :String
    {
        var result :Object = re.exec(input);
        if (result == null) {
            return null;
        }

        // the line matched! pick a replacement
        if (response is Array) {
            var i :int = int(Math.floor(Math.random() * response.length));
            response = response[i];
        }
        
        return processReplacement(result, response as String, speaker);
    }

    /** Once a pattern match was successful, creates a response. */
    protected function processReplacement (bindings :Object, response :String, speaker :String)
        :String
    {
        trace("PROCESS REPL");
        
        // in the replacement function, i'm using bindings from one regexp
        // to populate a completely different response string. but this means
        // i have to do the populating manually.

        var replacements :Array = [ [ "$1", replace(bindings[1], POV) ],
                                    [ "$2", replace(bindings[2], POV) ],
                                    [ "$3", replace(bindings[3], POV) ],
                                    [ "$4", replace(bindings[4], POV) ],
                                    [ "$5", replace(bindings[5], POV) ],
                                    [ "$name", speaker ] ];

        //response = replace(response.toLowerCase(), replacements);
        
        for each (var pair :Array in replacements) {
                if (pair[1] != null) {
                    response = response.replace(pair[0], (pair[1] as String).toLowerCase());
                }
//                trace("RESPONSE: " + response);
            }
        
        
        // revert the point of view
        response = replace(response.toLowerCase(), POSTPROCESSING);
        trace("FINAL RESPONSE: " + response);
        
        return response;
    }

    /** Runs an array of pattern-replacement pairs over an input string. */
    protected function replace (input :String, pairs :Array) :String
    {
        if (input == null) return null;
        
        pairs.forEach(function (def :Array, i :int, a :Array) :void {
                input = input.replace(new RegExp(def[0], "gi"), def[1]);
//                trace("REPLACE: " + input);
            });

        return input;
    }


    

    protected var _regexps :Array;

}
}

    
