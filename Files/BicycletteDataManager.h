//
//  BicycletteDataManager.h
//  
//
//  Created by Nicolas Bouilleaud on 15/05/11.
//  Copyright 2011 Visuamobile. All rights reserved.
//

#import "CoreDataManager.h"

#define kVelibStationsListURL		@"http://www.velib.paris.fr/service/carto"

@interface BicycletteDataManager : CoreDataManager
@property (readonly) BOOL downloadingUpdate;

- (void) parseXML:(NSData*)xml;

@end
