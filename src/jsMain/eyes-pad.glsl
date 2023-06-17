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

// vec2 rotateAroundPoint(vec2 point, vec2 pivot, float angle) {
//     // Move the point so that the pivot point becomes the origin
//     point -= pivot;
//     // Perform the rotation
//     float sinAngle = sin(angle);
//     float cosAngle = cos(angle);
//     vec2 rotatedPoint = vec2(
//         point.x * cosAngle - point.y * sinAngle,
//         point.x * sinAngle + point.y * cosAngle
//     );
//     // Move the point back
//     rotatedPoint += pivot;
//     return rotatedPoint;
// }



// @param params moving-head-params
void main(out MovingHeadParams params) {
    // x is forward (+ is forward)
    // y is height (+ is up)
    // z is sideways (+ is right)


    vec3 target = vec3(
    (pad.y + 1.0) * DISTANCE_FORWARD / 2.0 + fixtureInfo.position.x,
    0.0,
    pad.x * DISTANCE_SIDEWAYS + fixtureInfo.position.z
    );


    float dx = target.x  - fixtureInfo.position.x;
    float dy = target.y  - fixtureInfo.position.y;
    float dz = target.z  - fixtureInfo.position.z;

    params.tilt = .0*PI - acos(dx / sqrt(dx*dx+dy*dy+dz*dz));
    params.pan = 1.5*PI+ acos(dz / sqrt(dz*dz+dy*dy));


    // fixed for testing
    // targetPoint= vec3(200, 0, 200);

    // // rotate target into space in front of eye
    // vec3 pointInFrontOfEye;
    // pointInFrontOfEye.xz = rotateAroundPoint(targetPoint.xz, fixtureInfo.position.xz, fixtureInfo.rotation.y);
    // pointInFrontOfEye.y = targetPoint.y;

    // // angle from eye to pointInFrontOfEye with x=0 y=0
    // params.pan =  1.0 * PI - 0.0; //atan(pointInFrontOfEye.z - fixtureInfo.position.z, fixtureInfo.position.y);
    // //params.pan =  1.0 * PI + center.x * 2.0;


    // // params.pan = 1.0 * PI;
    // // params.tilt = PI / 4.0;
    // params.tilt = 0. * sin(time*2.0);

    // params.tilt = center.y;

    // params.pan=1.0*PI + center.x;
    // //params.tilt = -2.6;

    params.colorWheel = 0.;
    params.dimmer = 1.;

}
