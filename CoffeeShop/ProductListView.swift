import SwiftUI

struct Product: Identifiable {
    let name: String
    let img: Image
    let description: String
    let id = UUID()
}


class ProductListViewModlel: ObservableObject {
    @Published var productsList = [
        Product(name: "Espresso", img: Image("coffee"),
               description: "Espresso is a full-flavored, concentrated form of coffee that is served in “shots.” It is made by forcing pressurized hot water through very finely ground coffee beans using an espresso machine."),
        
        Product(name: "Latte", img: Image("latte"),
               description: "A latte or caffè latte is a milk coffee that boasts a silky layer of foam as a real highlight to the drink. A true latte will be made up of one or two shots of espresso, lots of steamed milk and a final, thin layer of frothed milk on top."),
        
        Product(name: "Frappuccino", img: Image("frappuccino"),
               description: "Frappuccino is a trademarked brand of the Starbucks Corporation for a line of highly-sweetened iced, blended coffee drinks. It consists of coffee or crème base, blended with ice and other various ingredients like flavored syrups, usually topped with whipped cream and or spices."),
        
        Product(name: "Watermelon Splash", img: Image("watermelon"),
               description: "Indulge in the refreshing flavors of watermelon and lemon with this delicious cocktail. The perfect drink to cool you down on a hot summer’s night.")
    ]
}

struct ContentView: View {
    @ObservedObject var viewModel = ProductListViewModlel()
    @Namespace private var animation
    
    @State var showDetailView = false
    @State var currentProduct = Product(name: "", img: Image(""), description: "")
    
    var body: some View {
        ZStack {
            if showDetailView {
                DetailView(showDetailView: $showDetailView, animation: animation, product: currentProduct)
            }
            
            // When I used 'else' in here, its position got reset
            VStack(alignment: .leading) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150)
                    .padding()
                
                
                VStack(alignment: .leading) {
                    Text("Featured")
                        .font(.title)
                        .bold()
                    Text("Totally unrelated picture from usplash")
                        .font(.caption)
                }
                .padding(.horizontal)

                
                Image("bevs")
                    .resizable()
                    .clipped()
                    .frame(height: 300)
                    .padding(.bottom)
                
                // Title texts
                VStack(alignment: .leading) {
                    Text("Recommended")
                        .font(.title)
                        .bold()
                    Text("descriptions")
                        .font(.caption)
                }
                .padding()
                // Actual menus
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(viewModel.productsList, id: \.id) { product in
                            ZStack {
                                Circle()
                                    .stroke(.black, lineWidth: 1.5)
                                    .frame(width: 150, height: 150)
                                    .padding(5)
                                VStack {
                                    product.img
                                        .resizable()
                                        .matchedGeometryEffect(id: product.id, in: animation, anchor: .center)
                                        .scaledToFit()
                                        .frame(width: 75, height: 75, alignment: .center)
                                    Text(product.name)
                                        .font(.system(size: product.name.count > 12 ? 12 : 15))
                                }
                                .onTapGesture {
                                    withAnimation(.easeInOut) {
                                        showDetailView = true
                                        currentProduct = product
                                    }
                                }
                            }
                        }
                    }
                    .contentShape(Rectangle())
                }
                
                Spacer()
            }
            .opacity(showDetailView ? 0 : 1)
        }
    }
    
    struct DetailView: View {
        @State var isShow1 = false
        @State var isShow2 = false
        @State var isMagnified = false
        
        @Binding var showDetailView: Bool

        var animation: Namespace.ID
        let product: Product
        
        var body: some View {
            VStack {
                // Full screen
                if isMagnified {
                    Magnify(product.img)
                        .padding()
                        .matchedGeometryEffect(id: product.id, in: animation, anchor: .center)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                isMagnified = false
                            }
                        }
                } else {
                    // Previous button
                    HStack {
                        Button(action: { withAnimation(.spring()) {
                            showDetailView = false
                        }}) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.black)
                                .font(.system(size: 20))
                                .padding()
                        }
                        Spacer()
                    }
                    
                    // Image contents
                    ZStack {
                        product.img
                            .resizable()
                            .matchedGeometryEffect(id: product.id, in: animation, anchor: .center)
                            .scaledToFit()
                            .frame(width: 250, height: 250)
                            .zIndex(1)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    isMagnified = true
                                }
                            }
                                            
                        if isShow1 {
                            Circle()
                                .stroke(.pink)
                                .frame(width: 200, height: 200)
                                .offset(x: 100 , y: 50)
                                .transition(.move(edge: .leading))
                                .zIndex(0.9)
                            
                            Circle()
                                .stroke(.purple)
                                .frame(width: 350, height: 350)
                                .offset(x: -100 , y: -100)
                                .transition(.move(edge: .trailing))
                        }
                    }
                    .frame(height: 250)
                    
                    // Description: Name
                    VStack {
                        if isShow2 {
                            Text(product.name)
                                .font(.title)
                                .bold()
                                .transition(.move(edge: .bottom))
                            
                            Text(product.description)
                                .font(.subheadline)
                                .transition(.move(edge: .bottom))
                                .padding(25)
                        }
                    }
                    Spacer()
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    withAnimation(.spring()) {
                        self.isShow1 = true
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.spring()) {
                        self.isShow2 = true
                    }
                }
            }
        }
        
        @ViewBuilder
        func Magnify(_ image: Image) -> some View {
            ZStack {
                image
                    .resizable()
                    .scaledToFit()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
