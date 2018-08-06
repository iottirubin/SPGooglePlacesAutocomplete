//
//  SPGooglePlacesAutocompletePlace.m
//  SPGooglePlacesAutocomplete
//
//  Created by Stephen Poletto on 7/17/12.
//  Copyright (c) 2012 Stephen Poletto. All rights reserved.
//

#import "SPGooglePlacesAutocompletePlace.h"
#import "SPGooglePlacesPlaceDetailQuery.h"

@interface SPGooglePlacesAutocompletePlace()
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *placeId;
@property (nonatomic) SPGooglePlacesAutocompletePlaceType type;
@property (nonatomic, strong) NSArray* terms;
@end

@implementation SPGooglePlacesAutocompletePlace



+ (SPGooglePlacesAutocompletePlace *)placeDetailFromDictionary:(NSDictionary *)placeDictionary apiKey:(NSString *)apiKey
{
    SPGooglePlacesAutocompletePlace *place = [[self alloc] init];
    NSMutableString *str = [NSMutableString string];
    
    // Address
    if (placeDictionary[@"formatted_address"]) {
        
        [str appendString:placeDictionary[@"formatted_address"]];
    } else if (placeDictionary[@"address_components"]) {
        
        for (NSDictionary *d in placeDictionary[@"address_components"]) {
            
            NSLog(@"%@", d);
            [str appendString:d[@"short_name"]];
            [str appendString:@", "];
        }
    }
    
    @try {
        // Component Address
        if (placeDictionary[@"address_components"]) {
            
            for (NSDictionary *d in placeDictionary[@"address_components"]) {
                
                NSLog(@"%@", d);
                if (d[@"types"]) {
                    
                    NSArray *type = d[@"types"];
                    
                    for (NSString *t in type) {
                        
                        if ([t isEqualToString:@"street_number"]) { // Número
                            
                            NSString *tmp = [NSString stringWithFormat:@"%@", d[@"long_name"]];
                            
                            if ([[tmp componentsSeparatedByString:@","] count] > 1) {
                                
                                place.streetNumber = [[tmp componentsSeparatedByString:@","] firstObject];
                                
                            } else if ([[tmp componentsSeparatedByString:@"-"] count] > 1) {
                                
                                place.streetNumber = [[tmp componentsSeparatedByString:@"-"] firstObject];
                            } else if ([[tmp componentsSeparatedByString:@" "] count] > 1) {
                                
                                place.streetNumber = [[tmp componentsSeparatedByString:@" "] firstObject];
                            } else {
                                
                                place.streetNumber = d[@"long_name"];
                            }
                            
                            break;
                        }
                        
                        if ([t isEqualToString:@"route"]) { // Rua / Av / Alamameda
                            
                            place.street = d[@"long_name"];
                            break;
                        }
                        
                        if ([t isEqualToString:@"sublocality_level_1"]) { // Bairro
                            
                            place.neighborhood = d[@"long_name"];
                            break;
                        }
                        
                        if ([t isEqualToString:@"administrative_area_level_2"]) {
                            
                            place.city = d[@"long_name"];
                            break;
                        }
                        
                        if ([t isEqualToString:@"administrative_area_level_1"]) {
                            
                            place.provincy = d[@"long_name"];
                            break;
                        }
                        
                        if ([t isEqualToString:@"postal_code"]) {
                            
                            place.postalCode = d[@"long_name"];
                            if (place.postalCode.length <= 5) {
                                place.postalCode = [place.postalCode stringByAppendingString:@"000"];
                            }
                            break;
                        }
                    }
                }
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"%@ : %d", exception, __LINE__);
    } @finally {}
    
    
    // Location
    NSDictionary *loc = placeDictionary[@"geometry"][@"location"];
    place.location = [[CLLocation alloc] initWithLatitude:[loc[@"lat"] doubleValue] longitude:[loc[@"lng"] doubleValue]];
    if (str.length > 0) {
        place.name = str;
    }
    place.placeId = placeDictionary[@"place_id"];
    place.type = SPPlaceTypeFromDictionary(placeDictionary);
    NSMutableArray* terms = [NSMutableArray array];
    for (NSDictionary* term in [placeDictionary objectForKey:@"terms"])
        [terms addObject:term[@"value"]];
    place.terms = terms;
    place.key = apiKey;
    return place;
}

+ (SPGooglePlacesAutocompletePlace *)placeFromDictionary:(NSDictionary *)placeDictionary apiKey:(NSString *)apiKey
{
    SPGooglePlacesAutocompletePlace *place = [[self alloc] init];
    
    if (placeDictionary[@"address_components"]) {
        place = [SPGooglePlacesAutocompletePlace placeDetailFromDictionary:placeDictionary apiKey:apiKey];
        
        return place;
    }
    
    @try {
        // Component Address
        if (placeDictionary[@"address_components"]) {
            
            for (NSDictionary *d in placeDictionary[@"address_components"]) {
                
                NSLog(@"%@", d);
                if (d[@"types"]) {
                    
                    NSArray *type = d[@"types"];
                    
                    for (NSString *t in type) {
                        
                        if ([t isEqualToString:@"street_number"]) { // Número
                            
                            NSString *tmp = [NSString stringWithFormat:@"%@", d[@"long_name"]];
                            
                            if ([[tmp componentsSeparatedByString:@","] count] > 1) {
                                
                                place.streetNumber = [[tmp componentsSeparatedByString:@","] firstObject];
                                
                            } else if ([[tmp componentsSeparatedByString:@"-"] count] > 1) {
                                
                                place.streetNumber = [[tmp componentsSeparatedByString:@"-"] firstObject];
                            } else if ([[tmp componentsSeparatedByString:@" "] count] > 1) {
                                
                                place.streetNumber = [[tmp componentsSeparatedByString:@" "] firstObject];
                            } else {
                                
                                place.streetNumber = d[@"long_name"];
                            }
                            
                            break;
                        }
                        
                        if ([t isEqualToString:@"route"]) { // Rua / Av / Alamameda
                            
                            place.street = d[@"long_name"];
                            break;
                        }
                        
                        if ([t isEqualToString:@"sublocality_level_1"]) { // Bairro
                            
                            place.neighborhood = d[@"long_name"];
                            break;
                        }
                        
                        if ([t isEqualToString:@"administrative_area_level_2"]) {
                            
                            place.city = d[@"long_name"];
                            break;
                        }
                        
                        if ([t isEqualToString:@"administrative_area_level_1"]) {
                            
                            place.provincy = d[@"long_name"];
                            break;
                        }
                        
                        if ([t isEqualToString:@"postal_code"]) {
                            
                            place.postalCode = d[@"long_name"];
                            if (place.postalCode.length <= 5) {
                                place.postalCode = [place.postalCode stringByAppendingString:@"000"];
                            }
                            break;
                        }
                    }
                }
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"%@ : %d", exception, __LINE__);
    } @finally {}
    
    if (placeDictionary[@"description"])
        place.name = placeDictionary[@"description"];
    else
        place.name = placeDictionary[@"vicinity"];
    place.placeId = placeDictionary[@"place_id"];
    place.type = SPPlaceTypeFromDictionary(placeDictionary);
    NSMutableArray* terms = [NSMutableArray array];
    for (NSDictionary* term in [placeDictionary objectForKey:@"terms"])
        [terms addObject:term[@"value"]];
    place.terms = terms;
    place.key = apiKey;
    return place;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Name: %@, Place Id: %@, Type: %@, Location: %@",
            self.name, self.placeId, SPPlaceTypeStringForPlaceType(self.type), _location];
}

- (CLGeocoder *)geocoder {
    if (!geocoder) {
        geocoder = [[CLGeocoder alloc] init];
    }
    return geocoder;
}

- (void)resolveEstablishmentPlaceToPlacemark:(SPGooglePlacesPlacemarkResultBlock)block {
    SPGooglePlacesPlaceDetailQuery *query = [[SPGooglePlacesPlaceDetailQuery alloc] initWithApiKey:self.key];
    query.placeId = self.placeId;
    [query fetchPlaceDetail:^(NSDictionary *placeDictionary, NSError *error) {
        if (error) {
            block(nil, nil, error);
        } else {
            NSString *addressString = placeDictionary[@"formatted_address"];
            [[self geocoder] geocodeAddressString:addressString completionHandler:^(NSArray *placemarks, NSError *error) {
                if (error) {
                    // Sometimes establishment has address, which location cannot be retrieved
                    // ref: https://github.com/chenyuan/SPGooglePlacesAutocomplete/issues/9
                    [self resolveGecodePlaceToPlacemark:block];
                } else {
                    CLPlacemark *placemark = [placemarks onlyObject];
                    block(placemark, self.name, error);
                }
            }];
        }
    }];
}

- (void)resolveGecodePlaceToPlacemark:(SPGooglePlacesPlacemarkResultBlock)block {
    [[self geocoder] geocodeAddressString:self.name completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            block(nil, nil, error);
        } else {
            CLPlacemark *placemark = [placemarks onlyObject];
            block(placemark, self.name, error);
        }
    }];
}

