import SwiftUI
import WeatherAppModel

struct WeatherNavigationView: View {
    static let title = "Weather"

    var body: some View {
        NavigationStack {
            WeatherView()
                .navigationTitle(Self.title)
        }
    }
}

struct WeatherView : View {
    @State var latitude: String = ""
    @State var longitude: String = ""
    @State var error: String = ""
    @State var temperature: Double = Double.nan

    var body: some View {
        VStack {
            HStack {
                Text(LocalizedStringKey("Lat:"), bundle: .module)
                TextField(text: $latitude) {
                    Text(LocalizedStringKey("Latitude"), bundle: .module)
                }
            }
            HStack {
                Text(LocalizedStringKey("Lon:"), bundle: .module)
                TextField(text: $longitude) {
                    Text(LocalizedStringKey("Longitude"), bundle: .module)
                }
            }

            Button {
                Task {
                    await updateWeather()
                }
            } label: {
                Text(LocalizedStringKey("Fetch Weather"), bundle: .module)
            }
            .buttonStyle(.borderedProminent)

            if !error.isEmpty {
                Text("\(error)")
                    .font(.headline)
                    .foregroundStyle(Color.red)
            } else {
                if !temperature.isNaN {
                    Text(LocalizedStringKey("Temperature: \(Int(temperature))°"), bundle: .module)
                        .font(.largeTitle)
                        .foregroundStyle(temperature < 15.0 ? Color.blue : temperature > 30.0 ? Color.red : Color.green)
                }
            }
            Spacer()
        }
        #if !SKIP
        .textFieldStyle(.roundedBorder)
        #endif
        .padding()
        .task {
            // Update immediately if we were constructed with a location
            if !latitude.isEmpty && !longitude.isEmpty {
                await updateWeather()
            }
        }
    }

    func updateWeather() async {
        do {
            self.error = "" // clear the current error
            let condition = try await fetchWeather()
            if let temperature = await condition.temperature {
                self.temperature = temperature
            }
        } catch {
            // set the error message label on failure
            self.error = "\(error)"
        }
    }

    func fetchWeather() async throws -> WeatherCondition {
        guard let lat = Double(self.latitude), let lon = Double(self.longitude) else {
            throw AppError(description: "Unable to parse coordinates")
        }
        logger.log("fetching weather for lat=\(lat) lon=\(lon)…")
        let location = Location(latitude: lat, longitude: lon)
        let condition = await WeatherCondition(location: location)
        let result = try await condition.fetchWeather()
        logger.log("fetched weather: \(result)")
        return condition
    }
}
