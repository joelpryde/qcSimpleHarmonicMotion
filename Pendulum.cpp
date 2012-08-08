#include "Pendulum.h"

#define PI 3.14159

Pendulum::Pendulum(int _count, int _index, float _freq, int _pitch) 
{
    count = _count;
    index = _index;
    freq = _freq;
    pitch = _pitch;
    pos = 1;
    vel = 0;
    hit = 0;
}

// update position and trigger sound if nessecary
void Pendulum::update(float _t, float _c, float _width, float _height, float _size) 
{
    float oldPos = pos;     // save old position
    float oldVel = vel;     // save old direction
    
    pos = cos(freq * _t * 2 * PI);  // calculate new position
    vel = pos - oldPos;            // calculte new direction
    
    if (vel * oldVel <= 0.0) {     // if pendulum has changed direction...
        //playMidiNote(index, pitch, pos < 0 ? 0 : 127);
        hit = 1;
    }
    else {
        hit *= 0.85;
    }
    
    pt = Vec2f(lmap((float)_c, 0.0f, (float)count-1.0f, _size/2.0f, _width - _size/2.0f), 
               lmap(pos, -1.0f, 1.0f, _size/2.0f, _height-_size/2.0f));
    size = _size;
}

// draw
void Pendulum::draw(Pendulum** pendulums, int count) 
{
    // set color
    float r = lerp(0.1f, 1.0f, hit);
    float g = lerp(0.1f, 0.0f, hit);
    float b = lerp(0.1f, 0.0f, hit);
    
    // draw circle
    gl::color(r, g, b);
    gl::drawSolidEllipse(pt, size, size);
    
    gl::color(1.0f, 1.0f, 1.0f);
    gl::drawStrokedEllipse(pt, size, size);
    
    for (int i=0; i<count; i++)
    {
        if (pendulums[i] != this)
        {
            gl::enableAlphaBlending();
            float alpha = lmap(pt.distance(pendulums[i]->pt), 0.0f, 300.0f, 1.0f, 0.0f);
            gl::color(1.0f, 1.0f, 1.0f, alpha);
            gl::drawLine(pt, pendulums[i]->pt);
        }
    }
}

