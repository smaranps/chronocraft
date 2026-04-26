import SwiftUI
import Foundation
let techQuestions: [Question] = [
    Question(
        text: "What kind of world is this??",
        answers: [
            Answer(text: "Earth Like" ,scoreValue: 10),
            Answer(text: "Ocean Civilization",scoreValue: 5),
            Answer(text: "Era of Advancement",scoreValue: 15),
            Answer(text: "The Dustbound World",scoreValue: 0),
            
        ]
    ),
    
    Question(
        text: "How large is the world?",
        answers: [
            Answer(text: "Size of Earth",scoreValue: 5),
            Answer(text: "Large",scoreValue: 10),
            Answer(text: "Medium Size",scoreValue: 15),
            Answer(text: "Dwarf Planet",scoreValue: 0)
        ]
    ),
    
    Question(
        text: "What is the gravity like?",
        answers: [
            Answer(text: "Low",scoreValue: 5),
            Answer(text: "Medium",scoreValue: 10),
            Answer(text: "Same as Earth",scoreValue: 15),
            Answer(text: "High",scoreValue: 0)
        ]
    ),
    
    Question(
        text: "How many moons are found?",
        answers: [
            Answer(text: "1 (Default like Earth)",scoreValue: 10),
            Answer(text: "2, (Advanced Tides)",scoreValue: 15),
            Answer(text: "0",scoreValue: 0),
            Answer(text: "3 (Constant moon sightings)",scoreValue: 5)
            
        ]
    ),
    
    Question(
        text: "What dominates the surface?",
        answers: [
            Answer(text: "Cities (urban and technological)",scoreValue: 15),
            Answer(text: "Nature (wild and untamed)",scoreValue: 0),
            Answer(text: "Ruins (ancient history, decay)",scoreValue: 5),
            Answer(text: "Mixed (balanced ecology/civilization)",scoreValue: 10)
        ]
    )
]

struct BaseCategoryView: View {
    @ObservedObject var worldManager: WorldManager
     @Environment(\.dismiss) var dismiss
    let category: CategoryCard
    var onFinish: () -> Void
    let questions: [Question] = techQuestions
    @Environment(\.horizontalSizeClass) var sizeClass
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
            worldManager.baseScore = 0
        }
    }
    
    func goToNextStep() {
        if let selectedAnswer = worldChoices[currentQuestion.id] {
            if currentQuestionIndex == 0 {
                worldManager.baseType = selectedAnswer.text
            }
            if currentQuestionIndex == 3{
                if let firstChar = selectedAnswer.text.first, let count = Int(String(firstChar)) {
                    worldManager.moonCount = count
                }
            }
            worldManager.baseScore += selectedAnswer.scoreValue 
            if currentQuestionIndex < questions.count - 1 {
                withAnimation {
                    currentQuestionIndex += 1
                }
            } else {
                onFinish() 
               worldManager.completedCategories.append("1")
                dismiss() 
            }
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
