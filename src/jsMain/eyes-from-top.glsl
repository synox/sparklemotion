struct FixtureInfo {
    vec3 position; // z=left/right y=height x=front-back
    vec3 rotation; // y=left/right
    mat4 transformation;
};

struct MovingHeadParams {
    float pan;
    float tilt;
    float colorWheel;
    float dimmer;
};

#define PI 3.14159265358979323846
#define PAN_RANGE (PI * 3.0)
#define TILT_RANGE (PI * 1.5)
#define DISTANCE_FORWARD 1000.0 // cm
#define DISTANCE_SIDEWAYS 500.0 // cm on each side

uniform FixtureInfo fixtureInfo;


uniform vec2 center; // @@XyPad

float calculate_angle(vec2 pos) {
    float angle = atan(pos.y, pos.x);
    return angle;
}


// @param params moving-head-params
void main(out MovingHeadParams params) {
    vec2 physicalLocation = vec2(DISTANCE_SIDEWAYS * center.x , DISTANCE_FORWARD * (center.y + 1.0) /2.0 );
    vec2 fixturePosition = vec2(fixtureInfo.position.z,fixtureInfo.position.x );
    vec2 fixtureToTarget = physicalLocation -fixturePosition;


    params.pan = calculate_angle(fixtureToTarget) + 3.0 / 4.0 * 2.0 * PI;


    // For other y values, interpolate between the two extremes.
    float tiltDown = PI / 2.0;
    float tiltForward = atan(fixtureInfo.position.y  / DISTANCE_FORWARD );
    params.tilt = -mix(tiltDown, tiltForward, center.y * 0.5 + 0.5 );


    // Set the other parameters as before
    params.colorWheel = 0.;
    params.dimmer = 1.;


    //params.pan = PI;
    //params.tilt = -1.0;
    //params.dimmer = physicalLocation.x;
}
