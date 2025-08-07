//import Foundation
//
struct PlantDetail: Identifiable, Codable {
    var id: String { pid }
    let pid: String
    let display_pid: String
    let alias: String
    let max_light_lux: Double?
    let min_light_lux: Double?
    let max_temp: Double?
    let min_temp: Double?
    let max_env_humid: Double?
    let min_env_humid: Double?
    let max_soil_moist: Double?
    let min_soil_moist: Double?
    let max_soil_ec: Double?
    let min_soil_ec: Double?
    let image_url: String?
}    /////////////////////////////////////////////////////                                                                                           

//
//struct PlantDetail: Identifiable, Codable {
//    var id: String { pid }
//    let pid: String
//    let display_pid: String
//    let alias: String
//    let max_light_lux: Double?
//    let min_light_lux: Double?
//    let max_temp: Double?
//    let min_temp: Double?
//    let max_env_humid: Double?
//    let min_env_humid: Double?
//    let max_soil_moist: Double?
//    let min_soil_moist: Double?
//    let max_soil_ec: Double?
//    let min_soil_ec: Double?
//    let image_url: String?
//}
