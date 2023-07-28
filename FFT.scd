(
b = Buffer.alloc(s,2048,1);
c = Buffer.alloc(s,2048,1);
//d = Buffer.read(s,"sounds/oceanMONO.aif");
//d = Buffer.read(s,"sounds/insand/camina.aif");
d = Buffer.read(s,"sounds/digireedoo.aif");
e = Buffer.read(s,"sounds/holeMONO.aif");
f = Buffer.read(s, "sounds/a11wlk01.wav");
)
g = Buffer.read(s, "D:/SUPERCOLLIDER/_SOUNDS/MUSIC_BOX.wav");

Synth(\bplay, [\buf, g, \rate, 1, \loop, 1])


Pbind(\instrument, \bplay, \rate, Pseq(Scale.minor.ratios,10 ), \dur, 0.25, \buf, g).play

(
SynthDef(\bplay, {|out = 0, buf, rate = 1, loop = 0, mul = 1|
	var sample;
	sample = PlayBuf.ar(1, buf, rate * BufRateScale.kr(buf), loop: loop, doneAction:2);
	Out.ar(out, sample * mul ! 2);
}).add;
)

Synth(\bplayenv, [\buf, f])

~lfo = {SinOsc.ar(1, 0, 0.5, 1.1)}

~bind = Pbind(\instrument, \bplayenv, \buf, f, \rate, Pseq([1, 0.5, 1, 1, 2], inf), \dur, Pseq([1, 1, 1, 0.5, 0.5], inf), \decay, Prand([0.5, 0.5, 1, 0.5], inf) )
~bind.play;



(
SynthDef(\bplayenv, {|out = 0, buf, rate = 1, loop = 0, mul = 1, decay = 1|
	var sample, env;
	env = Env.perc(0, decay);
	sample = PlayBuf.ar(1, buf, rate * BufRateScale.kr(buf), loop: loop);
	sample = sample * EnvGen.ar(env, doneAction: 2);
	Out.ar(out, sample * mul ! 2);
}).add;
)

(
SynthDef(\pvmagabove, { arg out=0, mul =1, seuil;
var in, chain;
chain = FFT(LocalBuf(2048), in);
chain = PV_MagAbove(chain, seuil);
Out.ar(out, 0.5 * IFFT(chain)!2);
}).add;
)

~sqrlfo = {LFPulse.ar(10)}

~seq.play
(
~seq = Pbind(\instrument, \bplay, \mul, 0.040, \buf, g, \rate, Prand(Scale.major.ratios * [1, 0.5, 2], inf), \out, b, \dur, Prand([0.25, 1, 1, 1], inf));

~seq[1] = \filter -> {arg sig; LPF.ar(sig, (~sqrlfo*500)  + 1000)};
~seq[2] = \filter -> {arg sig; FreeVerb.ar(sig, 1, 0.1)};
~seq[2] = nil;
~seq[3] = \filter -> {arg sig; sig + PitchShift.ar(sig, 0.1, 2, 0.1)};
~seq[3] = nil;
)
~seq.stop

p = ProxySpace.push(s, \prox, TempoClock)
p.fadeTime = 5
b = Bus.audio(s, 2);

~effectline = {In.ar(b, 2)};
~effectline[0] = \filter -> {arg sig; LPF.ar(sig, 42)}
~effectline.play
