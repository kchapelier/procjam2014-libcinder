#ifndef __Kchplr_SaveImage__
#define __Kchplr_SaveImage__

#include <stdio.h>

enum destination {
    CURRENT = 0,
    HOME = 1,
    DOCUMENTS = 2
};

void saveImage(ci::Surface surface, destination dest, std::string filename, bool useTimestamp);
void saveImage(ci::Surface surface, std::string filename, bool useTimestamp);
void saveImage(ci::Surface surface, std::string filename);

void saveImage(ci::gl::Fbo fbo, destination dest, std::string filename, bool useTimestamp);
void saveImage(ci::gl::Fbo fbo, std::string filename, bool useTimestamp);
void saveImage(ci::gl::Fbo fbo, std::string filename);

void saveImage(ci::gl::FboRef fboRef, destination dest, std::string filename, bool useTimestamp);
void saveImage(ci::gl::FboRef fboRef, std::string filename, bool useTimestamp);
void saveImage(ci::gl::FboRef fboRef, std::string filename);

void saveImage(destination dest, std::string filename, bool useTimestamp);
void saveImage(std::string filename, bool useTimestamp);
void saveImage(std::string filename);

#endif /* defined(__Kchplr_SaveImage__) */
