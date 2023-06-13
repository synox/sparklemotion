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
#define DISTANCE_FORWARD 1000.0 // Inches
#define DISTANCE_SIDEWAYS 1000.0 // Inches to each side

uniform FixtureInfo fixtureInfo;
uniform vec2 center; // @@XyPad
uniform float time; // @@Time

vec2 rotateAroundPoint(vec2 point, vec2 pivot, float angle) {
    // Move the point so that the pivot point becomes the origin
    point -= pivot;
    // Perform the rotation
    float sinAngle = sin(angle);
    float cosAngle = cos(angle);
    vec2 rotatedPoint = vec2(
    point.x * cosAngle - point.y * sinAngle,
    point.x * sinAngle + point.y * cosAngle
    );
    // Move the point back
    rotatedPoint += pivot;
    return rotatedPoint;
}



// @param params moving-head-params
void main(out MovingHeadParams params) {
    // x is forward (+ is forward)
    // y is height (+ is up)
    // z is sideways (+ is right)


    vec3 targetPoint = vec3(
    (center.y + 1.0) * DISTANCE_FORWARD / 2.0 + -fixtureInfo.position.x,
    0.0,
    center.x * DISTANCE_SIDEWAYS - fixtureInfo.position.z
    );

    // fixed for testing
    targetPoint= vec3(200, 0, 20);

    // rotate target into space in front of eye
    vec3 pointInFrontOfEye;
    pointInFrontOfEye.xz = rotateAroundPoint(targetPoint.xz, fixtureInfo.position.xz, fixtureInfo.rotation.y);
    pointInFrontOfEye.y = targetPoint.y;

    // angle from pointInFrontOfEye to axis at x=0 y=0 z=?
    params.pan =  1.0 * PI - atan(pointInFrontOfEye.z, fixtureInfo.position.y);
    params.pan =  1.0 * PI + center.x * 2.0;
    // 2.0 * PI +

    // params.pan = 1.0 * PI;
    // params.tilt = PI / 4.0;
    params.tilt = sin(time*2.0);
    params.tilt = 2.6;

    params.colorWheel = pointInFrontOfEye.z;
    params.dimmer = 1.;

}
