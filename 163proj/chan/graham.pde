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



