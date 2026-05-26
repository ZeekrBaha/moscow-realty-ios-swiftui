struct SearchFilter: Equatable {
    var propertyType: PropertyType = .apartment
    var listingType:  ListingType  = .buy
    var rooms:        Set<Int>     = []
    var priceMin:     Int?
    var priceMax:     Int?
    var areaMin:      Double?
    var areaMax:      Double?
    var metro:        String?
    var district:     String?

    var isEmpty: Bool {
        rooms.isEmpty && priceMin == nil && priceMax == nil
        && areaMin == nil && areaMax == nil
        && metro == nil && district == nil
    }
}
