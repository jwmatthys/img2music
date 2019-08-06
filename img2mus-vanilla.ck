[0,2,3,5,7,8,10] @=> int aeolianScale[];
[0,2,3,5,7,9,11] @=> int dorianScale[];
[0,2,4,5,7,9,10] @=> int mixolydianScale[];
[0,2,4,5,7,9,11] @=> int ionianScale[];
[0,2,4,6,7,9,11] @=> int lydianScale[];
[0,1,3,4,6,7,9,10] @=> int octatonicScale[];
[0,2,4,7,9] @=> int majorPentatonicScale[];
[0,3,5,7,10] @=> int minorPentatonicScale[];
[0,3,4,7,8,11] @=> int augmentedScale[];

[0,4,3,6,1,5,2] @=> int diatonicWeights[];
[0,3,2,4,1] @=> int pentatonicWeights[];
[0,5,4,2,1,6,3,7] @=> int octatonicWeights[];
[0,3,4,1,2,5] @=> int augmentedWeights[];

[augmentedScale,aeolianScale,dorianScale,minorPentatonicScale,majorPentatonicScale,mixolydianScale,ionianScale,lydianScale,octatonicScale] @=> int allScales[][];
[augmentedWeights,diatonicWeights,diatonicWeights,pentatonicWeights,pentatonicWeights,diatonicWeights,diatonicWeights,diatonicWeights,octatonicWeights] @=> int allWeights[][];

allScales.size() => int numScales;
0 => int root;
6 => int oldScale;

[0,8,12,4,14,6,10,2,15,7,11,3,13,5,9,1] @=> int beatWeights[];
144 => float bpm;

NRev rev => Envelope masterFader => dac;
15::second => masterFader.duration;
1 => masterFader.value;
0.2 => rev.mix;
5 => dac.gain;

1=> int count;

spork ~ processOSC();

majorPentatonicScale @=> int scale[];
pentatonicWeights @=> int weights[];

VanillaMelody highMelody;
VanillaBass bassLine;
VanillaPercussion percussion;
VanillaChords chords;
Cloud cloud;

highMelody.set(7,72,19,0,0,0);
0.2 => highMelody.m.gain;

bassLine.set(36,4,0);
0.15 => bassLine.m.gain;

percussion.set(0,22,0,0.5);
2 => percussion.m.gain;

0.5 => chords.syncopation;
0.5 => chords.m.gain;

0.5 => cloud.m.gain;

now => time start;
second => now;
while (true)
{
  //<<< ((now - start)/minute)$int, "minutes elapsed" >>>;
  30::second => now;
}

//w.closeFile();

//-----------------------------------------------------------------------

class VanillaMelody
{
  int channel;
  int octave;
  int lowBarrier;
  int range;
  int density;
  float syncopation;
  float disjunct;
  int running;
  int voiceIndex;

  LPF low => Gain m => rev;
  m => masterFader;
  Wurley r[6];
  1.0 / (r.size()) => low.gain;
  for (int i; i < r.size(); i++)
  {
    r[i] => low;
    r[i].controlChange(128,0.95);
  }
  4000 => low.freq;
  1 => low.Q;

  ScaleNote note;

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
    1 => running;
    spork ~ playShred();
  }

  fun void playShred()
  {
    while (masterFader.value() > 0.001)
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
          1 => r[voiceIndex].noteOff; //(note.getLast()+root,channel);
          (1 + voiceIndex) % r.size() => voiceIndex;
          (note.nextNote()+root) => Std.mtof => r[voiceIndex].freq;
          Math.random2f(0.5,1) => r[voiceIndex].gain;
          1 => r[voiceIndex].noteOn;
        }
        (pulse() - humanize) => now;
      }
    }
    10::second => now;
    0 => running;
  }
}

class VanillaBass
{
  3 => int channel;
  int lowBarrier;
  int density;
  float syncopation;
  int running;
  int voiceIndex;

  LPF low => Gain voices => Gain m => rev;
  m => masterFader;
  Rhodey r[4];
  1.0 / (r.size()) => voices.gain;
  for (int i; i < r.size(); i++)
  {
    r[i] => low;
  }
  1000 => low.freq;
  2 => low.Q;

  HarmonyNote note;

  fun void set(int low, int den, float sync)
  {
    low => lowBarrier;
    den => density;
    sync => syncopation;
    lowBarrier => note.lowBarrier;
  }

  fun void play()
  {
    1 => running;
    spork ~ playShred();
  }

  fun void playShred()
  {
    while (masterFader.value() > 0.001)
    {
      if (density < 2) cloud.play();
      lowBarrier => note.lowBarrier;
      rhythmicPattern(density,syncopation) @=> int test[];
      for (int i; i < test.size(); i++)
      {
        pulse() * Math.random2f(0,0.1) => dur humanize;
        humanize => now;
        if (test[i])
        {
          1 => r[voiceIndex].noteOff; //(note.getLast()+root,channel);
          (1 + voiceIndex) % r.size() => voiceIndex;
          (note.nextNote()+root) => Std.mtof => r[voiceIndex].freq;
          Math.random2f(0.5,1) => r[voiceIndex].noteOn;
        }
        (pulse() - humanize) => now;
      }
    }
    10::second => now;
    0 => running;
  }
}

