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

#define PI 3.14159265358979323846
#define PAN_RANGE (PI * 3.0)
#define TILT_RANGE (PI * 1.5)

uniform FixtureInfo fixtureInfo;

uniform vec2 center; // @@XyPad

float calculate_angle(vec2 pos) {
    float angle = atan(pos.y, -pos.x);
    if (angle < 0.0)
        angle += 2.0 * PI;
    angle = mod(angle + 1.5 * PI, 2.0 * PI);
    return angle;
}

// @param params moving-head-params
void main(out MovingHeadParams params) {


params.pan = calculate_angle(center);
// atan(center.y, center.x) - PI / 2.0;
params.tilt = length(center);

    params.colorWheel = 0.;
    params.dimmer = 1.;
}
