//
//  SEGOutboundIntegrationTests.m
//  Analytics
//
//  Created by Prateek Srivastava on 2015-08-13.
//  Copyright (c) 2015 Segment.io. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SEGOutboundIntegration.h"
#import <Outbound.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>


@interface SEGOutboundIntegrationTests : XCTestCase

@property SEGOutboundIntegration *integration;
@property Outbound *obMock;
@property Class obClassMock;

@end

@implementation SEGOutboundIntegrationTests

- (void)setUp {
    [super setUp];

    [Outbound initWithPrivateKey:@"FAKE API KEY"];
    _obMock = mockClass([Outbound class]);
    
    _integration = [[SEGOutboundIntegration alloc]init];
    [_integration setOutboundClass:_obMock];
}

- (void)testIdentify {
    [_integration identify:@"foo" traits:@{ @"bar" : @"baz",
                                            @"first_name": @"Bob",
                                            @"last_name": @"Dorsey",
                                            @"email": @"dorsey@bob.com",
                                            @"phone": @"+1-555-555-5555"} options:@{}];

    [verifyCount(_obMock, times(1)) identifyUserWithId:@"foo"
                                            attributes:@{ @"first_name": @"Bob",
                                                          @"last_name": @"Dorsey",
                                                          @"email": @"dorsey@bob.com",
                                                          @"phone_number": @"+1-555-555-5555",
                                                          @"attributes": @{@"bar" : @"baz"} }];
}

- (void)testIdentifyNameBecomesFirstLast {
    [_integration identify:@"foo" traits:@{ @"bar" : @"baz",
                                            @"name": @"Bob Dorsey"} options:@{}];
    
    [verifyCount(_obMock, times(1)) identifyUserWithId:@"foo"
                                            attributes:@{ @"first_name": @"Bob",
                                                          @"last_name": @"Dorsey",
                                                          @"attributes": @{@"bar" : @"baz"} }];
}

- (void)testIdentifyFirstLastMapping {
    [_integration identify:@"foo" traits:@{ @"bar" : @"baz",
                                            @"firstName": @"Bob",
                                            @"lastName": @"Dorsey",
                                            @"email": @"dorsey@bob.com",
                                            @"phone": @"+1-555-555-5555"} options:@{}];
    
    [verifyCount(_obMock, times(1)) identifyUserWithId:@"foo"
                                            attributes:@{ @"first_name": @"Bob",
                                                          @"last_name": @"Dorsey",
                                                          @"email": @"dorsey@bob.com",
                                                          @"phone_number": @"+1-555-555-5555",
                                                          @"attributes": @{@"bar" : @"baz"} }];
}

- (void) testTrack
{
    [_integration track:@"click event" properties:@{@"item": @"button", @"deep": @{@"foo": @"bar"}} options:@{}];
    [verifyCount(_obMock, times(1)) trackEvent: @"click event" withProperties:@{@"item": @"button", @"deep": @{@"foo": @"bar"}}];
}

- (void) testScreen
{
    [_integration screen:@"homepage" properties:@{@"ts": @"3"} options:@{}];
    [verifyCount(_obMock, times(1)) trackEvent: @"Viewed homepage Screen" withProperties:@{@"ts": @"3"}];
}

- (void)testReset
{
    [_integration reset];
    [verifyCount(_obMock, times(1)) logout];
}


@end
