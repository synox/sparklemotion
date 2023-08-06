struct FixtureInfo {
    vec3 position;
    vec3 rotation;
    mat4 transformation;
};

struct MovingHeadParams {
    float pan;
    float tilt;
    float colorWheel;
    float dimmer;
};

uniform FixtureInfo fixtureInfo;


struct BeatInfo {
    float beat;
    float bpm;
    float intensity;
    float confidence;
};
uniform BeatInfo beatInfo; // @@baaahs.BeatLink:BeatInfo

uniform float time; // @@Time
uniform bool alternateEye; // @@Switch enabled=true
uniform bool sky; // @@Switch enabled=true
uniform bool horizon; // @@Switch enabled=true
uniform bool ground; // @@Switch enabled=true


#define PI 3.14159265358979323846


bool isLeft(){
    return fixtureInfo.position.z < 0.;
}



#define SIMULATE_BPM true

float getBPM() {
    if (SIMULATE_BPM)  {
        return 120.;
    } else {
        return beatInfo.bpm;
    }
}

float getTimeOfLastBeat() {
    float beatShift = alternateEye && isLeft() ? 1.0 : 0.;
    float eyesInSequence = alternateEye ? 2. : 1.;

    // SIM:
    if(SIMULATE_BPM){
        float bpm =  getBPM();
        float beatDuration = 60. / bpm;
        float timeSince2Beats = mod(time + beatShift * beatDuration, beatDuration  * eyesInSequence);
        return time - timeSince2Beats;
    } else {
        // real:
        float beatDuration = 60. / getBPM();
        float timeSince2Beats = mod(beatInfo.beat + beatShift, eyesInSequence) * beatDuration;
        return time - timeSince2Beats;
    }
}

float rand(float seed){
    vec2 co = vec2(1, seed);
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}


float getSeed(){
    float counter = getTimeOfLastBeat() * getBPM() / 60.;
    float eyesInSequence = alternateEye ? 2. : 1.;
    return counter / eyesInSequence;
}


float pan(float value /* [-1...1]*/ ) {
    if(horizon && !sky && !ground) {
        return 2. * PI /2. + 0.5 * PI;
    }

    float rangeOfMotion = 0.5 * PI; // to each side
    return 2. * PI /2. + value * rangeOfMotion;
}

float tilt(float value /* [-1...1]*/) {
    // if(!sky) value = min(0.5, value);
    // if(!ground) value = max(0.5, value);
    // if(!horizon) {
    //     // avoid values near 0.5;
    //     if(value > 0.5 && value < 0.55) {
    //         value = 0.55;
    //     } else if (value < 0.5 && value > 0.45) {
    //         value = 0.45;
    //     }
    // }
    return value * 1.2;
}




float panValue(){
    // start each eye at a different position so it does not seem like they follow each other.
    float offset = isLeft() ? 4. : 0.;
    int t = int(mod(getSeed() + offset, 13.));

    float panStops[13] = float[](
    -0.4, -0.3, -0.4, -0.2,
    0.,    0.3,  0.2,  0.4,
    0.25,  0.3,   0., -0.1,
    -0.25
    );
    return panStops[t];
}

float tiltValue(){
    if(horizon && !sky && !ground) {
        int t = int(mod(getSeed(), 11.));
        float tiltStops[11] = float[](
        -1.,    -0.4,     -0.6,      -0.2,
        0.2,     0.0,       0.5,      1.0,
        0.2,    -0.4,     -0.7
        );
        return tiltStops[t];
    }
    int t = int(mod(getSeed(), 5.));
    float tiltStops[5] = float[](
    -1.,      -0.4,      -0.6,      -0.3,
    -0.7
    );

    return tiltStops[t];
}


// @param params moving-head-params
void main(out MovingHeadParams params) {
    params.pan = pan(panValue());
    params.tilt = tilt(tiltValue());

    //params.colorWheel =  round(mod(getTimeOfLastBeatSet()/13., 13.)/13.*7.);
    params.colorWheel =  0.2;
    // mod(time, 0.1); //mod(getSeed() / 10., 1.);
    params.dimmer = round(time - getTimeOfLastBeat());
}
