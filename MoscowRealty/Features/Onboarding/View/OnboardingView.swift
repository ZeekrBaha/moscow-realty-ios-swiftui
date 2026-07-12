import SwiftUI

struct OnboardingView: View {
    var onFinish: () -> Void

    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            illustration: "building.2.fill",
            accentColor: Color(red: 0.35, green: 0.55, blue: 1.0),
            title: "В поисках жилья?",
            subtitle: "Тысячи проверенных объявлений о продаже и аренде квартир в Москве — всё в одном приложении.",
            isLast: false
        ),
        OnboardingPage(
            illustration: "map.fill",
            accentColor: Color(red: 0.2, green: 0.75, blue: 0.55),
            title: "Ищи варианты",
            subtitle: "Фильтруй по цене, метро, районам. Смотри объекты на карте и сравнивай предложения.",
            isLast: false
        ),
        OnboardingPage(
            illustration: "key.fill",
            accentColor: Color(red: 1.0, green: 0.6, blue: 0.2),
            title: "Идеально",
            subtitle: "Твоя сделка защищена. Связывайся с агентами напрямую и находи жильё своей мечты.",
            isLast: true
        )
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $currentPage) {
                ForEach(pages.indices, id: \.self) { index in
                    pageView(pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()

            bottomPanel
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private func pageView(_ page: OnboardingPage) -> some View {
        ZStack(alignment: .bottom) {
            page.accentColor
                .opacity(0.12)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                Image(systemName: page.illustration)
                    .font(.system(size: 120, weight: .thin))
                    .foregroundStyle(page.accentColor)
                    .padding(.bottom, 40)
                Spacer()
                Spacer()
            }
        }
    }

    private var bottomPanel: some View {
        VStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: -4)

                VStack(spacing: 24) {
                    pageIndicator

                    VStack(spacing: 10) {
                        Text(pages[currentPage].title)
                            .font(.title).bold()
                            .multilineTextAlignment(.center)
                        Text(pages[currentPage].subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                    }

                    HStack(spacing: 12) {
                        if !pages[currentPage].isLast {
                            Button("Пропустить") {
                                onFinish()
                            }
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                        }

                        Button(pages[currentPage].isLast ? "Начать" : "Продолжить") {
                            if pages[currentPage].isLast {
                                onFinish()
                            } else {
                                withAnimation { currentPage += 1 }
                            }
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.primary, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(28)
            }
            .frame(height: 280)
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 6) {
            ForEach(pages.indices, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? Color.primary : Color(.tertiaryLabel))
                    .frame(width: index == currentPage ? 20 : 6, height: 6)
                    .animation(.spring(response: 0.3), value: currentPage)
            }
        }
    }
}

private struct OnboardingPage {
    let illustration: String
    let accentColor: Color
    let title: String
    let subtitle: String
    let isLast: Bool
}
