//
//  DebugLog.h
//  Bicyclette
//
//  Created by Nicolas on 24/01/13.
//  Copyright (c) 2013 Nicolas Bouilleaud. All rights reserved.
//

#if DEBUG
	#define DebugLog			NSLog
#else
	#define DebugLog(...)
#endif

#define ErrorLog			NSLog
