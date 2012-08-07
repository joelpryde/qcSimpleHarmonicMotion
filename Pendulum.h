#include "cinder/app/AppBasic.h"
#include "cinder/gl/gl.h"

using namespace ci;
using namespace ci::app;
using namespace std;

class Pendulum 
{
    // physical params
    int index;
    float freq;      // oscilations per second
    
    // physical vars
    float pos;       // position of pendulum (-1...1)
    float vel;       // current velocity
    Vec2f pt;
    float size;
    
    // musical params
    int pitch;      // midi note number to trigger
    
    // display params
    float hit;      // 0...1, how recently we 'hit' the edge
    
    // contructor
public:
    Pendulum(int _index, float _freq, int _pitch);
    
    // update position and trigger sound if nessecary
    void update(float _t, float _x, float _size);
    
    // draw
    void draw(Pendulum** pendulums);
};