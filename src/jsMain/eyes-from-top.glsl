struct FixtureInfo {
    vec3 position; // z=left/right y=height x=front-back
    vec3 rotation; // y=left/right yaw, z=pitch (0 is up), x=roll,
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
#define DISTANCE_SIDEWAYS 500.0 // cm to each side

uniform FixtureInfo fixtureInfo;
uniform vec2 center; // @@XyPad

float angleToTarget(vec2 pos) {
    float centerToEyesCm = fixtureInfo.position.z;
    float xDistanceCm = pos.x * DISTANCE_SIDEWAYS;
    float deltaXcm = xDistanceCm + centerToEyesCm;

    float deltaY = (pos.y + 1.0) * DISTANCE_FORWARD / 2.0;
    return atan(deltaXcm / deltaY) + fixtureInfo.rotation.y;
}

float tiltToTarget(vec2 pos) {
    float distanceForward = (pos.y + 1.0) * DISTANCE_FORWARD / 2.0;
    float fixtureHeight = fixtureInfo.position.y;
    //return fixtureHeight;
    return  - atan( fixtureHeight / (distanceForward + - 0.0 * fixtureInfo.position.x));
    //return 1.0;
}

float calculate_angle(vec2 pos) {
    float angle = atan(pos.y, pos.x);
    return angle;
}

float normalizeCenter(float angle) {
    if (angle < 0.0)
        angle += 2.0 * PI;
    angle = mod(angle + 3.0 / 4.0 * 2.0 * PI, 2.0 * PI);
    return angle;
}

// @param params moving-head-params
void main(out MovingHeadParams params) {


    vec2 physicalLocation = vec2(DISTANCE_SIDEWAYS * center.x , DISTANCE_FORWARD * (center.y + 1.0) /2.0 );
    vec2 fixturePosition = vec2(fixtureInfo.position.z,fixtureInfo.position.x );
    vec2 fixtureToTarget = physicalLocation -fixturePosition;


    params.pan = 2.0 * PI   - angleToTarget(center); // vec2(-1, 1) //+ 3.0 / 4.0 * 2.0 * PI;


    params.tilt = tiltToTarget(center);

    // Set the other parameters as before
    params.colorWheel = 0.;
    params.dimmer = 1.;


    //params.pan = PI;

    //params.dimmer = physicalLocation.x;
    params.colorWheel = fixtureInfo.rotation.y;
}
