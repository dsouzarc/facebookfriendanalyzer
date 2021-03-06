//
//  Person.h
//  Facebook Friend Analyzer
//
//  Created by Ryan D'souza on 7/13/15.
//  Copyright (c) 2015 Ryan D'souza. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject

@property(strong, nonatomic) NSString *id;
@property(strong, nonatomic) NSString *name;
@property(strong, nonatomic) NSString *profilePicture;

- (instancetype) initWithID:(NSString*)id name:(NSString*)name profilePicture:(NSString*)profilePicture;

@end