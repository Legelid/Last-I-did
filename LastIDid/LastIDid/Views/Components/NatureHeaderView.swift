//
//  NatureHeaderView.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/20/26.
//

import SwiftUI

struct NatureHeaderView: View {
    @AppStorage("userName") private var userName: String = ""
    @AppStorage(AppPreferenceKey.greetingStyle) private var greetingStyleRaw = "timeOfDay"
    @AppStorage(AppPreferenceKey.greetingTextSize) private var greetingTextSizeRaw = "medium"
    @AppStorage(AppPreferenceKey.greetingAlignment) private var greetingAlignmentRaw = "leading"

    // Header style settings
    @AppStorage(AppPreferenceKey.headerStyle) private var headerStyleRaw = "gradient"
    @AppStorage(AppPreferenceKey.gradientStyle) private var gradientStyleRaw = "edgeFade"
    @AppStorage(AppPreferenceKey.customPhotoData) private var customPhotoData: Data?

    // Weather settings
    @AppStorage("showWeather") private var showWeather = true
    @AppStorage("useCelsius") private var useCelsius = false

    // Theme colors
    @Environment(\.backgroundTheme) private var theme
    @Environment(\.customBackgroundHex) private var customHex

    @StateObject private var weatherService = WeatherService.shared

    @State private var showNamePrompt = false
    @State private var tempName = ""

    private var headerStyle: HeaderStyle {
        HeaderStyle.from(headerStyleRaw)
    }

    private var gradientStyle: GradientStyle {
        GradientStyle.from(gradientStyleRaw)
    }

    private var greetingStyle: GreetingStyle {
        GreetingStyle.from(greetingStyleRaw)
    }

    private var greetingTextSize: GreetingTextSize {
        GreetingTextSize.from(greetingTextSizeRaw)
    }

    private var greetingAlignment: GreetingAlignment {
        GreetingAlignment.from(greetingAlignmentRaw)
    }

    private var horizontalAlignment: Alignment {
        switch greetingAlignment {
        case .leading: return .bottomLeading
        case .center: return .bottom
        case .trailing: return .bottomTrailing
        }
    }

