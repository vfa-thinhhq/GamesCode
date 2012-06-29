//
//  OCRWebService.m
//  CamLingual
//
//  Created by Tsuneo Yoshioka on 8/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
/*
 Copyright (C) Yoshioka Tsuneo (yoshiokatsuneo@gmail.com)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "OCRWebService.h"
#import "DDXML.h"
#import "NSData+Base64.h"

@implementation OCRWebService

@synthesize user_name;
@synthesize license_code;
@synthesize services_url;

@synthesize delegate = _delegate;
@synthesize connection = _connection;
@synthesize error = _error;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.services_url = @"http://www.ocrwebservice.com/services/";
    }
    
    return self;
}
-(void)dealloc
{
    [user_name release];
    [license_code release];
    self.delegate = nil;
    [_connection release];
    [super dealloc];
}
- (void)showxmltree:(DDXMLElement *)element
{
    NSLog(@"Element: %@", [element stringValue]);
    for (DDXMLElement *child in [element children]){
        [self showxmltree:child];
    }
}
- (void)errorAlert:(NSError*)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription] message:[[error userInfo] description] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}





-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.delegate OCRWebService:self didFailWithError:error];
    self.error = error;
    
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpresponse = (NSHTTPURLResponse*) response;
    int status_code = [httpresponse statusCode];
    
    if(status_code != 200){
        NSError *error = [NSError errorWithDomain:@"" code:0 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"Invalid HTTP status code(%d) for URL:%@", status_code,[response URL]] forKey:NSLocalizedDescriptionKey]];
        [self.delegate OCRWebService:self didFailWithError:error];
        self.error = error;
        return;
    }
    
    [self.delegate OCRWebServiceProgress:self message:@"didReceiveResponse" progress:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if(self.error){return;}
    
    [responsebodydata appendData:data];
    [self.delegate OCRWebServiceProgress:self message:[NSString stringWithFormat:@"[%d] bytes received.",[responsebodydata length]] progress:1.0f];
    
}
-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if(totalBytesWritten < totalBytesExpectedToWrite){
        NSString *message = [NSString stringWithFormat:@"Sending image for OCR (%6d/%d)",totalBytesWritten,totalBytesExpectedToWrite];
        [self.delegate OCRWebServiceProgress:self message:message progress:((float)totalBytesWritten/(float)totalBytesExpectedToWrite)];
    }else{
        [self.delegate OCRWebServiceProgress:self message:[NSString stringWithFormat:@"OCR processing...(%dByte)",totalBytesWritten] progress:-1];
        
    }
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if(!self.error){
        NSError *error = nil;
        NSString *responsebody = [[[NSString alloc] initWithData:responsebodydata encoding:NSUTF8StringEncoding] autorelease];
        
        DDXMLDocument *xmlDocument = [[[DDXMLDocument alloc] initWithXMLString:responsebody options:0 error:&error] autorelease];
        if(!xmlDocument){
            [self.delegate OCRWebService:self didFailWithError:error];
        }
        
        DDXMLElement * root = [xmlDocument  rootElement];
        [root addNamespace:[DDXMLNode namespaceWithName:@"myns" stringValue:@"http://stockservice.contoso.com/wse/samples/2005/10"]];
        [self showxmltree:root];
        
        NSArray * array = [root nodesForXPath:@"//myns:OCRWSResponse/myns:ocrText/myns:ArrayOfString/myns:string" error:&error];
        if(!array){
            [self.delegate OCRWebService:self didFailWithError:error];
            return;
        }
        DDXMLElement *element = [array lastObject];
        NSString *ocrText = [element stringValue];
        [self.delegate OCRWebServiceDidFinish:self ocrText:ocrText];
    }
    
    
    self.connection = nil;
    [responsebodydata release]; responsebodydata = nil;
}

- (BOOL)sendRequest:(NSString*)soapAction templatename:(NSString*)templatename subst:(NSDictionary*)subst error:(NSError**)error
{
    if(self.connection){
        [self.connection cancel];
        self.connection = nil;
    }
    NSString *templatefile = [[NSBundle mainBundle] pathForResource:templatename ofType:@"xml"];
    NSString *template = [NSString stringWithContentsOfFile:templatefile encoding:NSUTF8StringEncoding error:error];
    if(!template){
        return NO;
    }

    NSMutableString *requestbody = [template.mutableCopy autorelease];
    for(NSString *key in subst){
        NSString *key2 = [NSString stringWithFormat:@"${%@}",key];
        [requestbody replaceOccurrencesOfString:key2 withString:[subst valueForKey:key] options:0 range:NSMakeRange(0, requestbody.length)];
        
    }
    // NSLog(@"requestbody=[%@]", requestbody);
    
    NSString *ocrwebservice_url_str = [self.services_url stringByAppendingString:@"OCRWebService.asmx"];
    NSURL *url = [NSURL URLWithString:ocrwebservice_url_str];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [urlRequest addValue:[NSString stringWithFormat:@"\"http://stockservice.contoso.com/wse/samples/2005/10/%@\"",soapAction] forHTTPHeaderField:@"SOAPAction"];
    NSData *bodydata = [requestbody dataUsingEncoding:NSUTF8StringEncoding];
    [urlRequest setHTTPBody:bodydata];

    responsebodydata = [[NSMutableData alloc] init];
    self.error = nil;
    self.connection = [[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self] autorelease];

    return YES;
}
#if 0
- (int)OCRWebServiceAvailablePages
{
    NSDictionary *subst = [NSDictionary dictionaryWithObjectsAndKeys:user_name,@"user_name",license_code,@"license_code", nil];
    NSError *error = nil;
    DDXMLDocument *xmlDocument = [self sendRequest:@"OCRWebServiceAvailablePages" templatename:@"OCRWebServiceAvailablePages-request-template" subst:subst error:&error];
    if(!xmlDocument){
        [self errorAlert:error];
        return -1;
    }

    DDXMLElement * root = [xmlDocument  rootElement];
    [root addNamespace:[DDXMLNode namespaceWithName:@"myns" stringValue:@"http://stockservice.contoso.com/wse/samples/2005/10"]];
    [self showxmltree:root];
    
    NSArray * array = [root nodesForXPath:@"//myns:OCRWebServiceAvailablePagesResult" error:&error];
    if(!array){
        [self errorAlert:error];
        return -1;        
    }
    DDXMLElement *element = [array lastObject];
    NSString *pagesstr = [element stringValue];
    int pages = [pagesstr intValue];
    return pages;
    
}
#endif
- (BOOL)OCRWebServiceRecognize:(NSString *)imagefile ocrLanguage:(NSString *)ocrLanguage outputDocumentFormat:(NSString *)outputDocumentFormat delegate:(id<OCRWebServiceDelegate>)delegate
{
    NSError *error = nil;
    NSData *imagedata = [NSData dataWithContentsOfFile:imagefile options:0 error:&error];
    if(!imagedata){
        [self errorAlert:error];
        return NO;
    }
    NSString *imagedatastr = [imagedata base64EncodedString];
    
    if([ocrLanguage isEqual:@"NORWEGIAN"] || [ocrLanguage isEqual:@"AFRIKAANS"]){
        ocrLanguage = @"DANISH";
    }else if([ocrLanguage isEqual:@"FILIPINO"]){
        ocrLanguage = @"ENGLISH";
    }else if([ocrLanguage isEqual:@"MALAY"]){
        ocrLanguage = @"INDONESIAN";
    }
    NSDictionary *subst = [NSDictionary dictionaryWithObjectsAndKeys:user_name,@"user_name",license_code,@"license_code", imagefile, @"imagefilename", imagedatastr, @"imagedata", ocrLanguage, @"language", nil];
    
    self.delegate = delegate;
    [self sendRequest:@"OCRWebServiceRecognize" templatename:@"OCRWebServiceRecognize-request-template" subst:subst error:&error];
    return YES;
}
@end

