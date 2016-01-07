n = NetAddr.new("127.0.0.1",12000)

//execute this
(
(
SynthDef(\sinblip,
	{
		arg freq = 8000, b1 = 1.01, b2 = 0.99, b3 = 1.02;
		var sig, env;
		env = EnvGen.ar(Env.perc(0.01,Rand(0.1,0.5)),1,1,0,1,2);
		sig = Splay.ar(SinOsc.ar([freq,freq*b1,freq*b2,freq*b3]+(env*Rand(-500,2000)),0,0.6));
		sig = sig * env;
		Out.ar(0,sig);
}).add;
);

(
SynthDef(\sinthunk,
	{
		arg freq=100, t1 = 1.05, t2 = 0.95, t3 = 1.1, t4 = 0.9;
		var sig, env;
		sig = Splay.ar(SinOscFB.ar([freq,freq*t1,freq*t2,freq*t3,freq*t4],Rand(0,0.9),0.7));
		env = EnvGen.ar(Env.perc(0.01,Rand(5,10)),1,1,0,1,2);
		sig = sig * env;
		Out.ar(0,sig)
}).add;
)
)

//then execute this
(
StageLimiter.activate;

~freq = 8000;
~b1 = 1.01;
~b2 = 0.99;
~b3 = 1.02;
~t1 = 1.05;
~t2 = 0.95;
~t3 = 1.1;
~t4 = 0.9;

~whois = OSCFunc({|msg| Synth.new(\sinblip,[\freq,~freq,\b1,~b1,\b2,~b2,\b3,~b3])},'/scwhois');
~netinfo = OSCFunc({|msg| Synth.new(\sinthunk,[\t1,~t1,\t2,~t2,\t3,~t3,\t4,~t4]);
	~freq = rrand(4000,10000);
	~b1 = rrand(0.95,1.05);
	~b2 = rrand(0.95,1.05);
	~b3 = rrand(0.9,1.1);
	~t1 = rrand(0.9,1.1);
	~t2 = rrand(0.9,1.1);
	~t3 = rrand(0.9,1.1);
	~t4 = rrand(0.9,1.1)},'/scnetinfo');
)

