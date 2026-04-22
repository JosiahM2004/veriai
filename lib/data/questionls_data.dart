import '../models/question.dart';

const List<Question> formalQuestions = [
  Question(
    id: 'f1',
    contextInfo: 'Read the following and decide if it is AI or human written.',
    content: 'Biscuit the golden retriever had been eyeing Gerald the tabby all morning — the cat was round as a bowling ball and twice as smug, sunbathing on the patio like he owned the place. Unable to resist, Biscuit trotted over and gave the chubby cat one long, enthusiastic lick from chin to ears. Gerald opened one eye, utterly unamused, then slowly turned away as if the whole incident had never happened. Biscuit wagged his tail anyway. Close enough.',
    isAI: true,
    explanation: 'This was AI generated. The prompt was: generate a small story about a dog eating a chubby cat, max 1 paragraph.',
    type: ContentType.formal,
  ),
  Question(
    id: 'f2',
    contextInfo: 'Read the following and decide if it is AI or human written.',
    content: 'All insects possesses a pair of antennae, but they may be greatly reduced, especially in larval forms. Among the non-insect Hexapoda, Collembola and Diplura have antennae, but Protura do not.',
    isAI: false,
    explanation: 'This was human written. Taken from a book called The Insects Structure and Function by R. F. Chapman',
    type: ContentType.formal,
  ),
];

const List<Question> informalQuestions = [
  Question(
    id: 'i1',
    contextInfo: 'Read the following and decide if it is AI or human written.',
    content: 'Oh sweetheart!! Your grandpa Harold would be SO proud of you!! I cried happy tears when your mum told me!! The NAVY!! My grandson!! I have already told Margaret next door and she says congratulations too. You make sure you eat properly and write to me when you can. I love you to the moon and back. All my love Gran xxx.',
    isAI: true,
    explanation: 'This was AI generated. The prompt was: generate a text message from an old lady to her grandson congratulating him on getting into the navy ',
    type: ContentType.informal,
  ),
  Question(
    id: 'i2',
    contextInfo: 'Read the following and decide if it is AI or human written.',
    content: 'According to the census of 1980 there were 3.5 million Asian Americans in the United States, about 1.5 percent of the total population.',
    isAI: false,
    explanation: 'This was human written. Taken from a book called Asian America by Roger Daniels',
    type: ContentType.informal,
  ),
];
