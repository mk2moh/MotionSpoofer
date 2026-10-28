#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

#define DOMAIN @"com.yourname.motionspoofer"
#define NOTIFY "com.yourname.motionspoofer/prefsChanged"

enum { S_ACCEL, S_GYRO, S_MAG, S_USERACCEL, S_GRAVITY, S_ROTRATE, S_MAGCAL, S_ATT, S_COUNT };

static BOOL   gEnabled = YES, gAdv = NO;
static double gBase[S_COUNT];
static double gAxis[S_COUNT][3];
static double mSteps = 1, mDistance = 1, mPressure = 1, mRelAlt = 1;

static inline double M(int s, int a) { return gAdv ? gAxis[s][a] : gBase[s]; }

static double readD(NSUserDefaults *d, NSString *key, double def) {
    id v = [d objectForKey:key];
    return v ? [v doubleValue] : def;
}

static void loadPrefs(void) {
    NSUserDefaults *d = [[NSUserDefaults alloc] initWithSuiteName:DOMAIN];
    NSArray *keys = @[@"accel", @"gyro", @"mag", @"userAccel", @"gravity", @"rotRate", @"magCal", @"attitude"];
    NSArray *ax = @[@"X", @"Y", @"Z"];
    gEnabled = [d objectForKey:@"enabled"] ? [d boolForKey:@"enabled"] : YES;
    gAdv = [d boolForKey:@"advanced"];
    for (int s = 0; s < S_COUNT; s++) {
        gBase[s] = readD(d, keys[s], 1);
        for (int a = 0; a < 3; a++)
            gAxis[s][a] = readD(d, [keys[s] stringByAppendingString:ax[a]], 1);
    }
    mSteps    = readD(d, @"steps", 1);
    mDistance = readD(d, @"distance", 1);
    mPressure = readD(d, @"pressure", 1);
    mRelAlt   = readD(d, @"relAlt", 1);
}

static void prefsChanged(CFNotificationCenterRef c, void *o, CFStringRef n, const void *obj, CFDictionaryRef u) {
    loadPrefs();
}

%hook CMAccelerometerData
- (CMAcceleration)acceleration {
    CMAcceleration a = %orig;
    if (gEnabled) { a.x *= M(S_ACCEL,0); a.y *= M(S_ACCEL,1); a.z *= M(S_ACCEL,2); }
    return a;
}
%end

%hook CMGyroData
- (CMRotationRate)rotationRate {
    CMRotationRate r = %orig;
    if (gEnabled) { r.x *= M(S_GYRO,0); r.y *= M(S_GYRO,1); r.z *= M(S_GYRO,2); }
    return r;
}
%end

%hook CMMagnetometerData
- (CMMagneticField)magneticField {
    CMMagneticField m = %orig;
    if (gEnabled) { m.x *= M(S_MAG,0); m.y *= M(S_MAG,1); m.z *= M(S_MAG,2); }
    return m;
}
%end

%hook CMDeviceMotion
- (CMAcceleration)userAcceleration {
    CMAcceleration a = %orig;
    if (gEnabled) { a.x *= M(S_USERACCEL,0); a.y *= M(S_USERACCEL,1); a.z *= M(S_USERACCEL,2); }
    return a;
}
- (CMAcceleration)gravity {
    CMAcceleration a = %orig;
    if (gEnabled) { a.x *= M(S_GRAVITY,0); a.y *= M(S_GRAVITY,1); a.z *= M(S_GRAVITY,2); }
    return a;
}
- (CMRotationRate)rotationRate {
    CMRotationRate r = %orig;
    if (gEnabled) { r.x *= M(S_ROTRATE,0); r.y *= M(S_ROTRATE,1); r.z *= M(S_ROTRATE,2); }
    return r;
}
- (CMCalibratedMagneticField)magneticField {
    CMCalibratedMagneticField f = %orig;
    if (gEnabled) { f.field.x *= M(S_MAGCAL,0); f.field.y *= M(S_MAGCAL,1); f.field.z *= M(S_MAGCAL,2); }
    return f;
}
%end

%hook CMAttitude
- (double)roll  { double v = %orig; return gEnabled ? v * M(S_ATT,0) : v; }
- (double)pitch { double v = %orig; return gEnabled ? v * M(S_ATT,1) : v; }
- (double)yaw   { double v = %orig; return gEnabled ? v * M(S_ATT,2) : v; }
%end

%hook CMPedometerData
- (NSNumber *)numberOfSteps {
    NSNumber *n = %orig;
    return (gEnabled && n) ? @((long long)llround(n.doubleValue * mSteps)) : n;
}
- (NSNumber *)distance {
    NSNumber *n = %orig;
    return (gEnabled && n) ? @(n.doubleValue * mDistance) : n;
}
%end

%hook CMAltitudeData
- (NSNumber *)relativeAltitude {
    NSNumber *n = %orig;
    return (gEnabled && n) ? @(n.doubleValue * mRelAlt) : n;
}
- (NSNumber *)pressure {
    NSNumber *n = %orig;
    return (gEnabled && n) ? @(n.doubleValue * mPressure) : n;
}
%end

%ctor {
    loadPrefs();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, prefsChanged,
        CFSTR(NOTIFY), NULL, CFNotificationSuspensionBehaviorCoalesce);
}
