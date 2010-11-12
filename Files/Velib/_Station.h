// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Station.h instead.

#import <CoreData/CoreData.h>


@class Section;

















@interface StationID : NSManagedObjectID {}
@end

@interface _Station : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (StationID*)objectID;



@property (nonatomic, retain) NSDate *refresh_date;

//- (BOOL)validateRefresh_date:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *fullAddress;

//- (BOOL)validateFullAddress:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *sort_index;

@property short sort_indexValue;
- (short)sort_indexValue;
- (void)setSort_indexValue:(short)value_;

//- (BOOL)validateSort_index:(id*)value_ error:(NSError**)error_;



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



@property (nonatomic, retain) NSNumber *status_available;

@property short status_availableValue;
- (short)status_availableValue;
- (void)setStatus_availableValue:(short)value_;

//- (BOOL)validateStatus_available:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *address;

//- (BOOL)validateAddress:(id*)value_ error:(NSError**)error_;



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



@property (nonatomic, retain) NSString *name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *lng;

@property double lngValue;
- (double)lngValue;
- (void)setLngValue:(double)value_;

//- (BOOL)validateLng:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *code_postal;

//- (BOOL)validateCode_postal:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *number;

//- (BOOL)validateNumber:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) Section* section;
//- (BOOL)validateSection:(id*)value_ error:(NSError**)error_;




+ (NSArray*)fetchStations:(NSManagedObjectContext*)moc_ ;
+ (NSArray*)fetchStations:(NSManagedObjectContext*)moc_ error:(NSError**)error_;


@end

@interface _Station (CoreDataGeneratedAccessors)

@end

@interface _Station (CoreDataGeneratedPrimitiveAccessors)

- (NSDate*)primitiveRefresh_date;
- (void)setPrimitiveRefresh_date:(NSDate*)value;


- (NSString*)primitiveFullAddress;
- (void)setPrimitiveFullAddress:(NSString*)value;


- (NSNumber*)primitiveSort_index;
- (void)setPrimitiveSort_index:(NSNumber*)value;

- (short)primitiveSort_indexValue;
- (void)setPrimitiveSort_indexValue:(short)value_;


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


- (NSNumber*)primitiveStatus_available;
- (void)setPrimitiveStatus_available:(NSNumber*)value;

- (short)primitiveStatus_availableValue;
- (void)setPrimitiveStatus_availableValue:(short)value_;


- (NSString*)primitiveAddress;
- (void)setPrimitiveAddress:(NSString*)value;


- (NSNumber*)primitiveOpen;
- (void)setPrimitiveOpen:(NSNumber*)value;

- (BOOL)primitiveOpenValue;
- (void)setPrimitiveOpenValue:(BOOL)value_;


- (NSNumber*)primitiveLat;
- (void)setPrimitiveLat:(NSNumber*)value;

- (double)primitiveLatValue;
- (void)setPrimitiveLatValue:(double)value_;


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;


- (NSNumber*)primitiveLng;
- (void)setPrimitiveLng:(NSNumber*)value;

- (double)primitiveLngValue;
- (void)setPrimitiveLngValue:(double)value_;


- (NSString*)primitiveCode_postal;
- (void)setPrimitiveCode_postal:(NSString*)value;


- (NSString*)primitiveNumber;
- (void)setPrimitiveNumber:(NSString*)value;




- (Section*)primitiveSection;
- (void)setPrimitiveSection:(Section*)value;


@end
