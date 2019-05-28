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

//[aeolianScale,dorianScale,minorPentatonicScale,majorPentatonicScale,mixolydianScale,ionianScale,lydianScale,octatonicScale] @=> int allScales[][];
[octatonicScale, lydianScale, ionianScale, majorPentatonicScale, minorPentatonicScale, dorianScale, aeolianScale,
dorianScale, minorPentatonicScale, majorPentatonicScale, ionianScale, lydianScale, octatonicScale] @=> int allScales[][];
[octatonicWeights, diatonicWeights, diatonicWeights, pentatonicWeights, pentatonicWeights, diatonicWeights, diatonicWeights,
diatonicWeights, pentatonicWeights, pentatonicWeights, diatonicWeights, diatonicWeights, octatonicWeights] @=> int allWeights[][];
//[diatonicWeights,diatonicWeights,pentatonicWeights,pentatonicWeights,diatonicWeights,diatonicWeights,diatonicWeights,octatonicWeights] @=> int allWeights[][];

allScales.size() => int numScales;
0 => int root;
6 => int oldScale;

[0,8,12,4,14,6,10,2,15,7,11,3,13,5,9,1] @=> int beatWeights[];
144 => float bpm;

NRev rev => dac;
0.1 => rev.mix;
3 => dac.gain;

//dac => WvOut2 w => blackhole;
//"img2music" => w.wavFilename;
//null @=> w;

spork ~ processOSC();

majorPentatonicScale @=> int scale[];
pentatonicWeights @=> int weights[];

FluidMelody highMelody;
FluidBass bassLine;
FluidMelody percussion;
FluidChords chords;

highMelody.set(7,72,19,0,0,0);
0.5 => highMelody.m.gain;

bassLine.set(48,4,0);

percussion.changeVoice("soundfonts/Scratch_2_0.sf2",9);
percussion.set(3,24,35,0,0.5,0.2);

0.5 => chords.syncopation;

now => time start;
while (true)
{
  <<< (now - start)/second, "seconds elapsed" >>>;
  <<< "highMelody.density",highMelody.density >>>;
  15::second => now;
}

//w.closeFile();

//-----------------------------------------------------------------------

class FluidMelody
{
  int channel;
  int octave;
  int lowBarrier;
  int range;
  int density;
  float syncopation;
  float disjunct;

  "soundfonts/Salamander_C5-v3-MR-HEDSounds.sf2" => string sfont;
  FluidSynth m  => rev;
  m => dac;
  m.open(sfont);

  ScaleNote note;

  fun void changeVoice(string path, int chan)
  {
    m.open(path);
    chan => channel;
  }

