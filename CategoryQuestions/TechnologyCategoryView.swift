import SwiftUI
import Foundation
struct Answer: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let scoreValue: Int
}
struct Question: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let answers: [Answer]
}
let baseQuestions: [Question] = [
    Question(
        text: "What is the main power source of your world?",
        answers: [
            Answer(text: "Steam",scoreValue: 0),
            Answer(text: "Electricity",scoreValue: 5),
            Answer(text: "Renewable Energy",scoreValue: 10),
            Answer(text: "Advanced or Unknown Energy",scoreValue: 15)
        ]
    ),
    Question(
        text: "How advanced is the overall technology?",
        answers: [
            Answer(text: "Digital" ,scoreValue: 10),
            Answer(text: "Industrial",scoreValue: 5),
            Answer(text: "Futuristic",scoreValue: 15),
            Answer(text: "Primitive (Early Development)",scoreValue: 0)
        ]
    ),
    Question(
        text: "What invention changed society the most in your planet?",
        answers: [
            Answer(text: "Printing" ,scoreValue: 0),
            Answer(text: "Flight" ,scoreValue: 5),
            Answer(text: "AI (Artificial Intelligence)" ,scoreValue: 10),
            Answer(text: "Time Travel" ,scoreValue: 15)
        ]
    ),
    Question(
        text: "In your planet, is technology accessible for everyone?",
        answers: [
            Answer(text: "Yes, Everyone has it" ,scoreValue: 10),
            Answer(text: "No, but only major cities or people of high authority have it",scoreValue: 5),
            Answer(text: "Can only be accessed by a few people",scoreValue: 0),
            
        ]
    ),
    Question(
        text: "When were Phones invented in your world?",
        answers: [
            Answer(text: "200 years earlier" ,scoreValue: 15),
            Answer(text: "Same as Earth" ,scoreValue: 5),
            Answer(text: "3 years earlier" ,scoreValue: 10),
            Answer(text: "20 years later",scoreValue: 0)
        ]
    )
]

struct TechnologyCategoryView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @ObservedObject var worldManager: WorldManager
    @Environment(\.dismiss) var dismiss
    let category: CategoryCard
    var onFinish: () -> Void
    let questions: [Question] = baseQuestions
    @State private var currentQuestionIndex = 0
    @State private var worldChoices: [UUID: Answer] = [:]
    @State private var showingResetAlert = false
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
            worldManager.techScore = 0
        }
    }
    func goToNextStep() {
        if let selectedAnswer = worldChoices[currentQuestion.id] {
            worldManager.techScore += selectedAnswer.scoreValue 
        }
        if currentQuestionIndex < questions.count - 1 {
            withAnimation {
                currentQuestionIndex += 1
            }
        } else {
            onFinish() 
            dismiss() 
             worldManager.completedCategories.append("2")
            print(worldManager.techScore)
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
                    .frame(maxWidth: sizeClass == .compact ? 350 :.infinity)
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
                
                LazyVGrid(columns: columns, spacing: 20) {
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
struct ChoiceButton: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    let answer: Answer
    let color: Color
    let isSelected: Bool
    let action: (Answer) -> Void
    
    var body: some View {
        Button(action: { action(answer) }) {
            Text(answer.text)
                .font(.title3.weight(.semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
                .frame(
                    maxWidth: sizeClass == .compact ? 350 : .infinity, 
                    minHeight: sizeClass == .compact ? 60 : 80, 
                    alignment: .center
                )
                .background(isSelected ? color.opacity(0.8) : color) 
                .cornerRadius(10)
                
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? .white : .clear, lineWidth: 5)
                )
        }
    }
}
