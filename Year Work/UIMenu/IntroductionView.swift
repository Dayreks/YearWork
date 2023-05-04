import SwiftUI

struct IntroductionView: View {
    @Binding var model: TestingModel
    @State private var showStartView = false
    @State var isButtonShown: Bool

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    model.theme.accentColor.ignoresSafeArea()
                    VStack(alignment: .center) {
                        Text("Інструкція")
                            .font(.system(size: 34))
                            .foregroundColor(model.theme.reverseAccentColor)
                            .padding([.top], 16)
                        
                        Text("Даний додаток складається з 5 частин, після проходження яких ти зможеш дізнатись чи є в тебе схильність до дислексії")
                            .font(.system(size: 18))
                            .foregroundColor(model.theme.reverseAccentColor)
                            .padding([.top, .leading, .trailing], 8)

                        VStack(alignment: .leading) {
                            Spacer()
                            ForEach(TestTask.allCases, id: \.self) { task in
                                HStack {
                                    ZStack {
                                        Rectangle()
                                            .foregroundColor(model.theme.mainColor)
                                            .frame(width: 60, height: 60)
                                            .cornerRadius(16)
                                        Image(task.rawValue)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 50)
                                    }
                                    Text(task.description) // Replace with your actual feature descriptions
                                        .font(.system(size: 18))
                                        .foregroundColor(model.theme.reverseAccentColor)
                                }
                                Spacer()
                            }
                            HStack {
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(.red)
                                        .frame(width: 60, height: 60)
                                        .cornerRadius(16)
                                    Image("reset")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 50)
                                }
                                Text("Скинути результати всіх частин") // Replace with your actual feature descriptions
                                    .font(.system(size: 18))
                                    .foregroundColor(model.theme.reverseAccentColor)
                            }
                        }
                        .frame(height: geometry.size.height * 0.6)
                        .padding([.leading, .trailing], 10)

                        Spacer()

                        NavigationLink(destination: StartView(model: $model), isActive: $showStartView) {
                            Text("Продовжити")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                                .frame(minWidth: 100, maxWidth: 200, minHeight: 25, maxHeight: 60)
                                .background(model.theme.mainColor)
                                .clipShape(Capsule())
                        }
                        .padding([.trailing, .leading], 16)
                        .opacity(isButtonShown ? 1 : 0)
                    }
                }
                .navigationBarTitle("")
            }
        }
    }
}

struct IntroductionView_Previews: PreviewProvider {
    static var previews: some View {
        IntroductionView(model: .constant(TestingModel.sampleData[0]), isButtonShown: true)
    }
}
