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
                MapView()
                    .tabItem { Label("Map", systemImage: "map.fill") }
                PhotoSenderView()
                    .tabItem { Label("Camera", systemImage: "camera.fill") }
                ProfileView()
                    .tabItem { Label("Profile", systemImage: "person.fill") }
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
