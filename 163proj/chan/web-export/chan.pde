int NUM_POINTS = 30;
ArrayList<PVector> points;
PVector[] pointarray;
int WIDTH = 500;
int HEIGHT = 1000;
PVector[][] miniHulls;
int numSets;
int k;
/* ADDED */
GrahamScan[] myScans;
ArrayList[] hulls;
boolean DONE;
Jarvis myMarch;

int compare(PVector a, PVector b) {
  if (a.z < b.z)
     return -1;
  if (a.z > b.z)
    return 1;
  return 0;
}

void setup() {
  DONE = false;
  size(1000, 500); 
  background(51);
  strokeWeight(5);
  points = new ArrayList();
  k=0;
  makePoints();
  convexHull();
  hulls = new ArrayList[numSets];
  /* ADDED */
  myMarch = new Jarvis();
  myScans = new GrahamScan[numSets];
  for(int i = 0; i < numSets; i++) {
    myScans[i] = new GrahamScan();
  }
  dataSetup();
  frameRate(10);
   
}


void dataSetup() {
  /* ADDED LOOP */
  for(int i = 0; i < numSets; i++) {
      PVector[] hull = miniHulls[i];
      int len = hull.length;
      //println("Length:" + len);
      myScans[i].pts = new PVector[len+1];
      /* Get out hull points */
      
      myScans[i].pts[0] = new PVector(3.4028235E38,3.4028235E38,-2); // dummy value, placeholder
      
      for(int j = 1; j < myScans[i].pts.length; j++) {
        float x = hull[j-1].x;
        float y = hull[j-1].y;
        myScans[i].pts[j] = new PVector(x, y, 0.0);
        //println("in here");
      }
      /*COMMENTED OUT! */
      /*scan = new GrahamScan();*/
      /*scan.setup(); */
      myScans[i].setup();
  }
}



void draw() {
            
            background(255);
            ellipseMode(RADIUS);
            smooth();
            strokeWeight(2);
            noFill();
            stroke(128);
            //beginShape();
            for (int i=0; i<pointarray.length; i++) {
              strokeWeight(5);
              float x_val = pointarray[i].x;
              float y_val = pointarray[i].y; 
              point(x_val, y_val);
            }
            if(DONE == true) {
              frameRate(0.5);
              stroke(76, 0, 163);
              noLoop();
              println("HELLO");
              beginShape();
              ArrayList<PVector> temp = myMarch.convex_hull(pointarray);
              for(int i=0; i<temp.size(); i++) {
                vertex(temp.get(i).x, temp.get(i).y);
                }
              endShape(CLOSE);
            }
            frameRate(10);
            stroke(128);
            strokeWeight(1);
            //if(DONE != true) {
            if (k>0 && myScans[k-1].done == true) {

              for (int i = 0; i < k; i++) {
                ArrayList temp = hulls[i];
                println(hulls[i]);
                beginShape();
                for(int p = 0; p<temp.size(); p++) {
                  PVector temp2 = (PVector)temp.get(p);
                  vertex(temp2.x, temp2.y);
                }
                endShape(CLOSE);
              }
              if(myScans[k].done == true && k == (numSets-1)) {
                ArrayList temp = hulls[k];
                println(hulls[k]);
                beginShape();
                for(int p = 0; p<temp.size(); p++) {
                  PVector temp2 = (PVector)temp.get(p);
                  vertex(temp2.x, temp2.y);
                }
                endShape(CLOSE);
                DONE = true;
            }
            }
                 
              
            strokeWeight(2);
            println("K: " + k);
            hulls[k] = new ArrayList();
            beginShape();
            for(int i = 0; i < myScans[k].M; i++) {
              vertex(myScans[k].pts[i].x, myScans[k].pts[i].y); 
               //println(i);
              /* add to hull array */
              PVector point = new PVector(myScans[k].pts[i].x, myScans[k].pts[i].y, 0);
              //println(point);
              hulls[k].add(point);
              //println("Hulls: " + hulls[0]);
            }
            
            endShape(myScans[k].done?CLOSE:OPEN);
            
            noStroke(); fill(0);
            for(PVector p : myScans[k].pts) {
              //ellipse(p.x, p.y, 5, 5);
            }
            
            if(!myScans[k].done) {
              // current point of inspection
              /*stroke(#ff66AA); fill(#ff66AA);
              PVector cur = myScans[k].pts[myScans[k].j];
              PVector start = myScans[k].pts[1];
              ellipse(cur.x, cur.y, 5, 5);
              line(cur.x, cur.y, start.x, start.y);*/
              myScans[k].next();
            }
            else {
               if((k+1)<myScans.length) {
                 k++;
               }
            } 
            //s}
}

