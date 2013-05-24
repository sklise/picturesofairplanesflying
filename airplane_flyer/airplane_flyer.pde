import SimpleOpenNI.*;

SimpleOpenNI kinect;

boolean was_was_airplane = false;
boolean was_airplane = false;
boolean airplane = false;
PImage airplane_image;
PImage title_screen;
String[] airplanes;
int airplane_count;
float slope;

void setup() {
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
  kinect.setMirror(true);
  size(1920, 1080);

  airplanes = loadStrings("filelist.txt");
  airplane_count = airplanes.length;

  title_screen = loadImage("title.jpg");
}

void draw() {
  kinect.update();

  // write the list of detected users
  int[] userList = kinect.getUsers();

  // if we found any users
  if (userList.length > 0) {

    // Use the first user only.
    int userId = userList[0];
    // now wait until the skeleton is getting tracked
    if (kinect.isTrackingSkeleton(userId)) {
      // initialize join position variables
      PVector rightHand = new PVector();
      PVector rightElbow = new PVector();
      PVector leftHand = new PVector();
      PVector leftElbow = new PVector();

      // dump joint info into the PVectors
      kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, leftHand);
      kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, rightHand);
      kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, leftElbow);
      kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, rightElbow);

      // screen coordinates
      kinect.convertRealWorldToProjective(leftHand, leftHand);
      kinect.convertRealWorldToProjective(rightHand, rightHand);
      kinect.convertRealWorldToProjective(leftElbow, leftElbow);
      kinect.convertRealWorldToProjective(rightElbow, rightElbow);

      // Collect joints and find best fit line and R^2
      PVector[] vectors = { leftHand, rightHand, leftElbow, rightElbow };
      float[] fits = bestFit(vectors);
      float r2 = rsquare(vectors, fits[0], fits[1]);

      if (r2 > 0.1) {
        airplane = true;
      } else {
        airplane = false;
      }

      slope = fits[0];

      // debugging
      // stroke(255, 0, 0);
      // line(0, fits[1], 700, 700 * fits[0] + fits[1]);

      // for (PVector v : vectors) {
        // fill(0, 255, 0);
        // noStroke();
        // ellipse(v.x, v.y, 5, 5);
      // }
      // end debugging
    }
  }

  if (airplane || was_airplane || was_was_airplane) {
    // Set the airplane image
    if (was_was_airplane == false && was_airplane == false) {
      airplane_image = loadImage("airplanes/" + airplanes[(int)random(airplane_count)]);
    }

    background(0,0,0);
    image(airplane_image, 0, 0);

    // tilting
    strokeWeight(3);
    if (slope < -0.2) {
      if (frameCount % 15 == 0) {
        airplane_image = loadImage("airplanes/" + airplanes[(int)random(airplane_count)]);
      }
      stroke(255, 0,0);
      line(0,1,width,1);
    } else if (slope > 0.2) {
      if (frameCount % 15 == 0) {
        airplane_image = loadImage("airplanes/" + airplanes[(int)random(airplane_count)]);
      }
      stroke(0, 255, 0);
      line(0,1,width,1);
    }
    strokeWeight(1);

  } else {
    background(0);
    image(title_screen, 0, 0);
  }
  // image(kinect.depthImage(), 0, 0);

  // Save current state of airplane-ness.
  was_was_airplane = was_airplane;
  was_airplane = airplane;
}

// Significance test for linearity. Overridden when there is an outlier.
float rsquare(PVector[] list, float m, float b) {
  // calculate the average y values.
  float average = 0.0;
  for (PVector vector : list) {
    average += vector.y;
  }
  average = average / (float)list.length;

  // Function values and error values for R^2 test
  float sumtot = 0;
  float sumerr = 0;
  // Keep track of the maximum error value, looking
  // for accuracy also.
  float maxerr = 0;

  for (PVector vector : list) {
    float err = pow(vector.y - vector.x * m - b, 2);
    float abserr = abs(err);

    // set maxerr if absolute value of err is bigger.
    if (abserr > maxerr) {
      maxerr = abserr;
    }

    sumtot += pow(vector.y - average, 2);
    sumerr += err;
  }

  // return 0 if maxerr is greater than a threshold.
  if (maxerr > 190) {
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
    sumx2 += pow(v.x, 2);
    sumy += v.y;
    sumproduct += v.x * v.y;
  }

  m = (sumproduct - (sumx * sumy / n)) / (sumx2 - pow(sumx, 2)/n);

  b = sumy / n - m * sumx / n;

  float[] response = {
    m, b
  };
  return response;
}

