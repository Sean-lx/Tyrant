import XCTest
@testable import Tyrant

final class TyrantTests: XCTestCase {
  func testDataReader() throws {
    let countries = DataReader().read("Country_Flags_Icons", type: "json")
    XCTAssertNotNil(countries?.count)
    if let count = countries?.count {
      XCTAssertTrue(count > 0)
    }
  }
  
  func testImageCache() async throws {
    let imageCache = ImageCache()
    guard
      let countries = DataReader().read("Country_Flags_Icons", type: "json")
    else {
      XCTFail("Load countries failed")
      return
    }
    
    let randomCountries = countries.randomChoose(5)
    
    for country in randomCountries {
      let urlString = "https://countryflagsapi.com/png/" + country.alpha3.lowercased()
      let image = try await imageCache.image(urlString, size: CGSizeMake(50, 50))
      XCTAssertNotNil(image)
    }
  }
}
