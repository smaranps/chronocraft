import SwiftUI
import Foundation


let HistoryQuestions: [Question] = [
    Question(
        text: "When was electricity discovered in your world?",
        answers: [
            Answer(text: "Never" ,scoreValue: 0),
            Answer(text: "Far in the Future" ,scoreValue: 5),
            Answer(text: "1900s",scoreValue: 10),
            Answer(text: "Ancient Times",scoreValue: 15)
        ]
    ),
    
    Question(
        text: "In your world, when did humans achieve flight?",
        answers: [
            Answer(text: "Never",scoreValue: 0),
            Answer(text: "Digital Era",scoreValue: 5),
            Answer(text: "Ancient Rome Era" ,scoreValue: 15),
            Answer(text: "Modern Era",scoreValue: 10)
        ]
    ),
    
    Question(
        text: "When did instant communication start growing in your world?",
        answers: [
            Answer(text: "Does not exist" ,scoreValue: 0),
            Answer(text: "Digital Era" ,scoreValue: 5),
            Answer(text: "Industrial Era",scoreValue: 10),
            Answer(text: "Dinosaur Era",scoreValue: 15)
        ]
    ),
    
    Question(
        text: "Did a major disaster change history in your world?",
        answers: [
            Answer(text: "No" ,scoreValue: 0),
            Answer(text: "Wars" ,scoreValue: 10),
            Answer(text: "Colliding with another planet",scoreValue: 15),
            Answer(text:"Harmful Disease",scoreValue: 5),
            
        ]
    ),
    
    Question(
        text: "What was a gamechanging moment in your world?",
        answers: [
            Answer(text: "Collapse of an empire",scoreValue: 5),
            Answer(text: "Discovering Time Travel",scoreValue: 15),
            Answer(text: "The rise of AI and technology",scoreValue: 10),
            Answer(text: "Discovery of the Alphabet",scoreValue: 0)
        ]
    )
]





struct HistoryCategoryView: View {
    @ObservedObject var worldManager: WorldManager
     @Environment(\.dismiss) var dismiss
    @Environment(\.horizontalSizeClass) var sizeClass
    let category: CategoryCard
     var onFinish: () -> Void
    let questions: [Question] = HistoryQuestions
    @State private var showingResetAlert = false
    @State private var currentQuestionIndex = 0
    @State private var worldChoices: [UUID: Answer] = [:]
    
    let buttonColors: [Color] = [.indigo, .blue, .teal, .mint]
    
    var currentQuestion: Question {
        questions[currentQuestionIndex]
    }
    
    var isAnswerSelected: Bool {
        worldChoices.keys.contains(currentQuestion.id)
    }
    func resetCategory() {
        withAnimation {
            currentQuestionIndex -= 1
            worldManager.historyScore = 0 
        }
    }
    func goToNextStep() {
        if let selectedAnswer = worldChoices[currentQuestion.id] {
            worldManager.historyScore += selectedAnswer.scoreValue
        }
        if currentQuestionIndex < questions.count - 1 {
            withAnimation {
                currentQuestionIndex += 1
            }
        } else {
            onFinish()
            dismiss() 
             worldManager.completedCategories.append("3")
            print(worldManager.historyScore)
        }
    }        
    
    var body: some View {
        ZStack{
            Image("Swift challenge artwork")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack{
                Spacer()
                VStack(spacing: 8) {
                    VStack(spacing: 8) {
                        Text(category.title.uppercased())
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.top,100)    
                    }
                    .padding(.bottom, sizeClass == .compact ? -30 : 0 )
                    .padding(.top, sizeClass == .compact ? 0 : 30 )
                    HStack {
                        Spacer() 
                        Button(action: {
                            showingResetAlert = true
                        }) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(currentQuestionIndex == 0 ? .secondary : .primary) 
                                .padding(12)
                                .background(Circle().fill(.ultraThinMaterial))
                                .overlay(Circle().stroke(.white.opacity(0.3), lineWidth: 1))
                                .opacity(currentQuestionIndex == 0 ? 0.5 : 1.0)
                        }
                        .padding(.top, 60) 
                        .padding(.trailing, 25)
                        .disabled(currentQuestionIndex == 0)
                    }
                    HStack {
                        Text("Progress")
                            .font(.system(size:15,weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                        Text("\(currentQuestionIndex + 1) of \(questions.count)")
                            .font(.system(size:15,weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.horizontal, 5)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.3))
                                .frame(height: 10)
                            
                            Capsule()
                                .fill(Color.orange) 
                                .frame(width: geometry.size.width * CGFloat(Double(currentQuestionIndex + 1) / Double(questions.count)) , height: 10)
                                .animation(.spring(), value: currentQuestionIndex)
                        }
                    }
                    .frame(height: 10 )
                    .frame(maxWidth: sizeClass == .compact ? 350 : .infinity)
                }
                .frame(maxWidth: sizeClass == .compact ? 350 : .infinity)
                .padding(.horizontal, 30)
                .padding(.top, 10)        
                
                Text(currentQuestion.text).padding(25)
                    .frame(maxWidth: sizeClass == .compact ? 350 : .infinity)
                    .padding(3)
                    .lineLimit(nil)    
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 2)
                    .minimumScaleFactor(0.5)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .background(.black.opacity(0.2))
                    .cornerRadius(20)
                    .padding(.horizontal, 20)
                 .padding(.bottom,sizeClass == .compact ? 30 : 0)
                    .minimumScaleFactor(0.8)
                Spacer()
                let columns = sizeClass == .compact 
                ? [GridItem(.flexible())] 
                : [GridItem(.flexible()), GridItem(.flexible())] 
                
                LazyVGrid(columns: columns, spacing: 15) {
                    ForEach(currentQuestion.answers.indices, id: \.self) { index in
                        ChoiceButton(
                            answer: currentQuestion.answers[index],
                            color: buttonColors[index % buttonColors.count],
                            isSelected: worldChoices[currentQuestion.id] == currentQuestion.answers[index]
                        ) { answer in
                            worldChoices[currentQuestion.id] = answer
                        }
                    }
                }
                .padding(.horizontal, 25)
             .padding(.bottom,20)
                
                VStack{
                    
                    Button(action: goToNextStep) {
                        Text(currentQuestionIndex < questions.count - 1 ? "NEXT STEP" : "FINISH!")
                            .font(.title3.weight(.bold))
                            .frame(maxWidth: sizeClass == .compact ? 350 : .infinity)
                            .padding()
                            .background(isAnswerSelected ? Color.orange : Color.gray .opacity(0.6)) 
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        
                    }
                    
                    .disabled(!isAnswerSelected) 
                    .padding(.horizontal)
                    .padding(.bottom, 170)
                    
                    
                }
                Spacer()
            }
            .alert("Reset Question?", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetCategory()
                }
            } message: {
                Text("This takes you back to the previous question. Are you Sure?")
            }
        }
        .navigationBarBackButtonHidden(true)
        
        
    }
    
}

