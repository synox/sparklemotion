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
#define DISTANCE_SIDEWAYS 200.0 // Inches to each side

uniform FixtureInfo fixtureInfo;
uniform vec2 center; // @@XyPad



// @param params moving-head-params
void main(out MovingHeadParams params) {
    // x is forward
    // y is height
    // z is sideways


    vec3 targetPoint = vec3(
    (center.y + 1.0) * DISTANCE_FORWARD / 2.0 + -fixtureInfo.position.x,
    0.0,
    center.x * DISTANCE_SIDEWAYS - fixtureInfo.position.z
    );




    params.pan = 1.0 * PI;
    params.tilt = PI / 4.0;

    params.colorWheel = targetPoint.z;
    params.dimmer = 1.;

}
