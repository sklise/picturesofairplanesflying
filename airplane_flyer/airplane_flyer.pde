import SimpleOpenNI.*;

SimpleOpenNI kinect;

boolean airplane = false;

void setup() {
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableRGB();
  kinect.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
  kinect.setMirror(true);
  size(1080, 720);
}

void draw() {
  kinect.update();

  if (airplane) {
    background(255, 0,0);
  } else {
    background(255);
  }
  image(kinect.depthImage(), 0, 0);

  // write the list of detected users
  // into our vector
  int[] userList = kinect.getUsers();

  // if we found any users
  if (userList.length > 0) {
    for( int userId : userList) {
      if (kinect.isTrackingSkeleton(userId)) {
        stroke(0);
        drawSkeleton(userId);
      }

      // initialize join position variables
      PVector rightHand = new PVector();
      PVector rightElbow = new PVector();
      PVector leftHand = new PVector();
      PVector leftElbow = new PVector();
      PVector leftShoulder = new PVector();
      PVector rightShoulder = new PVector();

      PVector torso = new PVector();
      PVector neck = new PVector();
      PVector head = new PVector();

      // dump joint info into the PVectors
      kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, leftHand);
      kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, rightHand);
      kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, leftElbow);
      kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, rightElbow);
      kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, leftShoulder);
      kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, rightShoulder);

      kinect.convertRealWorldToProjective(leftHand, leftHand);
      kinect.convertRealWorldToProjective(rightHand, rightHand);
      kinect.convertRealWorldToProjective(leftElbow, leftElbow);
      kinect.convertRealWorldToProjective(rightElbow, rightElbow);
      kinect.convertRealWorldToProjective(leftShoulder, leftShoulder);
      kinect.convertRealWorldToProjective(rightShoulder, rightShoulder);

      PVector[] vectors = {leftHand, rightHand, leftElbow, rightElbow, leftShoulder, rightShoulder};

      float[] fits = bestFit(vectors);

      float r2 = rsquare(vectors, fits[0], fits[1]);

      stroke(255,0,0);
      line(0, fits[1], 700, 700 * fits[0] + fits[1]);

      println("R2 = " + r2);

      if (r2 > 0.2) {
        airplane = true;
      } else {
        airplane = false;
      }
    }
  }
}

// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{
  // to get the 3d joint data
  /*
  PVector jointPos = new PVector();
  kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_NECK,jointPos);
  println(jointPos);
  */

  kinect.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

  kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
}

float rsquare(PVector[] list, float m, float b) {
  float average = 0.0;

  for (PVector vector : list) {
    average += vector.y;
  }

  average = average / (float)list.length;

  float sumtot = 0;
  float sumerr = 0;
  float sumreg = 0;

  float maxerr = 0;

  for (PVector vector : list) {
    sumtot += pow(vector.y - average, 2);
    float err = pow(vector.y - vector.x * m - b, 2);
  
    float abserr = abs(err);

    if (abserr > maxerr) { maxerr = abserr; }
    sumerr += err;
    sumreg += pow(vector.x * m + b - average, 2);
  }

  println(maxerr);

  if (maxerr > 100) {
    return 0;
  } else {
    return 1 - sumerr / sumtot;
  }
}

// Take a list of PVectors and calculate the slope and y-intercept
float[] bestFit(PVector[] list) {
  float n = (float)list.length;
  float m = 0;
  float b = 0;
  float sumproduct = 0;
  float sumx = 0;
  float sumx2 = 0;
  float sumy = 0;

  for (PVector v : list) {
    sumx += v.x;
    sumx2 += pow(v.x,2);
    sumy += v.y;
    sumproduct += v.x * v.y;
  }

  m = (sumproduct - (sumx * sumy / n)) / (sumx2 - pow(sumx,2)/n);

  b = sumy / n - m * sumx / n;

  float[] response = {m, b};
  return response;
}
