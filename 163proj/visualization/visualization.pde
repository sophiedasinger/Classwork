int NUM_POINTS = 40;
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
  h = 4;
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

              //println("I'm here!");
              /* Account for extra hull that hasn't been "graham scanned" 
                 because it had <= 3 points */
              if(numHulls < numSets) {
                //print("not good\n");
                beginShape();
                strokeWeight(1);
                stroke(colors[numSets-1].r, colors[numSets-1].g, colors[numSets-1].b);
                for(int i=0; i<miniHulls[numSets-1].length; i++) {
                  vertex(miniHulls[numSets-1][i].x, miniHulls[numSets-1][i].y);
                }
                endShape(CLOSE);
              }
              //print("HERE\n");
              ArrayList<PVector> temp = myMarch.convex_hull(pointarray);
              if(temp.size() > h) {
                println("H: " + h);
                /* increment h */
                //println("Incrementing h\n");
                h = h * 2;
                convexHull();
                numHulls = 0;   
                for(int i = 0; i < numSets; i++) {
                    if(miniHulls[i].length > 3) {
                        myScans[i] = new GrahamScan();
                        myScans[i].N = miniHulls[i].length;
                        numHulls++;
                    }
                }
                dataSetup();
                k = 0;
                DONE = false;
              }
              else {
                  print("Doing Jarvis\n");
                  noLoop();
                  beginShape();
                  for(int i = 0; i < temp.size(); i++) {
                    //println(temp[i].x);
                    vertex(temp.get(i).x, temp.get(i).y);
                  }
                  endShape(CLOSE);
                  loop();
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

  //println(numSets);
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



