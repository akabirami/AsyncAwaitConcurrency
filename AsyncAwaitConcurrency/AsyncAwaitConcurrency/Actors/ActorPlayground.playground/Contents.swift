actor User {
    var score = 10
    let name = "abi"
    
    nonisolated var fullName: String {
      "My name is \(name)"
    }

    func printScore() {
        print("My score is \(score)")
    }
    
    nonisolated func printName() {
        print("My name is \(name)")
    }

    func copyScore(from other: User) async {
        score = await other.score
    }
    
    // originally it was said not allowed
    func copyScore1(from other: isolated User, andOther: isolated User) async {
        score = other.score + andOther.score
    }
}

Task {
    let actor1 = User()
    let actor2 = User()
    let actor3 = User()
    
    await print(actor1.score)
    await actor1.copyScore(from: actor2)
    print(await actor1.score)
    
    
    print(actor1.name)
    print(actor1.fullName) // This must be marked with await if non isoalted is not used in func
    actor1.printName() // This must be marked with await if non isoalted is not used in func
}

@MainActor class ViewModel {
    func runTest() async {
        print("1")

        await MainActor.run {
            print("2")

            Task { @MainActor in
                print("3")
            }

            print("4")
        }

        print("5")
    }
}

Task {
    let viewModel = await ViewModel()
    await viewModel.runTest()
}

