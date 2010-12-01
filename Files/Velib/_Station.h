// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Station.h instead.

#import <CoreData/CoreData.h>


@class Region;

















@interface StationID : NSManagedObjectID {}
@end

@interface _Station : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (StationID*)objectID;



@property (nonatomic, retain) NSNumber *status_ticket;

@property BOOL status_ticketValue;
- (BOOL)status_ticketValue;
- (void)setStatus_ticketValue:(BOOL)value_;

//- (BOOL)validateStatus_ticket:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *status_free;

@property short status_freeValue;
- (short)status_freeValue;
- (void)setStatus_freeValue:(short)value_;

//- (BOOL)validateStatus_free:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *status_total;

@property short status_totalValue;
- (short)status_totalValue;
- (void)setStatus_totalValue:(short)value_;

//- (BOOL)validateStatus_total:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *bonus;

@property BOOL bonusValue;
- (BOOL)bonusValue;
- (void)setBonusValue:(BOOL)value_;

//- (BOOL)validateBonus:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *status_date;

//- (BOOL)validateStatus_date:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *address;

//- (BOOL)validateAddress:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *status_available;

@property short status_availableValue;
- (short)status_availableValue;
- (void)setStatus_availableValue:(short)value_;

//- (BOOL)validateStatus_available:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *open;

@property BOOL openValue;
- (BOOL)openValue;
- (void)setOpenValue:(BOOL)value_;

//- (BOOL)validateOpen:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *lat;

@property double latValue;
- (double)latValue;
- (void)setLatValue:(double)value_;

//- (BOOL)validateLat:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *create_date;

//- (BOOL)validateCreate_date:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *favorite_index;

@property int favorite_indexValue;
- (int)favorite_indexValue;
- (void)setFavorite_indexValue:(int)value_;

//- (BOOL)validateFavorite_index:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *lng;

@property double lngValue;
- (double)lngValue;
- (void)setLngValue:(double)value_;

//- (BOOL)validateLng:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *fullAddress;

//- (BOOL)validateFullAddress:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *number;

//- (BOOL)validateNumber:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) Region* region;
//- (BOOL)validateRegion:(id*)value_ error:(NSError**)error_;




+ (NSArray*)fetchStationWithNumber:(NSManagedObjectContext*)moc_ number:(NSString*)number_ ;
+ (NSArray*)fetchStationWithNumber:(NSManagedObjectContext*)moc_ number:(NSString*)number_ error:(NSError**)error_;



@end

@interface _Station (CoreDataGeneratedAccessors)

@end

@interface _Station (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveStatus_ticket;
- (void)setPrimitiveStatus_ticket:(NSNumber*)value;

- (BOOL)primitiveStatus_ticketValue;
- (void)setPrimitiveStatus_ticketValue:(BOOL)value_;


- (NSNumber*)primitiveStatus_free;
- (void)setPrimitiveStatus_free:(NSNumber*)value;

- (short)primitiveStatus_freeValue;
- (void)setPrimitiveStatus_freeValue:(short)value_;


- (NSNumber*)primitiveStatus_total;
- (void)setPrimitiveStatus_total:(NSNumber*)value;

- (short)primitiveStatus_totalValue;
- (void)setPrimitiveStatus_totalValue:(short)value_;


- (NSNumber*)primitiveBonus;
- (void)setPrimitiveBonus:(NSNumber*)value;

- (BOOL)primitiveBonusValue;
- (void)setPrimitiveBonusValue:(BOOL)value_;


- (NSDate*)primitiveStatus_date;
- (void)setPrimitiveStatus_date:(NSDate*)value;


- (NSString*)primitiveAddress;
- (void)setPrimitiveAddress:(NSString*)value;


- (NSNumber*)primitiveStatus_available;
- (void)setPrimitiveStatus_available:(NSNumber*)value;

- (short)primitiveStatus_availableValue;
- (void)setPrimitiveStatus_availableValue:(short)value_;


- (NSNumber*)primitiveOpen;
- (void)setPrimitiveOpen:(NSNumber*)value;

- (BOOL)primitiveOpenValue;
- (void)setPrimitiveOpenValue:(BOOL)value_;


- (NSNumber*)primitiveLat;
- (void)setPrimitiveLat:(NSNumber*)value;

- (double)primitiveLatValue;
- (void)setPrimitiveLatValue:(double)value_;


- (NSDate*)primitiveCreate_date;
- (void)setPrimitiveCreate_date:(NSDate*)value;


- (NSNumber*)primitiveFavorite_index;
- (void)setPrimitiveFavorite_index:(NSNumber*)value;

- (int)primitiveFavorite_indexValue;
- (void)setPrimitiveFavorite_indexValue:(int)value_;


- (NSNumber*)primitiveLng;
- (void)setPrimitiveLng:(NSNumber*)value;

- (double)primitiveLngValue;
- (void)setPrimitiveLngValue:(double)value_;


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;


- (NSString*)primitiveFullAddress;
- (void)setPrimitiveFullAddress:(NSString*)value;


- (NSString*)primitiveNumber;
- (void)setPrimitiveNumber:(NSString*)value;




- (Region*)primitiveRegion;
- (void)setPrimitiveRegion:(Region*)value;


@end