fun dur pulse ()
{
  if (bpm > 0) return 30::second / bpm;
  else return second;
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
    clamp(lowRand(0,density + syncopation*(16-density)),0,15)$int => int pick;
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

class VanillaChords
{
  3 => int numPitches;
  12 => int width;
  36 => int lowBarrier;
  int arpLen; // 0 - 4 pulses
  int channel;
  4 => int density;
  0.75 => float syncopation;
  int running;
  int voiceIndex;

  Gain voices => Gain m => rev;
  m => masterFader;
  ModalBar r[12];
  1.0 / (r.size()) => voices.gain;
  for (int i; i < r.size(); i++)
  {
    r[i] => voices;
    1 => r[i].preset;
    0.1 => r[i].vibratoGain;
    0.9 => r[i].stickHardness;
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
    1 => running;
    spork ~ playShred();
  }

  fun void playShred()
  {
    while (masterFader.value() > 0.001)
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
    10::second => now;
    0 => running;
  }
  fun void oneChord()
  {
    pulse() * arpLen / numPitches => dur arp;
    //lowBarrier + Math.random2(-1,1) => int thisLowBarrier;
    //width + Math.random2(-1,1) => int thisWidth;
    width/(numPitches - 1.0) => float dist;
    for (int j; j < numPitches; j++)
    {
      lowBarrier + (j * dist) => float pureSplit;
      fitToScale(pureSplit) => int fitSplit;
      (voiceIndex + 1) % r.size() => voiceIndex;
      (fitSplit+root) => Std.mtof => r[voiceIndex].freq;
      Math.random2f(0.5,1) => r[voiceIndex].noteOn;
      arp => now;
    }
  }
}

class VanillaPercussion
{
  0 => int channel;
  int lowBarrier;
  int range;
  int density;
  float syncopation;
  float variation;
  int running;
  float pattern[16];
  int voiceIndex;

  Gain voices => Gain m => rev;
  m => masterFader;
  Shakers r[16];
  1.0 / (r.size()) => voices.gain;
  for (int i; i < r.size(); i++)
  {
    r[i] => voices;
  }

  fun void set(int low, int ran, int den, float sync)
  {
    low => lowBarrier;
    ran => range;
    den => density;
    sync => syncopation;
  }

  fun void play()
  {
    1 => running;
    for (int i; i<pattern.size(); i++)
    {
      Math.random2f(0,1) => pattern[i];
    }
    spork ~ playShred();
  }

  fun void playShred()
  {
    while (masterFader.value() > 0.001)
    {
      rhythmicPattern(density,syncopation) @=> int test[];
      for (int i; i < test.size(); i++)
      {
        pulse() * Math.random2f(0,0.1) => dur humanize;
        humanize => now;
        if (test[i])
        {
          1 => r[voiceIndex].noteOff;
          ilerp(pattern[i],lowBarrier,lowBarrier+range) => int note;
          (1 + voiceIndex) % r.size() => voiceIndex;
          note => r[voiceIndex].preset;
          Math.random2f(0.5,1) => r[voiceIndex].noteOn;
          if (Math.random2f(0,16) < variation) Math.random2f(0,1) => pattern[i];
        }
        (pulse() - humanize) => now;
      }
    }
    10::second => now;
    0 => running;
  }
}

class Cloud
{
    SinOsc v1 => Chorus c1 => ADSR chordEnv;
    SinOsc v2 => Chorus c2 => chordEnv;
    SinOsc v3 => Chorus c3 => chordEnv;
    SinOsc v4 => Chorus c4 => chordEnv;
    chordEnv => chordEnv => PRCRev chordRev => Gain m => masterFader;

    0.05 => c1.modDepth => c2.modDepth => c3.modDepth => c4.modDepth;
    0.05 => chordEnv.gain;
    8::second => chordEnv.attackTime;
    8::second => chordEnv.decayTime;
    0 => chordEnv.sustainLevel;
		0.5 => chordRev.gain;
    int running;

    fun void play()
    {
      if (!running)
      {
    	  Math.random2f(0.5,2) => c1.modFreq;
    	  Math.random2f(0.5,2) => c2.modFreq;
    	  Math.random2f(0.5,2) => c3.modFreq;
    	  Math.random2f(0.5,2) => c4.modFreq;
        spork ~ playShred();
        1 => running;
      }
    }

    fun void playShred()
    {
        root + 84 => Std.mtof => float f;

        f * 2 / 3 => v1.freq;
        f * 3 / 4 => v2.freq;
        f * 4 / 3 => v3.freq;
        f * 3 / 2 => v4.freq;
        Math.random2(0,10)::second => now;
        1 => chordEnv.keyOn;
        Math.random2(6,15)::second => now;
        1 => chordEnv.keyOff;
        12::second => now;
        0 => running;
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
          Math.random2(-4,4) => root;
          flerp(br,48,212) => bpm;
          1 => masterFader.value;
          highMelody.play();
          bassLine.play();
          percussion.play();
          chords.play();
          0 => highMelody.density;
          0 => percussion.density;
          0 => bassLine.density;
          0 => chords.density;
        }
        if (0 == whichTrack) // master controls
        {
          ilerp (hue, 0, numScales-1) => int newScale;
          if (newScale != oldScale)
          {
            allScales[newScale] @=> scale;
            allWeights[newScale] @=> weights;
            newScale => oldScale;
          }
          ilerp (sat, 48, 12) => bassLine.lowBarrier;
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
          ilerp(sat, 8, 0) => chords.arpLen;
          ilerp(sat, 8, 0) => chords.density; // band 2 - random (or inverse sat)
          ilerp(hue, 2, 8) => chords.numPitches;
        }
        if (3 == whichTrack)
        {
          br => percussion.syncopation; // band 3 - hue
          hue => percussion.variation; // band 3 - sat
          ilerp(sat,0,16) => percussion.density; // band 3 - br
        }
        if (4 == whichTrack)
        {
          ilerp(hue,10,40) => bassLine.lowBarrier; // band 4 - hue
          sat * 0.5 => bassLine.syncopation; // band 4 - sat
          ilerp(br,0,8) => bassLine.density; // band 4 - br
        }
        if (-1 == whichTrack) // fade out
        {
          0 => masterFader.target;
          20::second => now;
        }
    }
  }
}
