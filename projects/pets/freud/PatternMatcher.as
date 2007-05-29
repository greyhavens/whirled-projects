package {

import flash.events.TimerEvent;

public class PatternMatcher
{
    // Main patterns
    
    /** Pattern definitions. */
    public static const PATTERNS :Array = [
        [ "GREETING", [ "hi there!", "hello there", "how are you?",
                        "hi, ~name", "hello, ~name" ] ],
        [ "freud", "hello, ~name" ],
        [ "test", "~areyou testing me?" ],
        [ "repeat (WORDS)", "here you go: $1" ],

        // Statements about self
        [ "i (DESIREVERB) (WORDS)", [ "~whysay you $1 that?", "are you unhappy because you $1 $2?",
                                      "why do you $1 $2?", "are you ~sure you $1 $2?" ] ],
        [ "i am not", [ "~whysay you are not?",
                        "~talkabout why you think you are not",
                        "~please ~talkabout that",
                        "~continue" ] ],
        [ "i am", [ "how often?", "do you wish you weren't?", "how do you feel about that?",
                    "are you really?", "you are?" ] ],

        // Statements about things
        [ "(INDEXICAL) (COPULA) NOT (WORDS)", [ "~whysay $1 $2 not?", "~really, not $3?" ] ],
        [ "(INDEXICAL) (COPULA) (WORDS)", [ "$2 $1 ~really $3", "~really $3?",
                                            "but $2 $1 really?" ] ],
        
        // Statements about people 
        [ "(PRONOUN) COPULA NICEADJ", [ "is $1 special to you?",
                                        "what else is $1 like?",
                                        "~maybe $1 means a lot to you?",
                                        "~please ~talkabout that" ] ],
        [ "(PRONOUN) COPULA BADADJ",  [ "is $1 someone you dislike?",
                                      "does $1 ever do anything you appreciate?",
                                      "what does $1 mean to you?",
                                      "would you prefer if $1 were not around you?" ] ],
        [ "(PRONOUN) WORDS BADADJ", [ "tell me ~something about what $1 is like",
                                      "~areyou ~afraidof that?" ] ],
        [ "(PRONOUN) (COPULA)", [ "what else $2 $1 like?",
                                  "is there something about $1 you really like?",
                                  "$2 $1 someone you'd look up to?",
                                  "does $1 annoy you?" ] ],

        // Statements about unknown topic
        [ "i (NICEVERB) (WORDS)", [ "you feel strongly about $2",
                                    "why do you $1 $2?",
                                    "is $2 special to you?",
                                    "how much do you $1 $2?" ] ],
        [ "i (BADVERB) (WORDS)",  [ "is there anything positive about it?",
                                    "does it make you feel energized to talk about it?",
                                    "do you like $2 even one bit?" ] ],

        // Justifications
        [ "why", [ "~maybe that ~isrelated to why you came to me",
                   "~areyou ~afraidof that possibility?", "~please ~talkabout that" ] ],
        [ "because", [ "are you ~sure", "maybe this ~isrelated to how you're feeling",
                       "is that the reason?" ] ],
        
        // Catch-alls
        [ "yes", [ "~whysay that is so?", "i don't think so", "is it ~randomadj?",
                   "~maybe this ~isrelated your problems" ] ],
        [ "no", [ "~areyou ~sure?", "do you find it at all ~randomadj?", "~maybe you're wrong" ] ],
        [ "(FAMILY)", "~please ~talkabout your $1" ],
        [ "", "~please ~talkabout your ~interests" ],
        
        ];

    /** Shortcut definitions. */
    public static const SHORTCUTS :Array = [
        [ "PRONOUN_POSSESSIVE", "(?:my|your|his|her|its|our|their)" ],
        [ "PRONOUN_ACCUSATIVE", "(?:me|you|him|her|it|us|them)" ],
        [ "PRONOUN", "\\b(?:I|you|he|she|it|we|they)\\b" ],
        [ "COPULA", "\\b(?:is|are)\\b" ],
        [ "INDEXICAL", "\\b(?:it|this|that|these|those)\\b" ],
        [ "NOT", "\\b(?:no|not)\\b" ],
        [ "WORDS", "(?:\\w+\\s*)+" ],
        [ "WORD", "\\w+" ],
        [ "NICEADJ", "(?:nice|sweet|lovely|pretty|cool|awesome|cheer)" ],
        [ "BADADJ", "(?:bad|horrible|mean|boring|stupid|dumb)" ],
        [ "NICEVERB", "(?:like|enjoy|love|hug|lub|heart)s?" ],
        [ "BADVERB", "(?:dislike|hate|despise|loathe)s?" ],
        [ "NICESTUFF", ".*(?:NICEADJ|love|neat)" ],
        [ "GREETING", "(?:\\bhi\\b|hello|howdy|greetings)" ],
        [ "DESIREVERB", "(?:want|wish|desire|like|hope|dream|need)s?" ],
        [ "MOODADJ", "(?:frustrated|depressed|annoyed|upset|excited|worried|lonely|angry|mad)" ],
        [ "FAMILY", "(?:wife|husband|partner|kid|children|child|parent|brother|sister)s?" ],
        ];


    // Helpers

    /** Preprocessing. */
    public static const PREPROCESSING :Array = [
        // unwrap contractions
        [ "'m", " am" ],
        [ "'re", " are" ],
        [ "'s", " is" ],
        [ "'ve", " have" ],
        [ "'d", " would" ],
        [ "n't", " not" ],
        [ "won't", "will not" ],
        [ "can't", "can not" ], // yeah, not grammatical, but easy to parse
        // remove filler words
        [ "//b(?:so|really|frankly|actually|please|eh|oh|maybe|perhaps|well)//b", "" ],
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

    /** Unwrap special production variables */
    public static const CONSTANTS :Array = [
        [ "~areyou", [ "are you", "have you been", "have you been",
                       "do you think you are", "are you perhaps" ] ],
        [ "~sure",   [ "sure", "positive", "certain", "absolutely sure" ] ],
        [ "~relation", [ "your relationship with", "something you remember about",
                         "your feelings toward", "some experiences you've had with",
                         "how you feel about" ] ],
        [ "~continue", [ "continue", "proceed", "go on", "keep going" ] ],
        [ "~afraidof", [ "afraid of", "scared of", "frightened by" ] ],
        [ "~isrelated", [ "has something to do with", "is related to", "could be the reason for",
                          "is caused by", "is because of" ] ],
        [ "~arerelated", [ "have something to do with", "are related to",
                           "could be the reasons for", "are caused by", "are because of" ] ],
        [ "~maybe", [ "maybe", "perhaps" ] ],
        [ "~really", [ "really", "are you sure", "actually" ] ],
        [ "~whysay", [ "why do you say", "what makes you believe", "are you sure",
                       "do you really think", "what makes you think" ] ],
        [ "~isee", [ "i see...", "yes,", "i understand.", "oh." ] ],
        [ "~randomadj", [ "vivid", "stimulating", "exciting", "boring", "interesting",
                          "recent", "random", "usual", "shocking", "embarrassing" ] ],
        [ "~something", [ "something", "more", "how do you feel" ] ],
        [ "~please", [ "", "", "", "please,", "please", "perhaps you could", "could you please",
                       "why don't you", "could you", "i would appreciate it if you would" ] ],
        [ "~talkabout", [ "tell me about", "say more about", "describe", "tell me more about" ] ],
        [ "~interests", [ "plans", "dreams", "goals", "friends",
                          "problems", "inhibitions", "mother", "parents" ] ],
        ];
    
    /** Person/number agreement post-processing. */
    public static const POSTPROCESSING :Array = [
        [ "\\b(i|you|we|they) does\\b", "$1 do" ],
        [ "\\bdoes (i|you|we|they)\\b", "do $1" ],
        [ "\\b(he|she|it) do\\b", "$1 does" ],
        [ "\\bdo (he|she|it)\\b", "does $1" ],
        
        [ "\\b(i|you|we|they) has\\b", "$1 have" ],
        [ "\\bhas (i|you|we|they)\\b", "have $1" ],
        [ "\\b(he|she|it) have\\b", "$1 has" ],
        [ "\\bhas (he|she|it)\\b", "has $1" ],

        [ "\\b(he|she|it) (am|are)\\b", "$1 is" ],
        [ "\\b(?:am|are) (he|she|it)\\b", "is $1" ],
        [ "\\b(we|you|they) (am|is)\\b", "$1 are" ],
        [ "\\b(?:am|is) (we|you|they)\\b", "are $1" ],
        [ "\\b(i|me) (are|is)\\b", "i am" ],
        [ "\\b(are|is) (me|i)\\b", "am i" ],
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
//        trace("PROCESSED INPUT: " + t);
        
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

//        trace("MATCHED REGEXP: " + re);

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
//        trace("PROCESS REPL");
        
        // in the replacement function, i'm using bindings from one regexp
        // to populate a completely different response string. but this means
        // i have to do the populating manually.

        var replacements :Array = [ [ "$1", replace(bindings[1], POV) ],
                                    [ "$2", replace(bindings[2], POV) ],
                                    [ "$3", replace(bindings[3], POV) ],
                                    [ "$4", replace(bindings[4], POV) ],
                                    [ "$5", replace(bindings[5], POV) ],
                                    [ "~name", speaker ] ];

        for each (var pair :Array in replacements) {
                if (pair[1] != null) {
                    response = response.replace(pair[0], (pair[1] as String).toLowerCase());
                }
//                trace("RESPONSE: " + response);
            }
        
        response = replace(response.toLowerCase(), CONSTANTS);
//        trace("RESPONSE: " + response);
        response = replace(response, POSTPROCESSING);
//        trace("FINAL RESPONSE: " + response);
        
        return response;
    }

    /** Runs an array of pattern-replacement pairs over an input string. */
    protected function replace (input :String, pairs :Array) :String
    {
        if (input == null) return null;
        
        pairs.forEach(function (def :Array, i :int, a :Array) :void {
                var pattern :RegExp = new RegExp(def[0], "gi");
                var replacement :String = def[1] as String;
                // if the replacement is an array, pick a random element
                if (def[1] is Array) {
                    var i :int = int(Math.floor(Math.random() * (def[1] as Array).length));
                    replacement = (def[1] as Array)[i] as String;
                }

                 input = input.replace(pattern, replacement);
//                trace("REPLACE: " + input);
            });

        return input;
    }


    

    protected var _regexps :Array;

}
}

    
