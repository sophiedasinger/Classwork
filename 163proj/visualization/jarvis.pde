/* JARVIS MARCH */
/* Code adapted for processing.js from https://gist.github.com/tixxit/252222 */

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
  
