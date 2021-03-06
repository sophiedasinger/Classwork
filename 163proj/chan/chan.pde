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





