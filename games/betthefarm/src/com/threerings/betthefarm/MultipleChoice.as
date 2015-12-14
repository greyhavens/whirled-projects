//
// $Id$

package com.threerings.betthefarm {

public class MultipleChoice extends Question
{
    public var correct :String;
    public var incorrect :Array;

    public function MultipleChoice (
        category :String, difficulty :int, question :String,
        correct: String, incorrect: Array)
    {
        super(category, difficulty, question);
        this.correct = correct;
        this.incorrect = incorrect;
    }

    override public function getCorrectAnswer () :String
    {
        return correct;
    }

    public static const QUESTIONS :XML =
 <Questions>
   <MultipleChoice>
    <Category>Geography</Category>
    <Question>Which body of water has the distinction of being the world's largest lake by surface area?</Question>
    <Correct>Caspian Sea</Correct>
    <Incorrect>Lake Superior</Incorrect>
    <Incorrect>Aral Sea</Incorrect>
    <Incorrect>Lake Victoria</Incorrect>
    <Info>The Caspian Sea is actually considered to be a lake, not a sea, despite its name. It can be found in Asia, surrounded by a number of countries, including: Russia, Iran and Kazakhstan.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>People</Category>
    <Question>Which of these 20th century American Presidents was not a winner of the Nobel Prize for Peace?</Question>
    <Correct>Franklin Roosevelt</Correct>
    <Incorrect>Theodore Roosevelt</Incorrect>
    <Incorrect>Woodrow Wilson</Incorrect>
    <Incorrect>Jimmy Carter</Incorrect>
    <Info>Jimmy Carter became the third U.S. President to win the Nobel Prize for Peace in 2002 for his widespread work in the promotion of world peace, including peace missions to North Korea, Haiti and other areas. Franklin Roosevelt's presidency was more known for its war-making policies than its promotion of peace, the last 4 years having seen U.S. involvement in World War II. Theodore Roosevelt won a Peace Prize for his work in arbitrating the end of the Russo-Japanese war, while Woodrow Wilson won his prize for his work in helping to create the League of Nations and for his 14-Point Plan.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>World</Category>
    <Question>The word 'kowtow', which implies obsequiousness in English, comes to us from the Chinese word combination 'koutou' or 'ketou'...both of which literally mean what?</Question>
    <Correct>Bump head</Correct>
    <Incorrect>Serve willingly</Incorrect>
    <Incorrect>Bow graciously</Incorrect>
    <Incorrect>Bend knees</Incorrect>
    <Info>Traditionally, as a sign of respect to a person of superior social position to oneself, a person would get on their knees and bend their body until their head literally bumped or knocked the floor. This term seems to have taken life in the English language, but is used in an extremely derogatory manner. In traditional China it was a sign of utmost respect.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Literature</Category>
    <Question>The name of Tom Wolfe's hit 1988 book 'Bonfire of the Vanities' was drawn from real life events involving what historical figure?</Question>
    <Correct>Savonarola</Correct>
    <Incorrect>Jan Huss</Incorrect>
    <Incorrect>John Calvin</Incorrect>
    <Incorrect>Galileo</Incorrect>
    <Info>Girolamo Savonarola was a monk from Florence who crusaded against the corrupt politics of the ruling Medici family in that city. In the year 1497 he held a burning of various 'lewd' literature and other related items which included works from Ovid, Dante, Boccaccio and others. The following year - 1498 - Pope Alexander VI had Savonarola burned at the stake, on the very same spot!</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Movies</Category>
    <Question>What is the voice message left on David's alarm clock at the beginning of 'Vanilla Sky' (2001)?</Question>
    <Correct>Open Your Eyes</Correct>
    <Incorrect>Sleep Tight</Incorrect>
    <Incorrect>Be Careful</Incorrect>
    <Incorrect>Get Up David</Incorrect>
    <Info>Julie (Cameron Diaz) had left this message on David (Tom Cruise)'s alarm. It was replayed throughout the movie. Penelope Cruz's role was a reprise of her part in the original, 'Abre Los Ojos'.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Movies</Category>
    <Question>In what field was William Forrester (Sean Connery) famous in 'Finding Forrester' (2000)?</Question>
    <Correct>writing</Correct>
    <Incorrect>law</Incorrect>
    <Incorrect>medicine</Incorrect>
    <Incorrect>acting</Incorrect>
    <Info>Forrester had written a novel that won the Pulitzer prize, then retreated into secrecy until a young boy (Rob Brown) drew him out into the world again.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Movies</Category>
    <Question>What was the first name of Adam Sandler's character in 'Mr. Deeds' (2002)?</Question>
    <Correct>Longfellow</Correct>
    <Incorrect>Lachlan</Incorrect>
    <Incorrect>Landers</Incorrect>
    <Incorrect>Langston</Incorrect>
    <Info>Mr. Longfellow Deeds constantly asked people to keep his first name under wraps and to call him by his last.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Movies</Category>
    <Question>What company did Chuck (Tom Hanks) work for in 2000's 'Cast Away'?</Question>
    <Correct>Fed Ex</Correct>
    <Incorrect>UPS</Incorrect>
    <Incorrect>US Mail</Incorrect>
    <Incorrect>Mail Boxes Etc.</Incorrect>
    <Info>He was a time-obsessed supervisor for Fed Ex before being stranded on the island.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Movies</Category>
    <Question>2002's 'Resident Evil' makes several references to a fairy tale. Which one?</Question>
    <Correct>Alice's Adventures in Wonderland</Correct>
    <Incorrect>Sleeping Beauty</Incorrect>
    <Incorrect>Snow White and the Seven Dwarfs</Incorrect>
    <Incorrect>Cinderella</Incorrect>
    <Info>Alice, the Red Queen, and the white rabbit used in the T-virus tests and an 'Alice in Wonderland' paperweight all point to the fact that the fairy tale inspired many things in the movie. Also, the Red Queen asks that one of the infected members be killed in order to let the uninfected ones out. In the fairy tale, the Red Queen says 'Off with her head!' This movie stars Milla Jovovich as Alice.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Movies</Category>
    <Question>Who plays the soldier who falls from a helicopter after missing his descent rope in 2001's 'Black Hawk Down'?</Question>
    <Correct>Orlando Bloom</Correct>
    <Incorrect>Josh Hartnett</Incorrect>
    <Incorrect>William Fichtner</Incorrect>
    <Incorrect>Ewan McGregor</Incorrect>
    <Info>All of these actors were in the film, but the other three lasted a little longer.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Animals</Category>
    <Question>Cat whiskers are so sensitive that they can detect the slightest change in what?</Question>
    <Correct>Air currents</Correct>
    <Incorrect>Air temperature</Incorrect>
    <Incorrect>Air pressure</Incorrect>
    <Incorrect>Air humidity</Incorrect>
    <Info>At night, a cat can slink its way through a room and not bump into anything. The air currents in the room change depending on where pieces of furniture are located. As the cat walks through the room and approaches the couch, he'll know which direction to turn based on the change in air current around the couch.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Animals</Category>
    <Question>What do scientists regard as the most intelligent of livestock?</Question>
    <Correct>The pig</Correct>
    <Incorrect>The horse</Incorrect>
    <Incorrect>The cow</Incorrect>
    <Incorrect>The mule</Incorrect>
    <Info>In animal intelligence tests, pigs score as high or higher than dogs. There's a reason that the pigs ran &quot;Animal Farm.&quot;</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Movies</Category>
    <Question>In &quot;Ghostbusters (1984) Walter Peck (William Atherton) ordered the Ghostbusters to shut down their storage facility. What organization did Peck represent?&quot;</Question>
    <Correct>Environmental Protection Agency (EPA)</Correct>
    <Incorrect>People for the Ethical Treatment of Animals (PETA)</Incorrect>
    <Incorrect>National Organization of Women (NOW)</Incorrect>
    <Incorrect>American Civil Liberties Union (ACLU)</Incorrect>
    <Info>When Peck had a technician shut off the laser protection grid, the facility exploded, releasing all the ghosts that had been held therein.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Movies</Category>
    <Question>What game did Veronica and the Heathers play at Veronica's house in &quot;Heathers&quot; (1989)?</Question>
    <Correct>Croquet</Correct>
    <Incorrect>Badminton</Incorrect>
    <Incorrect>Basketball</Incorrect>
    <Incorrect>Water Polo</Incorrect>
    <Info>After school, the girls would gather at Veronica's house to play Power Croquet. They each had their own signature colors, which were tied into their positions in the power hierarchy.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Movies</Category>
    <Question>In &quot;Rain Man (1988)  where did Raymond buy his underwear?&quot;</Question>
    <Correct>K-Mart</Correct>
    <Incorrect>Victoria's Secret</Incorrect>
    <Incorrect>Hanes Outlet</Incorrect>
    <Incorrect>Macy's</Incorrect>
    <Info>As he told his brother Charlie (Tom Cruise), Raymond (Dustin Hoffman) bought his boxer shorts at K-Mart in Cincinnati. Raymond was very upset when he was asked to wear new underwear that wasn't from that K-Mart.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Movies</Category>
    <Question>What dance was Chunk known for in &quot;The Goonies&quot; (1985)?</Question>
    <Correct>The Truffle Shuffle</Correct>
    <Incorrect>The Schmaltz Waltz</Incorrect>
    <Incorrect>The Shopping Cart</Incorrect>
    <Incorrect>The Lawnmower</Incorrect>
    <Info>Chunk was the fat kid, and his friends had him do this dance for their entertainment.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Movies</Category>
    <Question>What was the name of the female truck driver who gave Pee-wee a ride in &quot;Pee-wee's Big Adventure&quot; (1985)?</Question>
    <Correct>Large Marge</Correct>
    <Incorrect>Dolores</Incorrect>
    <Incorrect>Rules Jules</Incorrect>
    <Incorrect>Samantha</Incorrect>
    <Info>Pee-wee was hitchhiking across the country in pursuit of his stolen bike, and Large Marge stopped to give him a ride.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Movies</Category>
    <Question>In &quot;The Princess Bride (1987)  Westley and Inigo fought atop the Cliffs of what?&quot;</Question>
    <Correct>Insanity</Correct>
    <Incorrect>Despair</Incorrect>
    <Incorrect>Cacophony</Incorrect>
    <Incorrect>Circumstance</Incorrect>
    <Info>Westley followed Montoya, Vizzini, and Fezzik to the cliffs and climbed up after them. When Westley got to the top, Inigo was waiting for him, and they dueled it out before Westley continued on in pursuit of Vizzini, Fezzik, and, ultimately, Buttercup.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Entertainment</Category>
    <Question>The musical &quot;Cats&quot; is based on a book of poetry about cats. Which American born author wrote these poems?</Question>
    <Correct>T.S.Eliot</Correct>
    <Incorrect>Carl Sandburg</Incorrect>
    <Incorrect>Walt Whitman</Incorrect>
    <Incorrect>Emily Dickinson</Incorrect>
    <Info>T. S. Eliot, who was born in the USA, but lived in England and became a British citizen, wrote &quot;Old Possum's book of Practical Cats. The poems were set to music by Andrew Lloyd Webber.&quot;</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Literature</Category>
    <Question>What fictional character, based on the experiences of an actual sailor, did Daniel Defoe create?</Question>
    <Correct>Robinson Crusoe</Correct>
    <Incorrect>Gulliver</Incorrect>
    <Incorrect>Oliver Twist</Incorrect>
    <Incorrect>Tom Jones</Incorrect>
    <Info>The story of Robinson Crusoe was based on the experiences of Alexander Selkirk, a Scotsman who was shipwrecked on a tropical island.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Geography</Category>
    <Question>Which South American city is laid out in the shape of an airplane?</Question>
    <Correct>Brasilia</Correct>
    <Incorrect>Caracas</Incorrect>
    <Incorrect>Santiago</Incorrect>
    <Incorrect>Montevideo</Incorrect>
    <Info>Brasilia was built to replace Rio de Janiero as the capital of Brazil. The city was inaugurated in 1950.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Hobbies</Category>
    <Question>Which game of Chinese origin, using tiles built into walls, became very popular in the U.S. in the twenties and is still played today?</Question>
    <Correct>Mahjong</Correct>
    <Incorrect>Chess</Incorrect>
    <Incorrect>Go</Incorrect>
    <Incorrect>Chinese Checkers</Incorrect>
    <Info>Mah Jong is a game involving tiles of different suits. It became a real craze in the 1920s.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>History</Category>
    <Question>Which pharaoh of ancient Egypt was the first to build a pyramid?</Question>
    <Correct>Djoser</Correct>
    <Incorrect>Khafre</Incorrect>
    <Incorrect>Cheops</Incorrect>
    <Incorrect>Menkaure</Incorrect>
    <Info>The so-called Step Pyramid of Djoser (or Zoser) was built during the reign of the Third Dynasty (around 2800 B.C.) in Saqqara, Egypt. It was the first pyramid in the history of architecture. It was designed by the architect named Imhotep.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>History</Category>
    <Question>Alexander the Great had a famous horse after whom he named a city. What was the horse's name?</Question>
    <Correct>Bucephalus</Correct>
    <Incorrect>Incitatus</Incorrect>
    <Incorrect>Pegasus</Incorrect>
    <Incorrect>King of the Wind</Incorrect>
    <Info>The horse died in 326 B.C., after the battle on the Hydaspes River. A city there was named after him.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Movies</Category>
    <Question>How did Howard Payne, the terrorist played by Dennis Hopper in &quot;Speed (1994)  ultimately die?&quot;</Question>
    <Correct>Decapitation</Correct>
    <Incorrect>Drowning</Incorrect>
    <Incorrect>Suffocation</Incorrect>
    <Incorrect>Hanging</Incorrect>
    <Info>He was fighting with Jack Traven (Keanu Reeves) atop a subway train and Jack held his head up so that part of the subway tunnel's structure would hit and remove Howard's head. This film also starred Sandra Bullock.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Movies</Category>
    <Question>In &quot;Misery (1990)  what did Annie give Paul that eventually helped him to kill her?&quot;</Question>
    <Correct>Typewriter</Correct>
    <Incorrect>Gun</Incorrect>
    <Incorrect>Cleaver</Incorrect>
    <Incorrect>Screwdriver</Incorrect>
    <Info>Annie (Kathy Bates) had given the typewriter to Paul (James Caan) so that he could finish the manuscript, but at the end she incurred some rather nasty and ultimately fatal head wounds from the machine. This film was adapted by William Goldman from the Stephen King novel of the same name. Rob Reiner directed.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Movies</Category>
    <Question>From what country did Nadia, the foreign exchange student in &quot;American Pie (1999)  hail?&quot;</Question>
    <Correct>Czech Republic</Correct>
    <Incorrect>France</Incorrect>
    <Incorrect>Austria</Incorrect>
    <Incorrect>Finland</Incorrect>
    <Info>Nadia was an exchange student who the guys (especially Jim) were attracted to. She was played by Shannon Elizabeth.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Movies</Category>
    <Question>What was the title of the innovative new book written by the psychiatrist played by Richard Dreyfuss in &quot;What About Bob?&quot; (1991)?</Question>
    <Correct>Baby Steps</Correct>
    <Incorrect>Walk this Way</Incorrect>
    <Incorrect>Facing Your Fears</Incorrect>
    <Incorrect>Into Light</Incorrect>
    <Info>Unfortunately for Dreyfuss' character Leo, Bob (Bill Murray) wasn't satisfied with the book and followed Leo and his family to their New Hampshire vacation destination.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Geography</Category>
    <Question>The Caucasus Mountains run from the Black Sea to which other so-called sea?</Question>
    <Correct>Caspian Sea</Correct>
    <Incorrect>Dead Sea</Incorrect>
    <Incorrect>Red Sea</Incorrect>
    <Incorrect>Adriatic Sea</Incorrect>
    <Info>The Caspian Sea is the world's largest freshwater lake. The Caucasus Mountain range is 750 miles (1,200 kilometers) long. It contains the highest point in Europe, Mount El'brus which has a height of 18,510 feet (5,642 meters).</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Geography</Category>
    <Question>What is the geological term for the debris left behind after a glacier melts?</Question>
    <Correct>moraine</Correct>
    <Incorrect>cirque</Incorrect>
    <Incorrect>morsel</Incorrect>
    <Incorrect>jetsam</Incorrect>
    <Info>The main types of moraine are lateral, medial and terminal.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>People</Category>
    <Question>Among his many other accomplishments, which artist, born in 1881, co-founded the art movement called 'Cubism' with his French counterpart Georges Braque?</Question>
    <Correct>Pablo Picasso</Correct>
    <Incorrect>Jackson Pollock</Incorrect>
    <Incorrect>Henri Matisse</Incorrect>
    <Incorrect>Paul Cezanne</Incorrect>
    <Info>Born Pablo Ruiz Picasso in 1881 to Jose Ruiz and Maria Picasso. Pablo decided to use his mother's last name, rather than the more common last name Ruiz. Picasso created more than 20,000 works of art during his lifetime, and was a huge contributor to the modern art world.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>History</Category>
    <Question>Which French King was known as the 'Sun King'?</Question>
    <Correct>King Louis XIV</Correct>
    <Incorrect>King Louis XVI</Incorrect>
    <Incorrect>King Francis II</Incorrect>
    <Incorrect>King Charles V</Incorrect>
    <Info>Louis XIV was an absolute monarch who ruled France at the height of its glory in the 17th century.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Movies</Category>
    <Question>What 1993 black and white Steven Spielberg drama told the story of a German who attempted to save a number of Jews from the Holocaust?</Question>
    <Correct>Schindler's List</Correct>
    <Incorrect>Shoah</Incorrect>
    <Incorrect>1941</Incorrect>
    <Incorrect>Life Is Beautiful</Incorrect>
    <Info>Oskar Schindler (Liam Neeson) was a real Catholic German factory worker who intially profited from the war, but gradually spent everything trying to save his employees.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Sci / Tech</Category>
    <Question>Your body creates billions of new blood cells every day. Where in your body are red blood cells created?</Question>
    <Correct>Bone marrow</Correct>
    <Incorrect>Heart</Incorrect>
    <Incorrect>Liver</Incorrect>
    <Incorrect>Spleen</Incorrect>
    <Info>Blood is born in the bone marrow and continues to proliferate into more specific kinds of blood cells, each of which have their own separate functions. The scientific term for a red blood cell is 'erythrocyte'.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Movies</Category>
    <Question>At what kind of function or ceremony did the parents in &quot;The Addams Family&quot; (1991) meet?</Question>
    <Correct>Funeral</Correct>
    <Incorrect>Baptism</Incorrect>
    <Incorrect>High School Prom</Incorrect>
    <Incorrect>Bingo Game</Incorrect>
    <Info>They recounted the time they met: &quot;A boy. &quot;A girl.&quot; &quot;An open grave.&quot; The happy if morbid  couple was played by Anjelica Huston and Raul Julia.&quot;</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Movies</Category>
    <Question>In &quot;Breaking the Waves (1996)  Bess (Emily Watson) and Jan (Stellan Skarsgaard) were married  but Jan was in a paralyzing accident. What did he convince Bess to do that she believed would help him recover?&quot;</Question>
    <Correct>have sex with other men</Correct>
    <Incorrect>convert to Islam</Incorrect>
    <Incorrect>move to America</Incorrect>
    <Incorrect>take over his job on the oil rig</Incorrect>
    <Info>At first, Jan told Bess to take another lover and tell him the details, but she believed that her extra-marital acts served as religious penance and were helping Jan to recover, so she started having more and more deviant encounters in the hope it would save her husband.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Movies</Category>
    <Question>Which cleaning device was Mary Sanderson (Kathy Najimy) forced to use instead of a broom in &quot;Hocus Pocus&quot; (1993)?</Question>
    <Correct>vacuum cleaner</Correct>
    <Incorrect>mop</Incorrect>
    <Incorrect>dust buster</Incorrect>
    <Incorrect>feather duster</Incorrect>
    <Info>When the sisters' brooms were stolen, they had to improvise. The only thing left for Mary to ride was a vacuum cleaner. Her sisters were played by Bette Midler and Sarah Jessica Parker.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Movies</Category>
    <Question>Marisa Tomei's character in &quot;My Cousin Vinny&quot; (1992) was an out-of-work what?</Question>
    <Correct>Hairdresser</Correct>
    <Incorrect>Lawyer</Incorrect>
    <Incorrect>Teacher</Incorrect>
    <Incorrect>Photographer</Incorrect>
    <Info>Tomei's character had also been a mechanic, which helped her testify for the defense and prove the boys didn't commit the murder. Tomei played Mona Lisa Vito, the girlfriend of Vincent Gambini (Joe Pesci).</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Music</Category>
    <Question>What musical instrument are all the following associated with: Brian May of Queen, Hank Marvin of The Shadows and The Edge of U2?</Question>
    <Correct>Guitar</Correct>
    <Incorrect>Drums</Incorrect>
    <Incorrect>Keyboards</Incorrect>
    <Incorrect>Saxophone</Incorrect>
    <Info>David Evans is the real name of 'The Edge' and Brian Rankin is the real name of Hank Marvin.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Geography</Category>
    <Question>What is the name of the tallest mountain peak in the European Alps?</Question>
    <Correct>Mont Blanc</Correct>
    <Incorrect>Matterhorn</Incorrect>
    <Incorrect>Eiger</Incorrect>
    <Incorrect>Zugspitze</Incorrect>
    <Info>Mont Blanc lies on the border between France and Italy and its height is 15,771 feet. 'Monte Bianco' is its Italian name.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Geography</Category>
    <Question>In what U.S. city would you find the famous intersection of Haight and Ashbury?</Question>
    <Correct>San Francisco</Correct>
    <Incorrect>New York</Incorrect>
    <Incorrect>Los Angeles</Incorrect>
    <Incorrect>Chicago</Incorrect>
    <Info>In the 60s Haight/Ashbury was a hotbed of hippie activity. Once Starbucks moved in, however, the hippie image began to fade!</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Sports</Category>
    <Question>A rather turbulent melee called a scrummage (or 'scrum') restarts play in which sport?</Question>
    <Correct>Rugby</Correct>
    <Incorrect>Lacrosse</Incorrect>
    <Incorrect>Ice hockey</Incorrect>
    <Incorrect>Cricket</Incorrect>
    <Info>Rugby football originated in the United Kingdom in the 1800's, and is now played worldwide. It is a fast contact sport in which each team tries to get the ball over the opponent's goal line. A scrum restarts play after one of the teams has committed a minor violation, such as a forward pass. In a scrum, the two opposing sets of forwards link themselves together tightly, bending forward from the waist to form a tunnel-like formation. The halfback from the team not responsible for the violation 'feeds' the ball into the tunnel. The two sets of forwards push from opposite sides as soon as the ball enters the scrum. Each side attempts to move the scrum into a position that allows its hooker to heel the ball back through his own team scrum to gain possession.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Geography</Category>
    <Question>Known for its canal, one of the world's longest skating rinks in winter, what is the capital city of Canada?</Question>
    <Correct>Ottawa</Correct>
    <Incorrect>Toronto</Incorrect>
    <Incorrect>Vancouver</Incorrect>
    <Incorrect>Montreal</Incorrect>
    <Info>Although Ottawa is only the fourth largest city in Canada, it is in fact the capital. It sits in eastern Ontario, a couple of hours west of Montreal.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Animals</Category>
    <Question>An insect called the boll weevil is a significant and destructive pest that threatens which crop in the United States?</Question>
    <Correct>cotton</Correct>
    <Incorrect>wheat</Incorrect>
    <Incorrect>soybeans</Incorrect>
    <Incorrect>corn</Incorrect>
    <Info>The boll weevil has a curved snout one half the length of its body. It first invaded the United States in 1892.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>General</Category>
    <Question>What gem did Hindus refer to as the &quot;The Lord of the Gems&quot;?</Question>
    <Correct>Ruby</Correct>
    <Incorrect>Moonstone</Incorrect>
    <Incorrect>Emerald</Incorrect>
    <Incorrect>Amethyst</Incorrect>
    <Info>Hindus referred to the ruby as &quot;The Lord of the Gems  and believed its deep red color came from an inextinguishable fire that was capable of boiling water. It was said that a person should never make faces at a ruby in a museum  and never ignore it  because it would grow dull if slighted or not worn or seen.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Sports</Category>
    <Question>What is the only &quot;Grand Slam&quot; tennis tournament played south of the equator?</Question>
    <Correct>The Australian Open</Correct>
    <Incorrect>New Zealand Open</Incorrect>
    <Incorrect>South American Cup</Incorrect>
    <Incorrect>Wimbledon</Incorrect>
    <Info>The term &quot;Grand Slam originated from Don Budge's achievement of winning the French Open, Winmbledon  the US Open and the Australian Open in 1938.&quot;</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Sports</Category>
    <Question>Zorbing is a sport in which one rolls down a hill encased inside a giant inflatable pvc ball. From what country did this sport originate?</Question>
    <Correct>New Zealand</Correct>
    <Incorrect>Australia</Incorrect>
    <Incorrect>India</Incorrect>
    <Incorrect>Britain</Incorrect>
    <Info>The idea is that as the ball rolls around, the person inside (known as &quot;the Zorbonaut) becomes pinned to the inside by centrifugal force.&quot;</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>General</Category>
    <Question>Near the equator, there are areas where there is little to no wind. What are these areas called?</Question>
    <Correct>doldrums</Correct>
    <Incorrect>maelstroms</Incorrect>
    <Incorrect>pyreheneses</Incorrect>
    <Incorrect>indigos</Incorrect>
    <Info>The Doldrums are an area of low pressure occurring where the trade winds meet along the equator. Winds here are usually calm or very light. Sailors have been known to get &quot;stuck in the doldrums,  run out of rations, and starve before reaching land.&quot;</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Sci / Tech</Category>
    <Question>You set off on a journey to the closest star to Earth. Where are you going?</Question>
    <Correct>The sun</Correct>
    <Incorrect>Alpha Centauri</Incorrect>
    <Incorrect>Proxima Centauri</Incorrect>
    <Incorrect>Sirius</Incorrect>
    <Info>People tend to forget that the sun is a star! As stars go, it's pretty small and weak.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Sci / Tech</Category>
    <Question>In the 'Star Trek' television series, spacecraft used deuterium to fuel their warp drives. Deuterium is a form of what element?</Question>
    <Correct>Hydrogen</Correct>
    <Incorrect>Carbon</Incorrect>
    <Incorrect>Oxygen</Incorrect>
    <Incorrect>Nitrogen</Incorrect>
    <Info>Deuterium is an isotope, or form, of hydrogen. Regular hydrogen has one proton and one neutron, deuterium has one proton and two neutrons.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Sci / Tech</Category>
    <Question>What is the most widely-consumed addictive chemical substance in the world?</Question>
    <Correct>Caffeine</Correct>
    <Incorrect>Alcohol</Incorrect>
    <Incorrect>Marijuana</Incorrect>
    <Incorrect>Nicotine</Incorrect>
    <Info>In the United States alone, over 80% of adults ingest enough caffeine daily to cause physiological and behavioral effects. Caffeine is consumed in many forms, from tea to chocolate to chewing kola nuts.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Sci / Tech</Category>
    <Question>It was the Age of Dinosaurs. During which era of geologic time did dinosaurs dominate the world?</Question>
    <Correct>Mesozoic</Correct>
    <Incorrect>Paleozoic</Incorrect>
    <Incorrect>Cenozoic</Incorrect>
    <Incorrect>Jurassic</Incorrect>
    <Info>Mesozoic&quot; means &quot;middle life era.&quot; This era ended 65 million years ago.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Geography</Category>
    <Question>What is the former name of the second-highest mountain on earth, now referred to as 'K2'?</Question>
    <Correct>Mt. Godwin-Austen</Correct>
    <Incorrect>Mt. Kilimanjaro</Incorrect>
    <Incorrect>Mt. Huascaran</Incorrect>
    <Incorrect>Mt. Erebus</Incorrect>
    <Info>At over 28 thousand feet, K2 is only surpassed by Mt. Everest in height. It is situated in the Karakoram Range in the Pakistani portion of Kashmir, a disputed region between Pakistan and India.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Sci / Tech</Category>
    <Question>The chemical symbols for molybednum, sulphur, cobalt and tungsten, in that order, together spell out the name of which world capital?</Question>
    <Correct>Moscow</Correct>
    <Incorrect>Muscat</Incorrect>
    <Incorrect>Madrid</Incorrect>
    <Incorrect>Maputo</Incorrect>
    <Info>The symbols for molybdenum (Mo), tin (S), cobalt (Co) and tungsten (W) together spell out 'Moscow', which is the capital of the Russian Federation.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>People</Category>
    <Question>Which English King was the father of two English Queens?</Question>
    <Correct>Henry VIII</Correct>
    <Incorrect>George VI</Incorrect>
    <Incorrect>William I</Incorrect>
    <Incorrect>Edward VI</Incorrect>
    <Info>Henry VIII was the father of both Queen Mary, also known as 'Bloody Mary', and Queen Elizabeth I. These three monarchs dominated 16th century English politics.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Religion</Category>
    <Question>Which world religion is said to have been conceived by a semi-mythical Chinese philosopher called Lao-Tzu?</Question>
    <Correct>Taoism</Correct>
    <Incorrect>Confucianism</Incorrect>
    <Incorrect>Shintoism</Incorrect>
    <Incorrect>Buddhism</Incorrect>
    <Info>Taoism is also alternatively spelled 'Daoism'. Lao-tzu (whose real name was Li Er) is generally listed as the founder of Taoism and author of its primary text, the 'Tao Te Ching'.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>History</Category>
    <Question>Which long reigning monarch ruled Britain and the British Empire when the twentieth century began?</Question>
    <Correct>Queen Victoria</Correct>
    <Incorrect>King Edward VII</Incorrect>
    <Incorrect>King George V</Incorrect>
    <Incorrect>Queen Elizabeth I</Incorrect>
    <Info>Queen Victoria came to the throne at the age of twenty in 1837. She celebrated her Diamond Jubilee in 1897 and went on to reign four more years. She died in 1901.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>History</Category>
    <Question>Whom did Stalin expel from the USSR in 1929?</Question>
    <Correct>Trotsky</Correct>
    <Incorrect>Nicholas II</Incorrect>
    <Incorrect>Lenin</Incorrect>
    <Incorrect>Chekov</Incorrect>
    <Info>Leon Trotsky lead the Bolshevik revolution of 1917. He was expelled because of his opposition to Stalin.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Entertainment</Category>
    <Question>The first issue of Playboy came out in 1953. Who was on the cover?</Question>
    <Correct>Marilyn Monroe</Correct>
    <Incorrect>Betty Grable</Incorrect>
    <Incorrect>Jayne Mansfield</Incorrect>
    <Incorrect>Sophia Loren</Incorrect>
    <Info>The photo used was one taken in 1949 and used on a calendar. There was no date on the cover of the first issue of &quot;Playboy&quot; as Hugh Hefner wasn't sure there would be a second issue!</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Entertainment</Category>
    <Question>Cartoonist Al Capp died in 1979. Which comic strip did he create?</Question>
    <Correct>Li'l Abner</Correct>
    <Incorrect>Archie</Incorrect>
    <Incorrect>Peanuts</Incorrect>
    <Incorrect>Calvin and Hobbs</Incorrect>
    <Info>Li'L Abner&quot; cartoon strips first appeared in newspapers in 1934 and continued until 1977.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Sports</Category>
    <Question>In 1903, who hit the first World Series home run in history?</Question>
    <Correct>Jimmy Sebring</Correct>
    <Incorrect>Jimmy Collins</Incorrect>
    <Incorrect>Patsy Dougherty</Incorrect>
    <Incorrect>Honus Wagner</Incorrect>
    <Info>A member of the Series-losing Pittsburgh Pirates, Sebring put the great Cy Young over the fence to claim this unique achievement in 1903. The Boston Pilgrims won the series 5-3.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Sports</Category>
    <Question>In the 1986 NFL Draft, what player was selected with the number one overall selection, but didn't sign with the team, instead playing baseball that year?</Question>
    <Correct>Bo Jackson</Correct>
    <Incorrect>Deion Sanders</Incorrect>
    <Incorrect>Ricky Bell</Incorrect>
    <Incorrect>Lawrence Elkins</Incorrect>
    <Info>Bo was drafted by the Tampa Bay Buccaneers in 1986, but opted to play baseball with the Kansas City Royals rather than wear those awful orange uniforms. He later landed with the Raiders, where he became famous as a two-sport star.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Sports</Category>
    <Question>Which Buffalo Brave set the NBA record by playing in more than 900 consecutive games?</Question>
    <Correct>Randy Smith</Correct>
    <Incorrect>Kareem Abdul-Jabbar</Incorrect>
    <Incorrect>Robert Parish</Incorrect>
    <Incorrect>Paul Silas</Incorrect>
    <Info>The Buffalo Braves drafted Smith in the seventh round, the 104th pick overall in 1971. He went on to set an NBA record of 906 consecutive games played from 1972 to 1983.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Sports</Category>
    <Question>The Paris to Dakar car and motorcycle rally is one of the world's toughest tests for man and machine, but in which country is Dakar?</Question>
    <Correct>Senegal</Correct>
    <Incorrect>Chad</Incorrect>
    <Incorrect>Mali</Incorrect>
    <Incorrect>Niger</Incorrect>
    <Info>The route involves crossing the Sahara Desert. Generally, less than 30% of starters actually finish the 6,000 mile trip.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Sports</Category>
    <Question>William Taft was President in the year the first Indianapolis 500 took place. What year was this?</Question>
    <Correct>1911</Correct>
    <Incorrect>1906</Incorrect>
    <Incorrect>1914</Incorrect>
    <Incorrect>1921</Incorrect>
    <Info>The first Indianapolis 500 was won by Ray Harroun, who completed it in six hours, forty-two minutes and eight seconds. His average speed was 74.602 mph.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>History</Category>
    <Question>The first meeting of the UN took place in London, on January 10, 1946. Who was the first Secretary-General?</Question>
    <Correct>Trygve Lie</Correct>
    <Incorrect>Dag Hammarskjold</Incorrect>
    <Incorrect>Kurt Waldheim</Incorrect>
    <Incorrect>U Thant</Incorrect>
    <Info>Trygve Lie was a Norwegian politician, who was minister of foreign affairs in the Norwegian government-in-exile in London during WWII, a time when Norway was occupied by the Germans. He resigned his position as secretary-general in 1952 and was succeeded by the Swedish Dag Hammarskjold</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Animals</Category>
    <Question>In the animal kingdom the adult male and female often have different names. What is the name of the male swan?</Question>
    <Correct>Cob</Correct>
    <Incorrect>Pen</Incorrect>
    <Incorrect>Drake</Incorrect>
    <Incorrect>Tom</Incorrect>
    <Info>The female is known as a pen, and the young are cygnets. Swans mate for life and can live to be over thirty years old.</Info>
   </MultipleChoice>
   <MultipleChoice>
    <Category>Television</Category>
    <Question>The theme song of a 70s TV show includes the line &quot;Gee, our old LaSalle ran great. What was the show?&quot;</Question>
    <Correct>All in the Family</Correct>
    <Incorrect>Happy Days</Incorrect>
    <Incorrect>Laverne and Shirley</Incorrect>
    <Incorrect>The Jeffersons</Incorrect>
    <Info>The multiple Emmy winning show &quot;All in the Family&quot; was first seen in January 1971. The opening theme song was &quot;Those Were the Days&quot;.</Info>
   </MultipleChoice>
 </Questions>;
}
}
