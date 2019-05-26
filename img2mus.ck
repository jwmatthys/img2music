[0,2,3,5,7,8,10] @=> int aeolianScale[];
[0,2,3,5,7,9,11] @=> int dorianScale[];
[0,2,4,5,7,9,10] @=> int mixolydianScale[];
[0,2,4,5,7,9,11] @=> int ionianScale[];
[0,2,4,6,7,9,11] @=> int lydianScale[];
[0,1,3,4,6,7,9,10] @=> int octatonicScale[];
[0,2,4,7,9] @=> int majorPentatonicScale[];
[0,3,5,7,10] @=> int minorPentatonicScale[];

[40,180] @=> int tempoRange[];
[21,55] @=> int lowPitchRange[];
[67,108] @=> int highPitchRange[];
[1,4] @=> int rhythmicValues[]; // powers of 2 - half notes to 16th notes

[0,8,12,4,14,6,10,2,15,7,11,3,13,5,9,1] @=> int beatWeights[];
196 => float bpm;

NRev rev => dac;
0.1 => rev.mix;

minorPentatonicScale @=> int scale[];
spork ~ oneVoice(6,48,84,12,1,1);
spork ~ oneVoice(5,48,72,15,1,1);
spork ~ oneVoice(4,36,60,2,1,0);
minute => now;


fun void oneVoice(int oct, int low, int high, int density, float synco, float disjunct)
{
  "soundfonts/Salamander_C5-v3-MR-HEDSounds.sf2" => string sfont;
  if(me.args() > 0) me.arg(0) => sfont;

  FluidSynth m => rev;
  m => dac;
  1 => m.gain;
  m.open(sfont);

  ScaleNote note;
  low => note.lowBarrier;
  high => note.highBarrier;
  oct => note.octave;
  disjunct => note.disjunct;

  while (true)
  {
    rhythmicPattern(density,synco) @=> int test[];
    for (int i; i < test.size(); i++)
    {
      if (test[i])
      {
        m.noteOff(note.getLast(),0);
        m.noteOn(note.nextNote(),Math.random2(64,127),0);
      }
      pulse() => now;
    }
  }
}

fun dur pulse ()
{
  return 30::second / bpm;
}

fun int[] rhythmicPattern (int density, float syncopation)
{
  int output[16];
  density => int pitchesLeft;
  float interpBeatWeights[16];
  for (int i; i < 16; i++)
  {

    1 + ((beatWeights[i] - 1) * (1-syncopation)) => interpBeatWeights[i];
  }
  while (pitchesLeft)
  {
    lowRand(0,density + syncopation*(16-density))$int => int pick;
    beatWeights[pick] => int beatPosition;
    if (!output[beatPosition])
    {
      1 => output[beatPosition];
      pitchesLeft--;
    }
  }
  return output;
}

fun int weightedRandom (float weights[])
{
  float sum;
  for (int i; i < weights.size(); i++) weights[i] +=> sum;
  Math.random2f(0,sum) => float randval;
  for (int i; i < weights.size(); i++)
  {
    if (randval <= weights[i])
    {
      //<<< weights.size(), i >>>;
      return i;
    }
    else weights[i] -=> randval;
  }
  return 0;
}

fun float lowRand (float low, float high)
{
  return Math.min (Math.random2f(low,high), Math.random2f(low,high));
}

class ScaleNote
{
  int octave;
  float disjunct;
  int scaleIndex;
  21 => int lowBarrier;
  108 => int highBarrier;
  int last;

  fun int nextNote ()
  {
    (1 + ((scale.size()-1) * disjunct))$int => int maxLeap;
    scale[scaleIndex % scale.size()] + 12*octave => last;
    while (true)
    {
      scaleIndex => int testScaleIndex;
      octave => int testOctave;
      Math.random2(0, maxLeap) => int leapSize;
      if (maybe) -1 *=> leapSize;
      if (leapSize == 0) break;
        leapSize +=> testScaleIndex;
        while (testScaleIndex < 0)
        {
          scale.size() +=> testScaleIndex;
          octave++;
        }
        while (testScaleIndex >= scale.size())
        {
          scale.size() -=> testScaleIndex;
          octave--;

        }

      scale[testScaleIndex % scale.size()] + (12 * testOctave) => int testNote;
      if (testNote >= lowBarrier && testNote <= highBarrier)
      {
        testOctave => octave;
        testScaleIndex => scaleIndex;
        break;
      }
    }
    //<<< note, scaleIndex >>>;
    return scale[scaleIndex % scale.size()] + 12*octave;
  }

  fun int getLast()
  {
    return last;
  }
}
