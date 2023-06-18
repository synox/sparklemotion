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
#define DISTANCE_FORWARD 500.0 // Inches
#define DISTANCE_SIDEWAYS 300.0 // Inches to each side

uniform FixtureInfo fixtureInfo;
uniform vec2 pad; // @@XyPad
uniform float time; // @@Time

// @param params moving-head-params
void main(out MovingHeadParams params) {
    // +x is forward (from sheeps perspective)
    // +y is up (height)
    // +z is right (from sheeps perspective)


    vec3 target = vec3((pad.y + 1.0) * DISTANCE_FORWARD / 2.0,
        0.0,
        pad.x * DISTANCE_SIDEWAYS);

    float dx = target.x  - fixtureInfo.position.x;
    float dy = target.y  - fixtureInfo.position.y;
    float dz = target.z  - fixtureInfo.position.z;

    params.tilt = .0*PI - acos(dx / sqrt(dx*dx+dy*dy+dz*dz));
    params.pan = 1.5*PI+ acos(dz / sqrt(dz*dz+dy*dy));


    params.colorWheel = fixtureInfo.position.z / 10.;
    params.dimmer = 1.;

}