/* Generates a random set of points of size NUM_POINTS
 * How do I make sure that these points are in general position?
 */
void makePoints() {
  for (int i = 0; i < NUM_POINTS; i++) {
     double x_val = random(0, HEIGHT);
     double y_val = random(0, WIDTH);
     PVector point = new PVector((float)x_val, (float)y_val);
     points.add(point);  
  } 
  pointarray = new PVector[points.size()];
  pointarray = points.toArray(pointarray);  
}

/* Generates point sets 
 */
void convexHull() {
  int h = 6;
  numSets = (int)ceil(NUM_POINTS / h);
  miniHulls = new PVector[numSets][];
  int count = 0;
  int i;
  int len = pointarray.length;
  for(i=0; i<NUM_POINTS; i+=h) {
    if((i+h)-1 >= NUM_POINTS) {

     arrayCopy(pointarray, i, miniHulls[count], 0, len);
     break;
    }
    miniHulls[count] = new PVector[h];
    arrayCopy(pointarray, i, miniHulls[count], 0, h);
    count++;
  }

}





/* CODE FOR GRAHAM SCAN */
/* Adapted for Processing.js from Processing Graham Scan */
/* http://www.cc.gatech.edu/grads/m/mluffel/2011/graham_scan/graham_scan.pde */

int N = 6;

class GrahamScan {
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

void mousePressed() {
  dataSetup();
}



/* CODE FOR JARVIS MARCH */
/* Adapted for Processing from a Python program for the Jarvis March algorithm */
/* Source: https://gist.github.com/tixxit/252222 */

class Jarvis {
  int TURN_LEFT=1;
  int TURN_RIGHT=-1;
  int TURN_NONE=0;
  
  int turn(PVector p, PVector q, PVector r) {
    double val=(q.x-p.x)*(r.y-p.y)-(r.x-p.x)*(q.y-p.y);
    if(val<0) 
      return -1;
    else if(val>0)
      return 1;
    else
      return 0;
  }
  
  double dist(PVector p, PVector q) {
    double dx=q.x - p.x;
    double dy=q.y - p.y;
    return (dx * dx * dy * dy);
  }
  PVector nextHullPt(PVector[] points, PVector p) {
    PVector q=p;
    for(int i=0; i<points.length; i++) {
      PVector r=points[i];
      int t=turn(p, q, r);
      if (t==TURN_RIGHT || t==TURN_NONE && dist(p, r)>dist(p, q)) {
        q = r;
      }
    }
      return q;
    }
  ArrayList<PVector> convex_hull(PVector[] points) {
    int min=0;
    for(int i=0; i<points.length; i++) {
      if(points[i].x<=points[min].x) {
        min=i;
      }
    }
    ArrayList<PVector> hull=new ArrayList();
    hull.add(points[min]);
    for(int i=0; i< hull.size(); i++) {
      PVector temp=hull.get(i);
      PVector q=nextHullPt(points, temp);
      if (q.x!=hull.get(0).x && q.y!=hull.get(0).y) {
        hull.add(q);
      }
    }
    return hull;
  }
}
  