- (void)resolveToPlacemark:(SPGooglePlacesPlacemarkResultBlock)block {
    if (self.type == SPPlaceTypeGeocode) {
        // Geocode places already have their address stored in the 'name' field.
        [self resolveGecodePlaceToPlacemark:block];
    } else {
        [self resolveEstablishmentPlaceToPlacemark:block];
    }
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeObject:_placeId forKey:@"placeId"];
    [encoder encodeInteger:_type forKey:@"type"];
    [encoder encodeInteger:_terms forKey:@"terms"];
    
    [encoder encodeObject:_street forKey:@"street"];
    [encoder encodeObject:_streetNumber forKey:@"streetNumber"];
    [encoder encodeObject:_postalCode forKey:@"postalCode"];
    [encoder encodeObject:_neighborhood forKey:@"neighborhood"];
    [encoder encodeObject:_provincy forKey:@"provincy"];
    [encoder encodeObject:_city forKey:@"city"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    
    if (self = [super init]) {
        @try {
            _name = [decoder decodeObjectForKey:@"name"];
            _placeId = [decoder decodeObjectForKey:@"placeId"];
            _type = [decoder decodeObjectForKey:@"type"];
            _terms = [decoder decodeObjectForKey:@"terms"];
            
            _street = [decoder decodeObjectForKey:@"street"];
            _streetNumber = [decoder decodeObjectForKey:@"streetNumber"];
            _postalCode = [decoder decodeObjectForKey:@"postalCode"];
            _neighborhood = [decoder decodeObjectForKey:@"neighborhood"];
            _provincy = [decoder decodeObjectForKey:@"provincy"];
            _city = [decoder decodeObjectForKey:@"city"];
        }
        @catch (NSException *exception) {
            NSLog(@"%s", __FUNCTION__);
        }
        @finally {
            
        }
    }
    return self;
}

@end
