
"soundfonts/Salamander_C5-v3-MR-HEDSounds.sf2" => string sfont;
if(me.args() > 0) me.arg(0) => sfont;

NRev rev => dac;
0.01 => rev.mix;
FluidSynth m => rev;
m => dac;
1 => m.gain;
m.open(sfont);

fun void playNote (int note, int vel, dur len)
{
  m.noteOn(note,vel,0);
  len => now;
  m.noteOff(note,0);
}

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

spork ~ oneVoice(5,60,84);
spork ~ oneVoice(6,60,84);
spork ~ oneVoice(4, 36,60);
spork ~ oneVoice(3, 24,48);

minute => now;

fun void oneVoice(int oct, int low, int high)
{
  ScaleNote note;
  note.setScale(mixolydianScale);
  low => note.lowBarrier;
  high => note.highBarrier;
  oct => note.octave;
  0.5 => note.disjunct;
  while (true)
  {
    rhythmicPattern(4,0) @=> int test[];
    for (int i; i < test.size(); i++)
    {
      if (test[i]) spork ~ playNote(note.nextNote(),127,(2000/4)::ms);
      125::ms => now;
    }
  }
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
    weightedRandom(interpBeatWeights) => int choice;
    if (!output[choice])
    {
      1 => output[choice];
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
  int scale[];
  int scaleLength;
  int octave;
  float disjunct;
  int scaleIndex;
  21 => int lowBarrier;
  108 => int highBarrier;

  fun void setScale (int newScale[])
  {
    newScale.size() => scaleLength;
    newScale @=> scale;
    for (int i; i < scale.size(); i++) newScale[i] => scale[i];
    if (scaleIndex >= scaleLength) (scaleIndex % scaleLength) => scaleIndex;
  }

  fun int nextNote ()
  {
    (2 + (scaleLength * disjunct))$int => int maxLeap;
    while (true)
    {
      scaleIndex => int testScaleIndex;
      octave => int testOctave;
      Math.random2f(-maxLeap, maxLeap)$int => int leapSize;
      if (leapSize == 0) break;
      leapSize +=> testScaleIndex;
      if (leapSize == scaleLength || testScaleIndex >= scaleLength) testOctave++;
      if (leapSize == -scaleLength || testScaleIndex < 0) testOctave--;
      (testScaleIndex + scaleLength) % scaleLength => testScaleIndex;
      scale[testScaleIndex] + (12 * testOctave) => int testNote;
      if (testNote >= lowBarrier && testNote <= highBarrier)
      {
        testOctave => octave;
        testScaleIndex => scaleIndex;
        break;
      }
      50::ms => now;
    }
    //<<< note, scaleIndex >>>;
    return scale[scaleIndex] + 12*octave;
  }
}
