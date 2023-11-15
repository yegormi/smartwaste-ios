import SwiftUI


// MARK: - BODY

struct TabScreen: View {
    @State private var willShowHeader: Bool = false

    var body: some View {
        VStack {
            if willShowHeader {
                HeaderView()
            }
            TabView() {
                ProfileView()
                    .tabItem { Label("Profile", systemImage: "person.fill") }
                MapView()
                    .tabItem { Label("Map", systemImage: "map.fill") }
            }
            .onAppear {
                withAnimation(.interactiveSpring) {
                    willShowHeader = true
                }
            }
        }
    }
}


// MARK: - PREVIEWS

struct TabScreen_Previews: PreviewProvider {
    static var previews: some View {
        TabScreen()
            .environmentObject(AuthViewModel())
    }
}
