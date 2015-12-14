//
// $Id$

package com.threerings.betthefarm {

public class FreeResponse extends Question
{
    public var correct :Array;

    public function FreeResponse (
        category :String, difficulty :int, question :String, correct :Array)
    {
        super(category, difficulty, question);
        this.correct = correct;
    }

    override public function getCorrectAnswer () :String
    {
        return correct[0];
    }

    public static const QUESTIONS :XML =
<Questions>
   <FreeResponse>
    <Category>Movies</Category>
    <Question>What was the first name of Adam Sandler's character in 'Mr. Deeds' (2002)?</Question>
    <Correct>Longfellow</Correct>
    <Info>Mr. Longfellow Deeds constantly asked people to keep his first name under wraps and to call him by his last.</Info>
   </FreeResponse>
   <FreeResponse>
    <Category>Movies</Category>
    <Question>What company did Chuck (Tom Hanks) work for in 2000's 'Cast Away'?</Question>
    <Correct>Fed Ex</Correct>
    <Correct>FedEx</Correct>
    <Info>He was a time-obsessed supervisor for Fed Ex before being stranded on the island.</Info>
   </FreeResponse>
   <FreeResponse>
    <Category>Animals</Category>
    <Question>What do scientists regard as the most intelligent of livestock?</Question>
    <Correct>The pig</Correct>
    <Correct>pig</Correct>
    <Correct>pigs</Correct>
    <Info>In animal intelligence tests, pigs score as high or higher than dogs. There's a reason that the pigs ran &quot;Animal Farm.&quot;</Info>
   </FreeResponse>
   <FreeResponse>
    <Category>Movies</Category>
    <Question>In &quot;Rain Man (1988)  where did Raymond buy his underwear?&quot;</Question>
    <Correct>K-Mart</Correct>
    <Correct>KMart</Correct>
    <Info>As he told his brother Charlie (Tom Cruise), Raymond (Dustin Hoffman) bought his boxer shorts at K-Mart in Cincinnati. Raymond was very upset when he was asked to wear new underwear that wasn't from that K-Mart.</Info>
   </FreeResponse>
   <FreeResponse>
    <Category>Movies</Category>
    <Question>What was the name of the female truck driver who gave Pee-wee a ride in &quot;Pee-wee's Big Adventure&quot; (1985)?</Question>
    <Correct>Large Marge</Correct>
    <Correct>Marge</Correct>
    <Info>Pee-wee was hitchhiking across the country in pursuit of his stolen bike, and Large Marge stopped to give him a ride.</Info>
   </FreeResponse>
   <FreeResponse>
    <Category>Movies</Category>
    <Question>In &quot;The Princess Bride (1987)  Westley and Inigo fought atop the Cliffs of what?&quot;</Question>
    <Correct>Insanity</Correct>
    <Info>Westley followed Montoya, Vizzini, and Fezzik to the cliffs and climbed up after them. When Westley got to the top, Inigo was waiting for him, and they dueled it out before Westley continued on in pursuit of Vizzini, Fezzik, and, ultimately, Buttercup.</Info>
   </FreeResponse>
   <FreeResponse>
    <Category>Geography</Category>
    <Question>Which South American city is laid out in the shape of an airplane?</Question>
    <Correct>Brasilia</Correct>
    <Info>Brasilia was built to replace Rio de Janiero as the capital of Brazil. The city was inaugurated in 1950.</Info>
   </FreeResponse>
   <FreeResponse>
    <Category>Hobbies</Category>
    <Question>Which game of Chinese origin, using tiles built into walls, became very popular in the U.S. in the twenties and is still played today?</Question>
    <Correct>Mahjong</Correct>
    <Correct>Mah Jong</Correct>
    <Info>Mah Jong is a game involving tiles of different suits. It became a real craze in the 1920s.</Info>
   </FreeResponse>
   <FreeResponse>
    <Category>Movies</Category>
    <Question>In &quot;Misery (1990)  what did Annie give Paul that eventually helped him to kill her?&quot;</Question>
    <Correct>Typewriter</Correct>
    <Correct>Type Writer</Correct>
    <Info>Annie (Kathy Bates) had given the typewriter to Paul (James Caan) so that he could finish the manuscript, but at the end she incurred some rather nasty and ultimately fatal head wounds from the machine. This film was adapted by William Goldman from the Stephen King novel of the same name. Rob Reiner directed.</Info>
   </FreeResponse>
   <FreeResponse>
    <Category>Movies</Category>
    <Question>What was the title of the innovative new book written by the psychiatrist played by Richard Dreyfuss in &quot;What About Bob?&quot; (1991)?</Question>
    <Correct>Baby Steps</Correct>
    <Info>Unfortunately for Dreyfuss' character Leo, Bob (Bill Murray) wasn't satisfied with the book and followed Leo and his family to their New Hampshire vacation destination.</Info>
   </FreeResponse>
   <FreeResponse>
    <Category>Geography</Category>
    <Question>The Caucasus Mountains run from the Black Sea to which other so-called sea?</Question>
    <Correct>Caspian</Correct>
    <Correct>Caspian Sea</Correct>
    <Info>The Caspian Sea is the world's largest freshwater lake. The Caucasus Mountain range is 750 miles (1,200 kilometers) long. It contains the highest point in Europe, Mount El'brus which has a height of 18,510 feet (5,642 meters).</Info>
   </FreeResponse>
 </Questions>;

}
}
