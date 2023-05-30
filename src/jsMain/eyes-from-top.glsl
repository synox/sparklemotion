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

uniform FixtureInfo fixtureInfo;


uniform vec2 center; // @@XyPad

float calculate_angle(vec2 pos) {
    float angle = atan(pos.y, pos.x);
    if (angle < 0.0)
        angle += 2.0 * PI;
    angle = mod(angle + 1.5 * PI, 2.0 * PI);
    return angle;
}

// @param params moving-head-params
void main(out MovingHeadParams params) {
    vec2 targetPoint = center;
    vec2 fixtureToTarget = center - vec2(-fixtureInfo.position.z, fixtureInfo.position.x);

    // Calculate distance from the fixture to the target point on the ground
    float groundDistance = length(fixtureToTarget);

    // Calculate the pan and tilt angles
    // The pan angle is the angle in the x-z plane (horizontal plane)
    params.pan = calculate_angle(fixtureToTarget);


    // For other y values, interpolate between the two extremes.
    float tiltDown = PI / 2.0;
    float tiltForward = atan(fixtureInfo.position.y  / DISTANCE_FORWARD );
    params.tilt = mix(tiltDown, tiltForward, center.y * 0.5 + 0.5 );


    // Set the other parameters as before
    params.colorWheel = 0.;
    params.dimmer = 1.;


    //params.pan = PI;
    //params.tilt = atan(fixtureInfo.position.y  / DISTANCE_FORWARD );

}
