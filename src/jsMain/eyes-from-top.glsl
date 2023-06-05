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
#define DISTANCE_FORWARD 500.0 // Inches
#define DISTANCE_SIDEWAYS 200.0 // Inches to each side

uniform FixtureInfo fixtureInfo;
uniform vec2 center; // @@XyPad



// @param params moving-head-params
void main(out MovingHeadParams params) {
    params.colorWheel = 0.0;

    // x is forward
    // z is sideways
    // y is height

    float centerToEyesInches = fixtureInfo.position.z;
    float distanceToSide = center.x * DISTANCE_SIDEWAYS;
    float distanceFromWall = (center.y + 1.0) * DISTANCE_FORWARD / 2.0;


    float dx = distanceFromWall - fixtureInfo.position.x;
    float dz = distanceToSide - centerToEyesInches;
    float dy = -fixtureInfo.position.y; // since y2 = 0 (point is on the floor)


    float panAngle = atan(dz, dx);
    params.colorWheel = panAngle;
    params.pan = 1.0 * PI + -panAngle;



    float distanceHorizontal = sqrt(dx * dx + dz * dz);
    float tiltAngle = atan(dy, distanceHorizontal);



    params.tilt = -tiltAngle;

    //params.tilt = - PI / 4.0;

    // Set the other parameters as before
    //params.colorWheel = 0.;
    params.dimmer = 1.;


    //params.pan = PI;

    //params.dimmer = physicalLocation.x;
    //params.colorWheel = fixtureInfo.rotation.y;
}
