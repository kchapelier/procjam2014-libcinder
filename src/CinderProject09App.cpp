#include "cinder/app/App.h"
#include "cinder/app/RendererGl.h"
#include "cinder/gl/gl.h"
#include "cinder/gl/Fbo.h"
#include "cinder/gl/GlslProg.h"
#include "cinder/gl/Shader.h"
#include "cinder/TriMesh.h"
#include "Resources.h"

#include "SaveImage.h"

class CinderProject09App : public ci::app::App {
  public:
	void setup() override;
    void buildTriangle();
    void keyDown( ci::app::KeyEvent event ) override;
    void keyUp( ci::app::KeyEvent event ) override;
    void mouseDown( ci::app::MouseEvent event ) override;
    void mouseDrag( ci::app::MouseEvent event ) override;
    void mouseUp( ci::app::MouseEvent event ) override;
    void mouseWheel( ci::app::MouseEvent event ) override;
	void update() override;
	void draw() override;
    void resize() override;
    
    double previous;
    ci::vec2 iMove;
    float iScale;
    
    ci::vec2 downPosition;
    ci::vec2 currentPosition;
    bool down;
    bool makeScreenshot;
    
    float seaLevelIncrement;
    float iSeaLevel;
    
    float distortionIncrement;
    float iDistortion;
    
    ci::TriMesh triangle;
    ci::gl::GlslProgRef glsl;
};

void CinderProject09App::setup()
{
    down = false;
    downPosition = ci::vec2(0);
    currentPosition = ci::vec2(0);
    makeScreenshot = false;
    
    iSeaLevel = 0.45;
    seaLevelIncrement = 0;
    
    iDistortion = 1.;
    distortionIncrement = 0;
    
    iMove = ci::vec2(0);
    iScale = 1.5;
    
    setWindowSize(ci::vec2(800,460));
    setFrameRate(60.);
    
    try {
        glsl = ci::gl::GlslProg::create( loadResource(VERTEXSHADER), loadResource(FRAGMENTSHADER) );
    } catch( const std::exception &e ) {
        // if anything went wrong, show it in the output window
        console() << e.what() << std::endl;
    }
    
    triangle = ci::TriMesh(ci::TriMesh::Format().positions(2).colors(3));
    buildTriangle();
}

void CinderProject09App::buildTriangle()
{
    ci::vec2 size = getWindowSize();
    
    triangle.clear();
    triangle.appendPosition(ci::vec2(0, 0));
    triangle.appendColorRgb(ci::Color(1., 0., 0.));
    triangle.appendPosition(ci::vec2(2 * size.x, 0));
    triangle.appendColorRgb(ci::Color(0., 1., 0.));
    triangle.appendPosition(ci::vec2(0, 2 * size.y));
    triangle.appendColorRgb(ci::Color(0., 0., 1.));
    triangle.appendTriangle(0, 1, 2);
}

void CinderProject09App::keyDown( ci::app::KeyEvent event ) {
    if( event.getCode() == ci::app::KeyEvent::KEY_UP ) {
        seaLevelIncrement = 0.002;
    } else if( event.getCode() == ci::app::KeyEvent::KEY_DOWN ) {
        seaLevelIncrement = -0.002;
    }
    
    if( event.getCode() == ci::app::KeyEvent::KEY_RIGHT ) {
        distortionIncrement = 0.05;
    } else if( event.getCode() == ci::app::KeyEvent::KEY_LEFT ) {
        distortionIncrement = -0.05;
    }
}

void CinderProject09App::keyUp( ci::app::KeyEvent event ) {
    if( event.getCode() == ci::app::KeyEvent::KEY_UP ) {
        seaLevelIncrement = 0.;
    } else if( event.getCode() == ci::app::KeyEvent::KEY_DOWN ) {
        seaLevelIncrement = 0.;
    }
    
    if( event.getCode() == ci::app::KeyEvent::KEY_RIGHT ) {
        distortionIncrement = 0.;
    } else if( event.getCode() == ci::app::KeyEvent::KEY_LEFT ) {
        distortionIncrement = 0.;
    }
    
    if ( event.getChar() == 'p' ) {
        makeScreenshot = true;
    }
}

void CinderProject09App::mouseDown( ci::app::MouseEvent event )
{
    if (!down) {
        down = true;
        currentPosition.x = downPosition.x = event.getX();
        currentPosition.y = downPosition.y = event.getY();
    }
}

void CinderProject09App::mouseDrag(cinder::app::MouseEvent event)
{
    if (down) {
        currentPosition.x = event.getX();
        currentPosition.y = event.getY();
    }
}

void CinderProject09App::mouseUp( ci::app::MouseEvent event )
{
    if (down) {
        down = false;
        currentPosition.x = downPosition.x = 0;
        currentPosition.y = downPosition.y = 0;
    }
}

inline float clamp(float x, float a, float b)
{
    return x < a ? a : (x > b ? b : x);
}

void CinderProject09App::mouseWheel(cinder::app::MouseEvent event)
{
    iScale -= event.getWheelIncrement() * 0.1;
    iScale = clamp(iScale, 0.5, 5.);
}

void CinderProject09App::update()
{
    double time = getElapsedSeconds() * 1000;
    double deltaTime = time - previous;
    double rate = deltaTime / 16.6666; // 16 ms per frame for 60fps
    previous = time;
    
    if (down) {
        iMove.x += (downPosition.x - currentPosition.x) / 10. * rate;
        iMove.y += (downPosition.y - currentPosition.y) / 10. * rate;
    }
    
    iSeaLevel = clamp(iSeaLevel + seaLevelIncrement * rate, 0., 1.);
    iDistortion = clamp(iDistortion + distortionIncrement * rate, 0., 5.);
}

void CinderProject09App::resize()
{
    buildTriangle();
}

void CinderProject09App::draw()
{
    glsl->uniform( "iMove", iMove );
    glsl->uniform( "iScale", iScale );
    glsl->uniform( "iSeaLevel", iSeaLevel );
    glsl->uniform( "iDistortion", iDistortion );
    
    ci::gl::clear( ci::Color( 0, 0, 0 ) );
    ci::gl::ScopedGlslProg shader( glsl );
    ci::gl::draw(triangle);
    
    if (makeScreenshot) {
        saveImage("black-sea");
        makeScreenshot = false;
    }
}

CINDER_APP( CinderProject09App, ci::app::RendererGl )
