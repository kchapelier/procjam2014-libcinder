#include "SaveImage.h"

#include "cinder/Utilities.h"
#include "cinder/gl/Fbo.h"

int count = 0;
cinder::fs::path currentPath = cinder::fs::path();

inline std::string zeroPadNumber(int num)
{
    std::ostringstream ss;
    ss << std::setw( 10 ) << std::setfill( '0' ) << num;
    return ss.str();
}

inline ci::fs::path getPath(destination dest) {
    switch(dest)
    {
        case destination::CURRENT:
            if(currentPath.empty()) {
                currentPath.append(getcwd(NULL, 0));
            }
            
            return currentPath;
            
            break;
        case destination::DOCUMENTS:
            return ci::getDocumentsDirectory();
            
            break;
        case destination::HOME:
            return ci::getHomeDirectory();
            
            break;
    }
}

inline ci::Surface convertFboToSurface(ci::gl::Fbo fbo) {
    return *ci::Surface::create(fbo.getColorTexture()->createSource());
}

inline ci::Surface convertFboRefToSurface(ci::gl::FboRef fboRef) {
    return *ci::Surface::create(fboRef->getColorTexture()->createSource());
}

void saveImage(ci::Surface surface, destination dest, std::string filename, bool useTimestamp) {
    ci::fs::path path = getPath(dest);
    
    int number = useTimestamp ? std::time(nullptr) : ++count;
    
    path /= (filename + "." +  zeroPadNumber( number ) + ".png" );
    
    std::cout << "File saved: " + path.string() << std::endl;
    
    writeImage(path, surface);
}

void saveImage(ci::Surface surface, std::string filename, bool useTimestamp) {
    saveImage(surface, destination::CURRENT, filename, useTimestamp);
}

void saveImage(ci::Surface surface, std::string filename) {
    saveImage(surface, destination::CURRENT, filename, false);
}

void saveImage(ci::gl::Fbo fbo, destination dest, std::string filename, bool useTimestamp) {
    saveImage(convertFboToSurface(fbo), dest, filename, useTimestamp);
}

void saveImage(ci::gl::Fbo fbo, std::string filename, bool useTimestamp) {
    saveImage(convertFboToSurface(fbo), destination::CURRENT, filename, useTimestamp);
}

void saveImage(ci::gl::Fbo fbo, std::string filename) {
    saveImage(convertFboToSurface(fbo), destination::CURRENT, filename, false);
}

void saveImage(ci::gl::FboRef fboRef, destination dest, std::string filename, bool useTimestamp) {
    saveImage(convertFboRefToSurface(fboRef), dest, filename, useTimestamp);
}

void saveImage(ci::gl::FboRef fboRef, std::string filename, bool useTimestamp) {
    saveImage(convertFboRefToSurface(fboRef), destination::CURRENT, filename, useTimestamp);
}

void saveImage(ci::gl::FboRef fboRef, std::string filename) {
    saveImage(convertFboRefToSurface(fboRef), destination::CURRENT, filename, false);
}

void saveImage(destination dest, std::string filename, bool useTimestamp) {
    saveImage(cinder::app::copyWindowSurface(), dest, filename, useTimestamp);
}

void saveImage(std::string filename, bool useTimestamp) {
    saveImage(cinder::app::copyWindowSurface(), destination::CURRENT, filename, useTimestamp);
}

void saveImage(std::string filename) {
    saveImage(cinder::app::copyWindowSurface(), destination::CURRENT, filename, false);
}