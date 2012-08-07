#include "Pendulum.h"

#define PI 3.14159

Pendulum::Pendulum(int _index, float _freq, int _pitch) 
{
    index = _index;
    freq = _freq;
    pitch = _pitch;
    pos = 1;
    vel = 0;
    hit = 0;
}

// update position and trigger sound if nessecary
void Pendulum::update(float _t, float _x, float _size) 
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
    
    pt = Vec2f(_x, lmap(pos, -1.0f, 1.0f, _size/2.0f, 480.0f-_size/2.0f));
    size = _size;
}

// draw
void Pendulum::draw(Pendulum** pendulums) 
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
    
    for (int i=0; i<15; i++)
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