    private var textAlignment: HorizontalAlignment {
        switch greetingAlignment {
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        }
    }

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: Date())
    }

    private var imageURL: URL {
        // Using date as seed ensures same photo all day
        URL(string: "https://picsum.photos/seed/\(dateString)/800/400")!
    }

    private var greeting: String? {
        greetingStyle.greeting(for: userName)
    }

    private var themeColors: ThemeColors {
        ThemeColors(theme: theme, customHex: customHex)
    }

    private var accentColor: Color {
        themeColors.secondaryColor
    }

    var body: some View {
        GeometryReader { geometry in
            let totalHeight: CGFloat = 200 + geometry.safeAreaInsets.top

            ZStack(alignment: horizontalAlignment) {
                // Background based on header style
                headerBackground(geometry: geometry, totalHeight: totalHeight)

                // Gradient overlay for text readability (for photo-based headers)
                if headerStyle != .gradient {
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(width: geometry.size.width, height: totalHeight)
                }

                // Greeting text with weather
                VStack(alignment: textAlignment, spacing: 4) {
                    // Greeting line with weather
                    if let greeting = greeting {
                        HStack(spacing: 8) {
                            Text(greeting)
                                .font(greetingTextSize.greetingFont)
                                .foregroundStyle(.white.opacity(0.8))

                            // Weather display
                            if showWeather, let weather = weatherService.currentWeather {
                                Text(weather.emoji)
                                    .font(greetingTextSize.greetingFont)

                                Text(weather.temperatureString(useCelsius: useCelsius))
                                    .font(greetingTextSize.greetingFont)
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                        }
                    } else if showWeather, let weather = weatherService.currentWeather {
                        // Show weather even if greeting is off
                        HStack(spacing: 6) {
                            Text(weather.emoji)
                                .font(greetingTextSize.greetingFont)
                            Text(weather.temperatureString(useCelsius: useCelsius))
                                .font(greetingTextSize.greetingFont)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }

                    if userName.isEmpty {
                        Button {
                            showNamePrompt = true
                        } label: {
                            Text("Tap to set your name")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    } else {
                        Text(userName)
                            .font(greetingTextSize.nameFont)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    }
                }
                .frame(maxWidth: .infinity, alignment: Alignment(horizontal: textAlignment, vertical: .center))
                .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
        .frame(height: 200)
        .ignoresSafeArea(edges: .top)
        .onAppear {
            if userName.isEmpty {
                // Delay the prompt slightly for better UX
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showNamePrompt = true
                }
            }

            // Fetch weather
            if showWeather {
                Task {
                    await weatherService.fetchWeather()
                }
            }
        }
        .alert("What should we call you?", isPresented: $showNamePrompt) {
            TextField("Your name", text: $tempName)
                .autocorrectionDisabled()
            Button("Save") {
                if !tempName.trimmingCharacters(in: .whitespaces).isEmpty {
                    userName = tempName.trimmingCharacters(in: .whitespaces)
                }
                tempName = ""
            }
            Button("Skip", role: .cancel) {
                tempName = ""
            }
        } message: {
            Text("We'll use this to personalize your experience.")
        }
        .onTapGesture {
            showNamePrompt = true
            tempName = userName
        }
    }

    // MARK: - Header Background View Builder

    @ViewBuilder
    private func headerBackground(geometry: GeometryProxy, totalHeight: CGFloat) -> some View {
        switch headerStyle {
        case .remotePhoto:
            remotePhotoBackground(geometry: geometry, totalHeight: totalHeight)

        case .gradient:
            gradientBackground(totalHeight: totalHeight)
                .frame(width: geometry.size.width, height: totalHeight)

        case .customPhotoSingle:
            customPhotoBackground(geometry: geometry, totalHeight: totalHeight)

        case .customPhotoCollection:
            // For now, fall back to gradient if no collection is set up
            gradientBackground(totalHeight: totalHeight)
                .frame(width: geometry.size.width, height: totalHeight)
        }
    }

    // MARK: - Remote Photo Background

    @ViewBuilder
    private func remotePhotoBackground(geometry: GeometryProxy, totalHeight: CGFloat) -> some View {
        AsyncImage(url: imageURL) { phase in
            switch phase {
            case .empty:
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay {
                        ProgressView()
                            .tint(.white)
                    }
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: totalHeight)
                    .clipped()
            case .failure:
                gradientBackground(totalHeight: totalHeight)
            @unknown default:
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
            }
        }
        .frame(width: geometry.size.width, height: totalHeight)
    }

    // MARK: - Custom Photo Background

    @ViewBuilder
    private func customPhotoBackground(geometry: GeometryProxy, totalHeight: CGFloat) -> some View {
        if let photoData = customPhotoData,
           let uiImage = UIImage(data: photoData) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geometry.size.width, height: totalHeight)
                .clipped()
        } else {
            // Fallback to gradient if no custom photo
            gradientBackground(totalHeight: totalHeight)
                .frame(width: geometry.size.width, height: totalHeight)
        }
    }

    // MARK: - Gradient Background

    @ViewBuilder
    private func gradientBackground(totalHeight: CGFloat) -> some View {
        let primaryColor = themeColors.primaryColor
        let secondaryColor = themeColors.secondaryColor
        let accentColor = Color.accentColor

        switch gradientStyle {
        case .edgeFade:
            // Edges darker, center lighter
            ZStack {
                Rectangle()
                    .fill(primaryColor)

                RadialGradient(
                    colors: [secondaryColor.opacity(0.8), primaryColor],
                    center: .center,
                    startRadius: 0,
                    endRadius: totalHeight
                )

                // Bottom darkening for text readability
                LinearGradient(
                    colors: [.clear, .black.opacity(0.5)],
                    startPoint: .center,
                    endPoint: .bottom
                )
            }

        case .linearVertical:
            LinearGradient(
                colors: [accentColor.opacity(0.6), primaryColor, primaryColor],
                startPoint: .top,
                endPoint: .bottom
            )

        case .linearDiagonal:
            LinearGradient(
                colors: [accentColor.opacity(0.5), secondaryColor, primaryColor],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        case .radialCenter:
            ZStack {
                Rectangle()
                    .fill(primaryColor)

                RadialGradient(
                    colors: [accentColor.opacity(0.6), secondaryColor, primaryColor],
                    center: .center,
                    startRadius: 0,
                    endRadius: totalHeight * 1.2
                )

                // Bottom darkening for text
                LinearGradient(
                    colors: [.clear, .black.opacity(0.4)],
                    startPoint: .center,
                    endPoint: .bottom
                )
            }

        case .angular:
            ZStack {
                Rectangle()
                    .fill(primaryColor)

                AngularGradient(
                    colors: [
                        accentColor.opacity(0.4),
                        secondaryColor.opacity(0.6),
                        primaryColor,
                        secondaryColor.opacity(0.6),
                        accentColor.opacity(0.4)
                    ],
                    center: .center,
                    startAngle: .degrees(0),
                    endAngle: .degrees(360)
                )
                .opacity(0.7)

                // Bottom darkening for text
                LinearGradient(
                    colors: [.clear, .black.opacity(0.5)],
                    startPoint: .center,
                    endPoint: .bottom
                )
            }
        }
    }
}

#Preview {
    VStack {
        NatureHeaderView()
        Spacer()
    }
    .preferredColorScheme(.dark)
}
