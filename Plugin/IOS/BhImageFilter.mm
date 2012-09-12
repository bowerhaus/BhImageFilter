//
// BhImageFilter.mm
// Image filters plugin for Gideros Studio (IOS Only)
//
// MIT License
// Copyright (C) 2012. Andy Bower, Bowerhaus LLP
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software
// and associated documentation files (the "Software"), to deal in the Software without restriction,
// including without limitation the rights to use, copy, modify, merge, publish, distribute,
// sublicense, and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
// BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#include "gideros.h"
#include "UIImage+StackBlur.h"
#include "UIImage+Resize.h"

@interface ImageFilterHelper : NSObject
@property(nonatomic, retain) UIImage *workingImage;

- (ImageFilterHelper *)initWithL:(lua_State *)state;

- (lua_Integer)getPixelX:(NSUInteger)integer y:(NSUInteger)integer1;
@end

@interface ImageFilterHelper ()
- (bool)loadImage:(NSString *)filename;
- (bool)blur:(NSUInteger)blurAmount;
- (bool)saveImage:(NSString *)filename;
@end

@implementation ImageFilterHelper {
    lua_State *L;
    UIImage *workingImage;
    CFDataRef pixelData;
}
@synthesize workingImage;

-(ImageFilterHelper *)initWithL:(lua_State *)state  {
    self = [super init];
    if (self) {
        L=state;
    }
    return self;
}

-(void) dealloc {
    [self releasePixelData];
    [workingImage release];
    [super dealloc] ;
}

-(bool) loadImage: (NSString *)filename  {
    self.workingImage = [UIImage imageWithContentsOfFile: filename];
    return workingImage != nil;
}

-(CFDataRef) getPixelData {
    if (pixelData==nil) {
        pixelData = CGDataProviderCopyData(CGImageGetDataProvider(workingImage.CGImage));
    }
    return pixelData;
}

-(void)releasePixelData {
    if (pixelData) {
        CFRelease(pixelData);
        pixelData=nil;
    }
}

-(bool) blur: (NSUInteger)blurAmount  {
    bool result=false;
    UIImage *blurredImage = [workingImage stackBlur: blurAmount ];
    if (blurredImage) {
        [self releasePixelData];
        self.workingImage=blurredImage;
        result=true;
    }
    return result;
}

-(bool) resizeWidth: (CGFloat)width height: (CGFloat)height  {
    bool result=false;
    CGSize size = CGSizeMake(width, height);
    UIImage *blurredImage = [workingImage resizedImage:size interpolationQuality:  kCGInterpolationDefault];
    if (blurredImage) {
        [self releasePixelData];
        self.workingImage=blurredImage;
        result=true;
    }
    return result;
}

- (lua_Integer)getPixelX:(NSUInteger)x y:(NSUInteger)y {
    const UInt8* data = CFDataGetBytePtr([self getPixelData]);

    NSUInteger pixelInfo = (NSUInteger) (((workingImage.size.width  * y) + x ) * 4);
    UInt8 red = data[pixelInfo];
    UInt8 green = data[(pixelInfo + 1)];
    UInt8 blue = data[pixelInfo + 2];
    UInt8 alpha = data[pixelInfo + 3];

    return ((alpha*256+red)*256+green)*256+blue;
}

-(bool) saveImage: (NSString *)filename  {
    [UIImagePNGRepresentation(self.workingImage) writeToFile:filename atomically:YES];
    return true;
}

@end

static ImageFilterHelper *filterHelper;

static int loadImage(lua_State *L) {
    NSString* imageName = [NSString stringWithUTF8String: luaL_checkstring(L, 1)];
    if (filterHelper==nil)
        filterHelper = [[ImageFilterHelper alloc] initWithL: L];
    bool result=[filterHelper loadImage: imageName];
    lua_pushboolean(L, result);
    return 1;
}

static int blur(lua_State *L) {
    bool result=false;
    if (filterHelper)  {
        NSUInteger blurAmount = (NSUInteger) luaL_checkinteger(L, 1);
        result=[filterHelper blur: blurAmount];
    }
    lua_pushboolean(L, result);
    return 1;
}

static int resize(lua_State *L) {
    bool result=false;
    if (filterHelper)  {
        NSUInteger width = (NSUInteger) luaL_checkinteger(L, 1);
        NSUInteger height = (NSUInteger) luaL_checkinteger(L, 2);
        result=[filterHelper resizeWidth: width height: height];
    }
    lua_pushboolean(L, result);
    return 1;
}

static int getPixel(lua_State *L) {
    lua_Integer result=0;
    if (filterHelper)  {
        NSUInteger x = (NSUInteger) luaL_checkinteger(L, 1);
        NSUInteger y = (NSUInteger) luaL_checkinteger(L, 2);
        result=[filterHelper getPixelX: x y: y];
    }
    lua_pushinteger(L, result);
    return 1;
}

static int saveImage(lua_State *L) {
    NSString* imageName = [NSString stringWithUTF8String: luaL_checkstring(L, 1)];
    bool result=false;
    if (filterHelper)  {
        result=[filterHelper saveImage:imageName];
    }
    lua_pushboolean(L, result);
    return 1;
}

static int closeImage(lua_State *L) {
    bool result=false;
    if (filterHelper)  {
        [filterHelper release];
        filterHelper=nil;
        result=true;
    }
    lua_pushboolean(L, result);
    return 1;
}

static int getDocumentsDirectory(lua_State *L) {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    lua_pushstring(L, [basePath UTF8String] );
    return 1;
}

static int getResourcesDirectory(lua_State *L) {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    lua_pushstring(L, [basePath UTF8String] );
    return 1;
}

static int getCachesDirectory(lua_State *L) {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    lua_pushstring(L, [basePath UTF8String] );
    return 1;
}

static int getPathForFile(lua_State *L) {
    NSString* filename = [NSString stringWithUTF8String: luaL_checkstring(L, 1)];
    lua_pushstring(L, g_pathForFile([filename UTF8String]) );
    return 1;
}

static int loader(lua_State *L)
{
    //This is a list of functions that can be called from Lua
    const luaL_Reg functionlist[] = {
        {"loadImage", loadImage},
        {"blur", blur},
        {"resize", resize},
        {"saveImage", saveImage},
        {"closeImage", closeImage},
        {"getPixel", getPixel},
        {"getDocumentsDirectory", getDocumentsDirectory} ,
        {"getResourcesDirectory", getResourcesDirectory} ,
        {"getCachesDirectory", getCachesDirectory} ,
        {"getPathForFile", getPathForFile} ,
        {NULL, NULL},
    };
    luaL_register(L, "BhImageFilter", functionlist);

    //return the pointer to the plugin
    return 1;
}

static void g_initializePlugin(lua_State* L)
{
    lua_getglobal(L, "package");
    lua_getfield(L, -1, "preload");

    lua_pushcfunction(L, loader);
    lua_setfield(L, -2, "BhImageFilter");

    lua_pop(L, 2);
}

static void g_deinitializePlugin(lua_State *) {
}

REGISTER_PLUGIN("BhImageFilter", "1.0")