  fun void set(int oct, int low, int ran, int den, float sync, float disj)
  {
    oct => octave;
    low => lowBarrier;
    ran => range;
    den => density;
    sync => syncopation;
    disj => disjunct;
    lowBarrier => note.lowBarrier;
    range => note.range;
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
      range => note.range;
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
  24 => int range;
  60 => int last;

  fun int nextNote ()
  {
    (1 + ((scale.size()-1) * disjunct))$int => int maxLeap;
    scale[scaleIndex % scale.size()] + 12*octave => last;
      Math.random2(0, maxLeap) => int leapSize;
      if (maybe) -1 *=> leapSize;
      leapSize +=> scaleIndex;
      while (scaleIndex < 0)
      {
        scale.size() +=> scaleIndex;
        octave--;
      }
      while (scaleIndex >= scale.size())
      {
        scale.size() -=> scaleIndex;
        octave++;
      }
      scale[scaleIndex % scale.size()] + (12 * octave) => int testNote;
      while (testNote < lowBarrier)
      {
        octave++;
        12 +=> testNote;
      }
      while (testNote > lowBarrier + range)
      {
        octave--;
        12 -=> testNote;
      }
    return testNote;
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

class FluidChords
{
  3 => int numPitches;
  12 => int width;
  48 => int lowBarrier;
  int arpLen; // 0 - 4 pulses
  int channel;
  4 => int density;
  0.75 => float syncopation;

  "soundfonts/Salamander_C5-v3-MR-HEDSounds.sf2" => string sfont;
  FluidSynth m  => rev;
  m => dac;
  m.open(sfont);

  fun void changeVoice(string path, int chan)
  {
    m.open(path);
    chan => channel;
  }

  fun int fitToScale (float input)
  {
    200 => float bestDist;
    73 => int closestNote;
    for (int oct; oct < 10; oct++)
    {
      for (int i; i < scale.size(); i++)
      {
        (12 * oct) + scale[i] => int testNote;
        Math.fabs(input - testNote) => float testDist;
        if (testDist < bestDist)
        {
          testDist => bestDist;
          testNote => closestNote;
        }
        if (testDist > bestDist) return closestNote;
      }
    }
  }

  fun void play()
  {
    spork ~ playShred();
  }

  fun void playShred()
  {
    while (true)
    {
      rhythmicPattern(density,syncopation) @=> int test[];
      for (int i; i < test.size(); i++)
      {
        if (test[i])
        {
          spork ~ oneChord();
        }
        4*pulse() => now;
      }
    }
  }
  fun void oneChord()
  {
    pulse() * arpLen / numPitches => dur arp;
    lowBarrier + Math.random2(-1,1) => int thisLowBarrier;
    width + Math.random2(-1,1) => int thisWidth;
    thisWidth/(numPitches - 1.0) => float dist;
    for (int j; j < numPitches; j++)
    {
      thisLowBarrier + (j * dist) => float pureSplit;
      fitToScale(pureSplit) => int fitSplit;
      m.noteOn(fitSplit+root,Math.random2(40,80),channel);
      arp => now;
    }
  }
}

fun float flerp (float in, float low, float high)
{
  return low + ((high-low)*in);
}

fun int ilerp (float in, int low, int high)
{
  return (low + ((1+high-low)*in))$int;
}

fun float clamp (float in, float low, float high)
{
  if (in < low) return low;
  if (in > high) return high;
  return in;
}

fun void processOSC()
{
  OscIn oin;
  OscMsg msg;
  53186 => oin.port;
  oin.addAddress( "/torch, ifff" );
  while (true)
  {
    oin => now;
    while ( oin.recv(msg) != 0 )
    {
        msg.getInt(0) => int whichTrack;
        msg.getFloat(1) => float hue;
        msg.getFloat(2) => float sat;
        msg.getFloat(3) => float br;
        //<<< "track",whichTrack,"hue:",hue,"sat:",sat,"br:",br >>>;
        if (99 == whichTrack) // start!
        {
          flerp(br,88,212) => bpm;
          highMelody.play();
          bassLine.play();
          percussion.play();
          chords.play();
        }
        if (0 == whichTrack) // master controls
        {
          ilerp (hue, 0, 12) => int newScale;
          if (newScale != oldScale && Math.abs(newScale - oldScale) < 11)
          {
            allScales[newScale] @=> scale;
            allWeights[newScale] @=> weights;
            Math.random2(-1,1) +=> root;
            newScale => oldScale;
          }
          ilerp (sat, 60, 24) => bassLine.lowBarrier;
          ilerp (sat, 60, 48) => chords.lowBarrier;
          ilerp (sat, 60, 84) => highMelody.lowBarrier;
          ilerp (br, 13, 36) => highMelody.range;
        }
        if (1 == whichTrack) // highMelody
        {
          hue => highMelody.disjunct; // band 1 - sat
          ilerp (sat, 0, 6) => highMelody.density; // band 1 - br
          br => highMelody.syncopation; // hue
        }
        if (2 == whichTrack)
        {
          ilerp(br, 7, 24) => chords.width;
          ilerp(sat, 4, 0) => chords.arpLen;
          ilerp(hue,8, 0) => chords.density; // band 2 - random (or inverse sat)
          ilerp(br, 2, 8) => chords.numPitches;
        }
        if (3 == whichTrack)
        {
          br => percussion.syncopation; // band 3 - hue
          hue => percussion.disjunct; // band 3 - sat
          ilerp(sat,0,16) => percussion.density; // band 3 - br
        }
        if (4 == whichTrack)
        {
          ilerp(hue,30,60) => bassLine.lowBarrier; // band 4 - hue
          sat * 0.5 => bassLine.syncopation; // band 4 - sat
          ilerp(br,0,8) => bassLine.density; // band 4 - br
        }
        if (-1 == whichTrack) // fade out
        {
          <<< "It's over!" >>>;
        }
    }
  }
}
