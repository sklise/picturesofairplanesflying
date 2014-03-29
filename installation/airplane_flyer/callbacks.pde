// user-tracking callbacks!
void onNewUser(int userId) {
  println("start pose detection");
  kinect.requestCalibrationSkeleton(userId, true);
}

void onEndCalibration(int userId, boolean successful) {
  if (successful) {
    println("  User calibrated !!!");
    kinect.startTrackingSkeleton(userId);
  } else {
    println("  Failed to calibrate user !!!");
    kinect.startPoseDetection("Psi", userId);
  }
}

void onStartPose(String pose, int userId) {
  println("Started pose for user");
}

void onLostUser(int userId)
{
  println("onLostUser - userId: " + userId);
  kinect.stopTrackingSkeleton(userId);
}

void onExitUser(int userId)
{
  println("onExitUser - userId: " + userId);
}

void onReEnterUser(int userId)
{
  println("onReEnterUser - userId: " + userId);
}

void onStartCalibration(int userId)
{
  println("onStartCalibration - userId: " + userId);
}

void onEndPose(String pose,int userId)
{
  println("onEndPose - userId: " + userId + ", pose: " + pose);
}  
