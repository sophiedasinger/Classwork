int NUM_POINTS = 30;
ArrayList<PVector> points;
PVector[] pointarray;
int WIDTH = 500;
int HEIGHT = 1000;
PVector[][] miniHulls;
int numSets;
int numHulls;
int k;
GrahamScan[] myScans;
ArrayList[] hulls;
boolean DONE;
Jarvis myMarch;
class aColor {
 float r, g, b;
}
aColor[] colors;
int h;
  
/* Compare function to be used by sort */
int compare(PVector a, PVector b) {
  if (a.z < b.z)
     return -1;
  if (a.z > b.z)
    return 1;
  return 0;
}

void setup() {
  h = 5;
  size(1000, 500); 
  strokeWeight(5);
  frameRate(5);
  colors = new aColor[20];
  for(int i = 0; i < 20; i++) {
    colors[i] = new aColor();
    colors[i].r = random(255);
    colors[i].g = random(255);
    colors[i].b = random(255);
  }
  numSets = 0;
  numHulls = 0;
  DONE = false;
  points = new ArrayList();
  k = 0;
  makePoints();
  convexHull();
  hulls = new ArrayList[numSets];
  /* ADDED */
  myMarch = new Jarvis();
  myScans = new GrahamScan[numSets];
  for(int i = 0; i < numSets; i++) {
    if(miniHulls[i].length > 3) {
        myScans[i] = new GrahamScan();
        myScans[i].N = miniHulls[i].length;
        numHulls++;
    }
  }
  dataSetup();   
}


void dataSetup() {
  /* ADDED LOOP */
  for(int i = 0; i < numHulls; i++) {
      PVector[] hull = miniHulls[i];
      int len = hull.length;
      myScans[i].pts = new PVector[len+1];
      /* Get out hull points */     
      myScans[i].pts[0] = new PVector(3.4028235E38,3.4028235E38,-2); // dummy value, placeholder      
      for(int j = 1; j < myScans[i].pts.length; j++) {
        float x = hull[j-1].x;
        float y = hull[j-1].y;
        myScans[i].pts[j] = new PVector(x, y, 0.0);
      }
      myScans[i].setup();
  }
}



void draw() {
            background(255);
            ellipseMode(RADIUS);
            smooth();
            noFill();
            for (int i=0; i<pointarray.length; i++) {
              stroke(0, 0, 0);
              strokeWeight(5);
              float x_val = pointarray[i].x;
              float y_val = pointarray[i].y; 
              point(x_val, y_val);
            }
            if(DONE == true) {
              /* Account for extra hull that hasn't been "graham scanned" 
                 because it had <= 3 points */
              if(numHulls < numSets) {
                beginShape();
                strokeWeight(1);
                stroke(colors[numSets-1].r, colors[numSets-1].g, colors[numSets-1].b);
                for(int i=0; i<miniHulls[numSets-1].length; i++) {
                  vertex(miniHulls[numSets-1][i].x, miniHulls[numSets-1][i].y);
                }
                endShape(CLOSE);
              }


            }

            strokeWeight(1);
            if (k > 0 && myScans[k-1].done == true) {
              drawPreviousHulls();            
            }
            drawCurrentHull();                    
            if(!myScans[k].done) {
              myScans[k].next();
            }
            else if ((k+1) < numHulls){
                 k++;
            } 
}


void drawPreviousHulls() {
      for (int i = 0; i < k; i++) {
      stroke(colors[i].r, colors[i].g, colors[i].b);
      ArrayList temp = hulls[i];
      beginShape();
      for(int p = 0; p < temp.size(); p++) {
        PVector temp2 = (PVector)temp.get(p);
        vertex(temp2.x, temp2.y);
      }
      endShape(CLOSE);
    }
    if(k == (numHulls-1) && myScans[k].done == true) {
      stroke(colors[k].r, colors[k].g, colors[k].b);
      ArrayList temp = hulls[k];
      beginShape();
      for(int p = 0; p<temp.size(); p++) {
        PVector temp2 = (PVector)temp.get(p);
        vertex(temp2.x, temp2.y);
      }
      endShape(CLOSE);
      DONE = true;
    }
}

void drawCurrentHull() {
    strokeWeight(2);
    hulls[k] = new ArrayList();
    beginShape();
    for(int i = 0; i < myScans[k].M; i++) {
      stroke(colors[k].r, colors[k].g, colors[k].b);
      vertex(myScans[k].pts[i].x, myScans[k].pts[i].y); 
      /* add to hull array */
      PVector point = new PVector(myScans[k].pts[i].x, myScans[k].pts[i].y, 0);
      hulls[k].add(point);
    }            
    endShape(myScans[k].done?CLOSE:OPEN);            
}
/* Generates a random set of points of size NUM_POINTS
 * How do I make sure that these points are in general position?
 */
