[0,2,3,5,7,8,10] @=> int aeolianScale[];
[0,2,3,5,7,9,11] @=> int dorianScale[];
[0,2,4,5,7,9,10] @=> int mixolydianScale[];
[0,2,4,5,7,9,11] @=> int ionianScale[];
[0,2,4,6,7,9,11] @=> int lydianScale[];
[0,1,3,4,6,7,9,10] @=> int octatonicScale[];
[0,2,4,7,9] @=> int majorPentatonicScale[];
[0,3,5,7,10] @=> int minorPentatonicScale[];

[0,4,3,6,1,5,2] @=> int diatonicWeights[];
[0,3,2,4,1] @=> int pentatonicWeights[];
[0,5,4,2,1,6,3,7] @=> int octatonicWeights[];

[aeolianScale,dorianScale,minorPentatonicScale,majorPentatonicScale,mixolydianScale,ionianScale,lydianScale,octatonicScale] @=> int allScales[][];
[diatonicWeights,diatonicWeights,pentatonicWeights,pentatonicWeights,diatonicWeights,diatonicWeights,diatonicWeights,octatonicWeights] @=> int allWeights[][];
allScales.size() => int numScales;
-4 => int root;
3 => int whichScale;
[60,200] @=> int tempoRange[];
[21,55] @=> int lowPitchRange[];
[67,108] @=> int highPitchRange[];
[1,4] @=> int rhythmicValues[]; // powers of 2 - half notes to 16th notes

[0,8,12,4,14,6,10,2,15,7,11,3,13,5,9,1] @=> int beatWeights[];
144 => float bpm;

NRev rev => dac;
0.1 => rev.mix;
3 => dac.gain;

majorPentatonicScale @=> int scale[];
pentatonicWeights @=> int weights[];

FluidMelody highMelody;
FluidBass bassLine;
FluidMelody percussion;

highMelody.set(7,72,96,8,0,0);
highMelody.play();
0.5 => highMelody.m.gain;

bassLine.set(48,4,0);
bassLine.play();

percussion.changeVoice("soundfonts/Scratch_2_0.sf2",9);
percussion.set(3,36,60,8,0.5,0.2);
percussion.play();


while (true)
{
  Math.random2(-1,1) +=> root;
  Math.random2(-1,1) +=> whichScale;
  if (whichScale < 0)  0 => whichScale;
  if (whichScale >= allScales.size()) allScales.size() - 1 => whichScale;
  allScales[whichScale] @=> scale;
  allWeights[whichScale] @=> weights;
  Math.random2(0,16) => highMelody.density;
  Math.random2f(0,0.75) => highMelody.syncopation;
  Math.random2f(0,1) => highMelody.disjunct;
  Math.random2(0,8) => bassLine.density;
  Math.random2f(0,0.5) => bassLine.syncopation;
  Math.random2(0,16) => percussion.density;
  Math.random2f(0,1) => percussion.syncopation;
  Math.random2f(0,1) => percussion.disjunct;
  Math.random2f(-10,10) +=> bpm;
  15::second => now;
}

class FluidMelody
{
  int channel;
  int octave;
  int lowBarrier;
  int highBarrier;
  int density;
  float syncopation;
  float disjunct;

  "soundfonts/Salamander_C5-v3-MR-HEDSounds.sf2" => string sfont;
  FluidSynth m => rev;
  m => dac;
  1 => m.gain;
  m.open(sfont);

  ScaleNote note;

  fun void changeVoice(string path, int chan)
  {
    m.open(path);
    chan => channel;
  }

  fun void set(int oct, int low, int high, int den, float sync, float disj)
  {
    oct => octave;
    low => lowBarrier;
    high => highBarrier;
    den => density;
    sync => syncopation;
    disj => disjunct;
    lowBarrier => note.lowBarrier;
    highBarrier => note.highBarrier;
    octave => note.octave;
    disjunct => note.disjunct;
  }

  fun void play()
  {
    spork ~ playShred();
  }

  fun void playShred()
  {
    while (true)
    {
      lowBarrier => note.lowBarrier;
      highBarrier => note.highBarrier;
      disjunct => note.disjunct;
      rhythmicPattern(density,syncopation) @=> int test[];
      for (int i; i < test.size(); i++)
      {
        pulse() * Math.random2f(0,0.1) => dur humanize;
        humanize => now;
        if (test[i])
        {
          m.noteOff(note.getLast()+root,channel);
          m.noteOn(note.nextNote()+root,Math.random2(64,127),channel);
        }
        (pulse() - humanize) => now;
      }
    }
  }
}

class FluidBass
{
  3 => int channel;
  int lowBarrier;
  int highBarrier;
  int density;
  float syncopation;

  "soundfonts/Nice-4-Bass-V1.5.sf2" => string sfont;
  FluidSynth m => rev;
  m => dac;
  1 => m.gain;
  m.open(sfont);

  HarmonyNote note;

  fun void changeVoice(string path, int chan)
  {
    m.open(path);
    chan => channel;
  }

  fun void set(int low, int den, float sync)
  {
    low => lowBarrier;
    den => density;
    sync => syncopation;
    lowBarrier => note.lowBarrier;
  }

  fun void play()
  {
    spork ~ playShred();
  }

  fun void playShred()
  {
    while (true)
    {
      lowBarrier => note.lowBarrier;
      rhythmicPattern(density,syncopation) @=> int test[];
      for (int i; i < test.size(); i++)
      {
        pulse() * Math.random2f(0,0.1) => dur humanize;
        humanize => now;
        if (test[i])
        {
          m.noteOff(note.getLast()+root,channel);
          m.noteOn(note.nextNote()+root,Math.random2(64,127),channel);
        }
        (pulse() - humanize) => now;
      }
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
  high => float result;
  repeat (4)
  {
    Math.random2f(low,high) => float tempVal;
    if (tempVal < result) tempVal => result;
  }
  return result;
}

class ScaleNote
{
  int octave;
  float disjunct;
  int scaleIndex;
  21 => int lowBarrier;
  108 => int highBarrier;
  60 => int last;

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

class HarmonyNote
{
  int octave;
  21 => int lowBarrier;
  60 => int last;
  60 => int note;

  fun int nextNote ()
  {
    lowRand(0,weights.size())$int => int scalePick;
    scale[weights[scalePick]] => int bassPitch;
    while (bassPitch < lowBarrier) 12 +=> bassPitch;
    note => last;
    bassPitch => note;
    return note;
  }

  fun int getLast()
  {
    return last;
  }
}
