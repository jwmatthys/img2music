"Salamander_C5-v3-MR-HEDSounds.sf2" => string sfont;
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
  dur => now;
  m.noteOff(note,0);
}

[6.35, 2.23, 3.48, 2.33, 4.38, 4.09, 2.52, 5.19, 2.39, 3.66, 2.29, 2.88] @=> float krumhanslWeights[];
[1.00,0,1,1,0,1,0,1,1,0,1,0] @=> float aeolianWeights[];
[1.00,0,1,1,0,1,0,1,0,1,1,0] @=> float dorianWeights[];
[1.00,0,1,0,1,1,0,1,0,1,1,0] @=> float mixolydianWeights[];
[1.00,0,1,0,1,1,0,1,0,1,0,1] @=> float ionianWeights[];
[1.00,0,1,0,1,0,1,1,0,1,0,1] @=> float lydianWeights[];
[1.00,0,1,0,1,0,1,0,1,0,1,0] @=> float octatonicWeights[];
[1.00,0,1,0,1,0,0,1,0,1,0,0] @=> float majorPentatonicWeights[];
[1.00,0,0,1,0,1,0,1,0,0,1,0] @=> float minorPentatonicWeights[];