void makePoints() {
  for (int i = 0; i < NUM_POINTS; i++) {
     double x_val = random(0, HEIGHT);
     double y_val = random(0, WIDTH);
     PVector p = new PVector((float)x_val, (float)y_val);
     points.add(p);  
  } 
  pointarray = new PVector[points.size()];
  pointarray = points.toArray(pointarray);  
}

/* Generates point sets 
 */
void convexHull() {
  numSets = (int)(ceil((float)NUM_POINTS / (float)h));
  miniHulls = new PVector[numSets][];
  int count = 0;
  int i;
  int len = pointarray.length;
  for(i=0; i<NUM_POINTS; i+=h) {
    if((i+h)-1 >= NUM_POINTS) {
     miniHulls[count] = new PVector[len-i];
     arrayCopy(pointarray, i, miniHulls[count], 0, len-i);
     break;
    }
    miniHulls[count] = new PVector[h];
    arrayCopy(pointarray, i, miniHulls[count], 0, h);
    count++;
  }

}

void mousePressed() {
  setup();
}



/* CODE FOR GRAHAM SCAN */
/* Adapted for Processing.js from Processing Graham Scan */
/* http://www.cc.gatech.edu/grads/m/mluffel/2011/graham_scan/graham_scan.pde */


class GrahamScan {
  int N;
  PVector[] pts;
  int M, j;
  boolean done;

  void setup() {
    done = false;
    // find index of topmost point
    float minY = 3.4028235E38;
    int minYi = -1;

    for(int i = 0; i < pts.length; i++) {
      PVector p = pts[i];
      if(p.y < minY) {
        minY = p.y;
        minYi = i;
      }
    }
    
    //sort, place angle relative to minY point in "z"
    float cx = pts[minYi].x, cy = pts[minYi].y;
    for(int i = 1; i < pts.length; i++) {
      PVector p = pts[i];
      p.z = atan2(p.y-cy, p.x-cx);
    }
    pts[minYi].z = -1; // force to the second location in the sort (after the dummy)
    
    
    
    pts.sort(compare);
    /*Arrays.sort(pts, new Comparator<PVector>() {
      public int compare(PVector p1, PVector p2) {
        return Float.compare(p1.z, p2.z);
      }
    });*/

    // top point is in pts[1]
    // dummy value is in pts[0]    
    pts[0] = pts[N];
    M = 2;
    j = 3;
    // we already know that pts[0], pts[1], and pts[2] and consecutive points on the hull
    // other than that we don't know yet
  }
  
  void next() {
    if(done) return;
    
    if(!cw(pts[M-1], pts[M], pts[j])) {
      if(M == 2) {
        swap(M,j);
        j++;
      } else {
        M--;
      }
    } else {
      M++;
      swap(M,j);
      j++;
    }
    
    if(j > N)  done = true;
  }
  
  void swap(int a, int b) {
    PVector tmp = pts[a];
    pts[a] = pts[b];
    pts[b] = tmp;
  }
}

boolean cw(PVector p1, PVector p2, PVector p3) {
  return (p2.x-p1.x)*(p3.y-p1.y) - (p2.y-p1.y)*(p3.x-p1.x) > 0;
}





class Jarvis {
  int TURN_LEFT=1;
  int TURN_RIGHT=-1;
  int TURN_NONE=0;
  int turn(PVector p, PVector q, PVector r) {
    double val = (q.x-p.x)*(r.y-p.y)-(r.x-p.x)*(q.y-p.y);
    if(val<0) 
      return -1;
    else if(val>0)
      return 1;
    else
      return 0;
  }
  
  double dist(PVector p, PVector q) {
    double dx = q.x - p.x;
    double dy = q.y - p.y;
    return (dx * dx * dy * dy);
  }
  PVector nextHullPt(PVector[] points, PVector p) {
    PVector q = p;
    for(int i = 0; i < points.length; i++) {
      PVector r = points[i];
      int t = turn(p, q, r);
      if (t==TURN_RIGHT || t==TURN_NONE && dist(p, r) > dist(p, q)) {
        q = r;
      }
    }
      return q;
    }
  ArrayList<PVector> convex_hull(PVector[] points) {
    int min = 0;
    for(int i=0; i < points.length; i++) {
      if(points[i].x <= points[min].x) {
        min = i;
      }
    }
    ArrayList<PVector> hull = new ArrayList();
    hull.add(points[min]);
    for(int i = 0; i< hull.size(); i++) {
      PVector temp = hull.get(i);
      PVector q = nextHullPt(points, temp);
      if (q.x != hull.get(0).x && q.y != hull.get(0).y) {
        hull.add(q);
      }
    }
    return hull;
  }
}
  

