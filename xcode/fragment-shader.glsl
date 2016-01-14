#version 150

// The output of our fragment shader is an RGBA color.
out vec4 oColor;

in vec4 vPosition;

uniform vec2 iMove;
uniform float iScale;
uniform float iSeaLevel;
uniform float iDistortion;

//
// Description : Array and textureless GLSL 2D and 3D simplex noise function.
//      Author : Ian McEwan, Ashima Arts.
//  Maintainer : ijm
//     Lastmod : 20110822 (ijm)
//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
//               Distributed under the MIT License. See LICENSE file.
//               https://github.com/ashima/webgl-noise
//
vec3 mod289(vec3 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}
vec2 mod289(vec2 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}
vec3 permute(vec3 x) {
    return mod289(((x*34.0)+1.0)*x);
}
vec4 mod289(vec4 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}
vec4 permute(vec4 x) {
    return mod289(((x*34.0)+1.0)*x);
}
vec4 taylorInvSqrt(vec4 r)
{
    return 1.79284291400159 - 0.85373472095314 * r;
}
float snoise(vec3 v)
{
    const vec2  C = vec2(1.0/6.0, 1.0/3.0) ;
    const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);
    // First corner
    vec3 i  = floor(v + dot(v, C.yyy) );
    vec3 x0 =   v - i + dot(i, C.xxx) ;
    // Other corners
    vec3 g = step(x0.yzx, x0.xyz);
    vec3 l = 1.0 - g;
    vec3 i1 = min( g.xyz, l.zxy );
    vec3 i2 = max( g.xyz, l.zxy );
    //   x0 = x0 - 0.0 + 0.0 * C.xxx;
    //   x1 = x0 - i1  + 1.0 * C.xxx;
    //   x2 = x0 - i2  + 2.0 * C.xxx;
    //   x3 = x0 - 1.0 + 3.0 * C.xxx;
    vec3 x1 = x0 - i1 + C.xxx;
    vec3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y
    vec3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y
    // Permutations
    i = mod289(i);
    vec4 p = permute( permute( permute(
                                       i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
                              + i.y + vec4(0.0, i1.y, i2.y, 1.0 ))
                     + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));
    // Gradients: 7x7 points over a square, mapped onto an octahedron.
    // The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
    float n_ = 0.142857142857; // 1.0/7.0
    vec3  ns = n_ * D.wyz - D.xzx;
    vec4 j = p - 49.0 * floor(p * ns.z * ns.z);  //  mod(p,7*7)
    vec4 x_ = floor(j * ns.z);
    vec4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)
    vec4 x = x_ *ns.x + ns.yyyy;
    vec4 y = y_ *ns.x + ns.yyyy;
    vec4 h = 1.0 - abs(x) - abs(y);
    vec4 b0 = vec4( x.xy, y.xy );
    vec4 b1 = vec4( x.zw, y.zw );
    //vec4 s0 = vec4(lessThan(b0,0.0))*2.0 - 1.0;
    //vec4 s1 = vec4(lessThan(b1,0.0))*2.0 - 1.0;
    vec4 s0 = floor(b0)*2.0 + 1.0;
    vec4 s1 = floor(b1)*2.0 + 1.0;
    vec4 sh = -step(h, vec4(0.0));
    vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
    vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;
    vec3 p0 = vec3(a0.xy,h.x);
    vec3 p1 = vec3(a0.zw,h.y);
    vec3 p2 = vec3(a1.xy,h.z);
    vec3 p3 = vec3(a1.zw,h.w);
    //Normalise gradients
    vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
    p0 *= norm.x;
    p1 *= norm.y;
    p2 *= norm.z;
    p3 *= norm.w;
    // Mix final noise value
    vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
    m = m * m;
    return 42.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1),
                                 dot(p2,x2), dot(p3,x3) ) );
}
float snoise(vec2 v)
{
    const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                        0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                        -0.577350269189626,  // -1.0 + 2.0 * C.x
                        0.024390243902439); // 1.0 / 41.0
    // First corner
    vec2 i  = floor(v + dot(v, C.yy) );
    vec2 x0 = v -   i + dot(i, C.xx);
    // Other corners
    vec2 i1;
    //i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
    //i1.y = 1.0 - i1.x;
    i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    // x0 = x0 - 0.0 + 0.0 * C.xx ;
    // x1 = x0 - i1 + 1.0 * C.xx ;
    // x2 = x0 - 1.0 + 2.0 * C.xx ;
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    // Permutations
    i = mod289(i); // Avoid truncation effects in permutation
    vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
                     + i.x + vec3(0.0, i1.x, 1.0 ));
    vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
    m = m*m ;
    m = m*m ;
    // Gradients: 41 points uniformly over a line, mapped onto a diamond.
    // The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)
    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;
    // Normalise gradients implicitly by scaling m
    // Approximation of: m *= inversesqrt( a0*a0 + h*h );
    m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
    // Compute final noise value at P
    vec3 g;
    g.x  = a0.x  * x0.x  + h.x  * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
}
vec3 fade(vec3 t) {
    return t*t*t*(t*(t*6.0-15.0)+10.0);
}
// Classic Perlin noise
float cnoise(vec3 P)
{
    vec3 Pi0 = floor(P); // Integer part for indexing
    vec3 Pi1 = Pi0 + vec3(1.0); // Integer part + 1
    Pi0 = mod289(Pi0);
    Pi1 = mod289(Pi1);
    vec3 Pf0 = fract(P); // Fractional part for interpolation
    vec3 Pf1 = Pf0 - vec3(1.0); // Fractional part - 1.0
    vec4 ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
    vec4 iy = vec4(Pi0.yy, Pi1.yy);
    vec4 iz0 = Pi0.zzzz;
    vec4 iz1 = Pi1.zzzz;
    vec4 ixy = permute(permute(ix) + iy);
    vec4 ixy0 = permute(ixy + iz0);
    vec4 ixy1 = permute(ixy + iz1);
    vec4 gx0 = ixy0 * (1.0 / 7.0);
    vec4 gy0 = fract(floor(gx0) * (1.0 / 7.0)) - 0.5;
    gx0 = fract(gx0);
    vec4 gz0 = vec4(0.5) - abs(gx0) - abs(gy0);
    vec4 sz0 = step(gz0, vec4(0.0));
    gx0 -= sz0 * (step(0.0, gx0) - 0.5);
    gy0 -= sz0 * (step(0.0, gy0) - 0.5);
    vec4 gx1 = ixy1 * (1.0 / 7.0);
    vec4 gy1 = fract(floor(gx1) * (1.0 / 7.0)) - 0.5;
    gx1 = fract(gx1);
    vec4 gz1 = vec4(0.5) - abs(gx1) - abs(gy1);
    vec4 sz1 = step(gz1, vec4(0.0));
    gx1 -= sz1 * (step(0.0, gx1) - 0.5);
    gy1 -= sz1 * (step(0.0, gy1) - 0.5);
    vec3 g000 = vec3(gx0.x,gy0.x,gz0.x);
    vec3 g100 = vec3(gx0.y,gy0.y,gz0.y);
    vec3 g010 = vec3(gx0.z,gy0.z,gz0.z);
    vec3 g110 = vec3(gx0.w,gy0.w,gz0.w);
    vec3 g001 = vec3(gx1.x,gy1.x,gz1.x);
    vec3 g101 = vec3(gx1.y,gy1.y,gz1.y);
    vec3 g011 = vec3(gx1.z,gy1.z,gz1.z);
    vec3 g111 = vec3(gx1.w,gy1.w,gz1.w);
    vec4 norm0 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
    g000 *= norm0.x;
    g010 *= norm0.y;
    g100 *= norm0.z;
    g110 *= norm0.w;
    vec4 norm1 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
    g001 *= norm1.x;
    g011 *= norm1.y;
    g101 *= norm1.z;
    g111 *= norm1.w;
    float n000 = dot(g000, Pf0);
    float n100 = dot(g100, vec3(Pf1.x, Pf0.yz));
    float n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z));
    float n110 = dot(g110, vec3(Pf1.xy, Pf0.z));
    float n001 = dot(g001, vec3(Pf0.xy, Pf1.z));
    float n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
    float n011 = dot(g011, vec3(Pf0.x, Pf1.yz));
    float n111 = dot(g111, Pf1);
    vec3 fade_xyz = fade(Pf0);
    vec4 n_z = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z);
    vec2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
    float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x);
    return 2.2 * n_xyz;
}
// Classic Perlin noise, periodic variant
float pnoise(vec3 P, vec3 rep)
{
    vec3 Pi0 = mod(floor(P), rep); // Integer part, modulo period
    vec3 Pi1 = mod(Pi0 + vec3(1.0), rep); // Integer part + 1, mod period
    Pi0 = mod289(Pi0);
    Pi1 = mod289(Pi1);
    vec3 Pf0 = fract(P); // Fractional part for interpolation
    vec3 Pf1 = Pf0 - vec3(1.0); // Fractional part - 1.0
    vec4 ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
    vec4 iy = vec4(Pi0.yy, Pi1.yy);
    vec4 iz0 = Pi0.zzzz;
    vec4 iz1 = Pi1.zzzz;
    vec4 ixy = permute(permute(ix) + iy);
    vec4 ixy0 = permute(ixy + iz0);
    vec4 ixy1 = permute(ixy + iz1);
    vec4 gx0 = ixy0 * (1.0 / 7.0);
    vec4 gy0 = fract(floor(gx0) * (1.0 / 7.0)) - 0.5;
    gx0 = fract(gx0);
    vec4 gz0 = vec4(0.5) - abs(gx0) - abs(gy0);
    vec4 sz0 = step(gz0, vec4(0.0));
    gx0 -= sz0 * (step(0.0, gx0) - 0.5);
    gy0 -= sz0 * (step(0.0, gy0) - 0.5);
    vec4 gx1 = ixy1 * (1.0 / 7.0);
    vec4 gy1 = fract(floor(gx1) * (1.0 / 7.0)) - 0.5;
    gx1 = fract(gx1);
    vec4 gz1 = vec4(0.5) - abs(gx1) - abs(gy1);
    vec4 sz1 = step(gz1, vec4(0.0));
    gx1 -= sz1 * (step(0.0, gx1) - 0.5);
    gy1 -= sz1 * (step(0.0, gy1) - 0.5);
    vec3 g000 = vec3(gx0.x,gy0.x,gz0.x);
    vec3 g100 = vec3(gx0.y,gy0.y,gz0.y);
    vec3 g010 = vec3(gx0.z,gy0.z,gz0.z);
    vec3 g110 = vec3(gx0.w,gy0.w,gz0.w);
    vec3 g001 = vec3(gx1.x,gy1.x,gz1.x);
    vec3 g101 = vec3(gx1.y,gy1.y,gz1.y);
    vec3 g011 = vec3(gx1.z,gy1.z,gz1.z);
    vec3 g111 = vec3(gx1.w,gy1.w,gz1.w);
    vec4 norm0 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
    g000 *= norm0.x;
    g010 *= norm0.y;
    g100 *= norm0.z;
    g110 *= norm0.w;
    vec4 norm1 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
    g001 *= norm1.x;
    g011 *= norm1.y;
    g101 *= norm1.z;
    g111 *= norm1.w;
    float n000 = dot(g000, Pf0);
    float n100 = dot(g100, vec3(Pf1.x, Pf0.yz));
    float n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z));
    float n110 = dot(g110, vec3(Pf1.xy, Pf0.z));
    float n001 = dot(g001, vec3(Pf0.xy, Pf1.z));
    float n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
    float n011 = dot(g011, vec3(Pf0.x, Pf1.yz));
    float n111 = dot(g111, Pf1);
    vec3 fade_xyz = fade(Pf0);
    vec4 n_z = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z);
    vec2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
    float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x);
    return 2.2 * n_xyz;
}
vec2 fade(vec2 t) {
    return t*t*t*(t*(t*6.0-15.0)+10.0);
}
// Classic Perlin noise
float cnoise(vec2 P)
{
    vec4 Pi = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);
    vec4 Pf = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
    Pi = mod289(Pi); // To avoid truncation effects in permutation
    vec4 ix = Pi.xzxz;
    vec4 iy = Pi.yyww;
    vec4 fx = Pf.xzxz;
    vec4 fy = Pf.yyww;
    vec4 i = permute(permute(ix) + iy);
    vec4 gx = fract(i * (1.0 / 41.0)) * 2.0 - 1.0 ;
    vec4 gy = abs(gx) - 0.5 ;
    vec4 tx = floor(gx + 0.5);
    gx = gx - tx;
    vec2 g00 = vec2(gx.x,gy.x);
    vec2 g10 = vec2(gx.y,gy.y);
    vec2 g01 = vec2(gx.z,gy.z);
    vec2 g11 = vec2(gx.w,gy.w);
    vec4 norm = taylorInvSqrt(vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11)));
    g00 *= norm.x;
    g01 *= norm.y;
    g10 *= norm.z;
    g11 *= norm.w;
    float n00 = dot(g00, vec2(fx.x, fy.x));
    float n10 = dot(g10, vec2(fx.y, fy.y));
    float n01 = dot(g01, vec2(fx.z, fy.z));
    float n11 = dot(g11, vec2(fx.w, fy.w));
    vec2 fade_xy = fade(Pf.xy);
    vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
    float n_xy = mix(n_x.x, n_x.y, fade_xy.y);
    return 2.3 * n_xy;
}
// Classic Perlin noise, periodic variant
float pnoise(vec2 P, vec2 rep)
{
    vec4 Pi = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);
    vec4 Pf = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
    Pi = mod(Pi, rep.xyxy); // To create noise with explicit period
    Pi = mod289(Pi);        // To avoid truncation effects in permutation
    vec4 ix = Pi.xzxz;
    vec4 iy = Pi.yyww;
    vec4 fx = Pf.xzxz;
    vec4 fy = Pf.yyww;
    vec4 i = permute(permute(ix) + iy);
    vec4 gx = fract(i * (1.0 / 41.0)) * 2.0 - 1.0 ;
    vec4 gy = abs(gx) - 0.5 ;
    vec4 tx = floor(gx + 0.5);
    gx = gx - tx;
    vec2 g00 = vec2(gx.x,gy.x);
    vec2 g10 = vec2(gx.y,gy.y);
    vec2 g01 = vec2(gx.z,gy.z);
    vec2 g11 = vec2(gx.w,gy.w);
    vec4 norm = taylorInvSqrt(vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11)));
    g00 *= norm.x;
    g01 *= norm.y;
    g10 *= norm.z;
    g11 *= norm.w;
    float n00 = dot(g00, vec2(fx.x, fy.x));
    float n10 = dot(g10, vec2(fx.y, fy.y));
    float n01 = dot(g01, vec2(fx.z, fy.z));
    float n11 = dot(g11, vec2(fx.w, fy.w));
    vec2 fade_xy = fade(Pf.xy);
    vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
    float n_xy = mix(n_x.x, n_x.y, fade_xy.y);
    return 2.3 * n_xy;
}
//
// Black Sea code starts here
// The code in the comments is the original cpu-bound javascript code for each map
//
// The original can be found here
// http://www.kchapelier.com/blacksea/
//
vec2 propensityDistortionMap(vec2 p, float distortionLevel) {
    /*
     mapX.map(function (value, x, y) {
     var dist = noise.perlin2(400 + x / 50, 400 + y / 50) / 40
     + noise.simplex2(400 + x / 25, 400 + y / 25) / 60
     + noise.simplex2(400 + x / 10, 400 + y / 10) / 130;
     return dist * distortionLevel;
     });
     mapY.map(function (value, x, y) {
     var dist = noise.perlin2(4000 + x / 50, 4000 + y / 50) / 40
     + noise.simplex2(4000 + x / 25, 4000 + y / 25) / 60
     + noise.simplex2(4000 + x / 10, 4000 + y / 10) / 130;
     return dist * distortionLevel;
     });
     return {
     x: mapX,
     y: mapY
     };
     */
    vec2 dist = vec2(
                     cnoise(vec2(400. + p.x / 50., 400. + p.y / 50.)) / 40. +
                     snoise(vec2(400. + p.x / 25., 400. + p.y / 25.)) / 60. +
                     snoise(vec2(400. + p.x / 10., 400. + p.y / 10.)) / 130.,
                     cnoise(vec2(4000. + p.x / 50., 4000. + p.y / 50.)) / 40. +
                     snoise(vec2(4000. + p.x / 25., 4000. + p.y / 25.)) / 60. +
                     snoise(vec2(4000. + p.x / 10., 4000. + p.y / 10.)) / 130.
                     );
    return dist * distortionLevel;
}
float heightPropensityMap(vec2 p, vec2 propensityDistortion) {
    /*
     // distortion
     var dx = distortions.x.get(x, y),
     dy = distortions.y.get(x, y);
     var base = Math.abs(Math.min(1, Math.max(-1, Math.min(
     noise.perlin3(x / 400 + dx, y / 400 + dy, 10),
     noise.perlin3(x / 250, y / 250, 15)
     ))));
     // soften with large scale perlin cloud
     var v = Math.min(
     noise.perlin3(x / 300 + dx * 1.3, y / 300 + dy, 50),
     noise.perlin3(x / 300 + dx, y / 300 + dy * 1.3, 50.30)
     );
     var increment = Math.pow(1 - Math.sqrt(Math.abs(v)), 3);
     return Math.max(0, Math.min(1, (base * increment) * 2));
     */
    float dx = propensityDistortion.x;
    float dy = propensityDistortion.y;
    float base = abs(min(
                         cnoise(vec3(p.x / 400. + dx, p.y / 400. + dy, 10.)),
                         cnoise(vec3(p.x / 250., p.y / 250., 15.))
                         ));
    float v = abs(min(
                      cnoise(vec3(p.x / 300. + dx * 1.3, p.y / 300. + dy, 50.)),
                      cnoise(vec3(p.x / 300. + dx, p.y / 300. + dy * 1.3, 50.30))
                      ));
    float increment = pow(1. - sqrt(v), 3.);
    return clamp(base * increment * 2., 0., 1.);
}
float altHeightPropensityMap(vec2 p, vec2 propensityDistortion) {
    /*
     // distortion
     var dx = distortions.x.get(x, y),
     dy = distortions.y.get(x, y);
     var base = Math.abs(Math.pow(0.2, Math.max(-1, Math.min(
     noise.perlin3(x / 200 + dx, y / 200 + dy, 50),
     noise.perlin3(x / 450, y / 450, 55)
     ))));
     base += Math.abs(Math.min(1, Math.max(-1, Math.min(
     noise.perlin3(x / 400 + dx, y / 400 + dy, 10),
     noise.perlin3(x / 250, y / 250, 15)
     ))));
     var v = Math.min(
     noise.perlin3(x / 300 + dx * 1.3, y / 300 + dy, 50),
     noise.perlin3(x / 300 + dx, y / 300 + dy * 1.3, 50.30)
     );
     var increment = Math.pow(1 - Math.sqrt(Math.abs(v)), 3);
     return Math.max(0, Math.min(1, (base * increment) * 2));
     */
    float dx = propensityDistortion.x;
    float dy = propensityDistortion.y;
    float base = abs(pow(0.2, max(-1., min(
                                           cnoise(vec3(p.x / 200. + dx, p.y / 200. + dy, 50.)),
                                           cnoise(vec3(p.x / 450., p.y / 450., 55.))
                                           ))));
    base += abs(min(
                    cnoise(vec3(p.x / 400. + dx, p.y / 400. + dy, 10.)),
                    cnoise(vec3(p.x / 250., p.y / 250., 15.))
                    ));
    float v = abs(min(
                      cnoise(vec3(p.x / 300. + dx * 1.3, p.y / 300. + dy, 50.)),
                      cnoise(vec3(p.x / 300. + dx, p.y / 300. + dy * 1.3, 50.30))
                      ));
    float increment = pow(1. - sqrt(v), 3.);
    return clamp(base * increment * 2., 0., 1.);
}
float lerp(float a, float b, float w) {
    return a + w * (b-a);
}
float heightMap(vec2 p, float propensity, float abyss) {
    /*
    	value = Math.abs(noise.perlin3(x / 1200, y / 1200, 300 + propensity * 0.4 + abyss * 0.2)) * (32 + propensity * 32) +
     noise.simplex2(x / 600, y / 600) * (16 + propensity * 16) +
     noise.perlin2(x / 300, y / 300) * (8 + propensity * 8) +
     noise.perlin2(x / 150, y / 150) * (4 + propensity * 4) +
     noise.perlin2(x / 75, y / 75) * (2 + propensity * 2) +
     noise.simplex2(x / 75, y / 75) +
     noise.perlin2(x / 35, y / 35) +
     noise.perlin2(x / 17, y / 17) * (1 + propensity * propensity * propensity) +
     noise.perlin2(x / 8, y / 8) * 0.5 +
     noise.perlin2(x / 4, y / 4) * 0.2 + propensity;
     value = Math.max(0, Math.min(1, (value + 31) / 100));
     value = Mathp.wshaper(value - (abyss * Math.pow(0.5 - value / 2, 2)), 0, 1, [Math.max(0, value - abyss * 4), 0.5, 1]);
     */
    float value = abs(cnoise(vec3(p.x / 1200., p.y / 1200., 300. + propensity * 0.4 + abyss * 0.2))) * (32. + propensity * 32.);
    value += snoise(vec2(p.x / 600., p.y / 600.)) * (16. + propensity * 16.);
    value += cnoise(vec2(p.x / 300., p.y / 300.)) * (8. + propensity * 8.);
    value += cnoise(vec2(p.x / 150., p.y / 150.)) * (4. + propensity * 4.);
    value += cnoise(vec2(p.x / 75., p.y / 75.)) * (2. + propensity * 2.);
    value += snoise(vec2(p.x / 75., p.y / 75.));
    value += cnoise(vec2(p.x / 35., p.y / 35.));
    value += cnoise(vec2(p.x / 17., p.y / 17.)) * (1. + pow(propensity, 3.));
    value += cnoise(vec2(p.x / 8., p.y / 8.)) * 0.5;
    value += cnoise(vec2(p.x / 4., p.y / 4.)) * 0.2;
    value += propensity;
    value = clamp((value + 31.) / 100., 0., 1.);
    value = value - (abyss * pow(0.5 - value * 0.5, 2.));
    // apply a lerp for values between 0. and 0.5
    if (value > 0. && value <= 0.5) {
        float minv = max(0., value - abyss * 4.);
        value = lerp(minv, 0.5, value * 2.);
    }
    return value;
}
float blackSea(float v, float seaLevel) {
    /*
    	value = Math.max(0, Math.min(255, continentMap.get(x, y) ? (value - 30) * 1.5 : value / 1.75));
     if (highlightMap && !highlightMap.get(x, y)) {
     value = value / 1.75;
     }
     return value;
     */
    if (v >= seaLevel) {
        return (v - 30. / 255.) * 1.5;
    } else {
        return v / 1.75;
    }
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = fragCoord * iScale + iMove;
    vec2 propensityDistortion = propensityDistortionMap(p, iDistortion);
    float heightPropensity = heightPropensityMap(p, propensityDistortion),
    altHeightPropensity = altHeightPropensityMap(p, propensityDistortion),
    height = heightMap(p, heightPropensity, altHeightPropensity);
    height = blackSea(height, iSeaLevel);
    fragColor = vec4(height, height, height,1.0);
}

void main() {
    mainImage(oColor, vPosition.xy);
}