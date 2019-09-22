//
//  References.swift
//  Memory Management
//
//  Created by Kishor Pahalwani on 18/09/19.
//  Copyright © 2019 Kishor Pahalwani. All rights reserved.
//

import Foundation

//UnOwned
class CarrierSubscription {
    let name: String
    let countryCode: String
    let number: String
    
    unowned let user: User
    
    lazy var completePhoneNumber: () -> String = { [unowned self] in
        return self.countryCode + " " + self.number
    }
    
    init(name: String, countryCode: String, number: String, user: User) {
        self.name = name
        self.countryCode = countryCode
        self.number = number
        self.user = user
        
        user.subscriptions.append(self)
        print("CarrierSubscription \(name) is initialized")
    }
    
    deinit {
        print("Deallocating CarrierSubscription named: \(name)")
    }
}

public class User {
    let name: String
    var subscriptions: [CarrierSubscription] = []
    
    init(name: String) {
        self.name = name
        print("User \(name) was initialized")
    }
    
    deinit {
        print("Deallocating user named: \(name)")
    }
}

class Phone {
    let model: String
    var owner: User?
    //weak var owner: User?
    
    var carrierSubscription: CarrierSubscription?
    
    func provision(carrierSubscription: CarrierSubscription) {
        self.carrierSubscription = carrierSubscription
    }
    
    func decommission() {
        carrierSubscription = nil
    }
    
    init(model: String) {
        self.model = model
        print("Phone \(model) was initialized")
    }
    
    deinit {
        print("Deallocating phone named: \(model)")
    }
}

class CheckFail {
    let who: String
    
    init(who: String) {
        self.who = who
    }
    
    /*lazy var greetingMaker: () -> String = { [unowned self] in
        return "Hello \(self.who)."
    }*/
    
    lazy var greetingMaker: () -> String = { [weak self] in
        guard let self = self else {
            return "No greeting available."
        }
        return "Hello \(self.who)."
    }
}

/*class User {
 let name: String
 private(set) var phones: [Phone] = []
 
 func add(phone: Phone) {
 phones.append(phone)
 phone.owner = self
 }
 
 init(name: String) {
 self.name = name
 print("User \(name) was initialized")
 }
 
 deinit {
 print("Deallocating user named: \(name)")
 }
 }
 
 class Phone {
 let model: String
 //var owner: User?
 weak var owner: User?
 
 init(model: String) {
 self.model = model
 print("Phone \(model) was initialized")
 }
 
 deinit {
 print("Deallocating phone named: \(model)")
 }
 }*/


/*As a modern, high-level programming language, Swift handles much of the memory management of your apps and allocates or deallocates memory on your behalf. It does so using a feature of the Clang compiler called Automatic Reference Counting, or ARC. In this tutorial, you’ll learn all about ARC and memory management in Swift.
 With an understanding of this system, you can influence when the life of a heap object ends. Swift uses ARC to be predictable and efficient in resource-constrained environments.
 ARC works automatically, so you don’t need to participate in reference counting, but you do need to consider relationships between objects to avoid memory leaks. This is an important requirement that is often overlooked by new developers.
 In this tutorial, you’ll level up your Swift and ARC skills by learning the following:
 How ARC works.
 What reference cycles are and how to break them.
 An example of a reference cycle in practice.
 How to detect reference cycles with the latest Xcode visualization tools.
 How to deal with mixed value and reference types.
 Getting Started
 Click the Download Materials button at the top or bottom of this tutorial. In the folder named Cycles, open the starter project. For the first part of this tutorial, you’ll be working completely inside MainViewController.swift to learn some core concepts.
 Add the following class to the bottom of MainViewController.swift:
 class User {
 let name: String
 
 init(name: String) {
 self.name = name
 print("User \(name) was initialized")
 }
 
 deinit {
 print("Deallocating user named: \(name)")
 }
 }
 
 This defines a class User which has print statements to show when you have initialized or deallocated it.
 Now, initialize an instance of User at the top of MainViewController.
 Put the following code above viewDidLoad():
 let user = User(name: "John")
 
 Build and run the app. Make sure the console is visible with Command-Shift-Y so you can see the result of the print statements.
 Notice that the console shows User John was initialized and that the print within deinit is never called. This means that the object is never deallocated because it never goes out of scope.
 In other words, since the view controller that contains this object never goes out of scope, the object is never removed from memory.
 Is That in Scope?
 Wrapping the instance of user in a method will allow it to go out of scope, letting ARC deallocate it.
 Create a method called runScenario() inside the MainViewController class. Move the initialization of User inside of it.
 func runScenario() {
 let user = User(name: "John")
 }
 
 runScenario() defines the scope for the instance of User. At the end of this scope, user should be deallocated.
 Now, call runScenario() by adding the following at the end of viewDidLoad():
 runScenario()
 
 Build and run again. The console output now looks like this:
 User John was initialized
 Deallocating user named: John
 
 The initialization and deallocation print statements both appear. These statements show that you’ve deallocated the object at the end of the scope.
 An Object’s Lifetime
 The lifetime of a Swift object consists of five stages:
 Allocation: Takes memory from a stack or heap.
 Initialization: init code runs.
 Usage.
 Deinitialization: deinit code runs.
 Deallocation: Returns memory to a stack or heap.
 There are no direct hooks into allocation and deallocation, but you can use print statements in init and deinit as a proxy for monitoring those processes.
 Reference counts, also known as usage counts, determine when an object is no longer needed. This count indicates how many “things” reference the object. The object is no longer needed when its usage count reaches zero and no clients of the object remain. The object then deinitializes and deallocates.
 SchemeOne
 When you initialize the User object, it starts with a reference count of one, since the constant user references that object.
 At the end of runScenario(), user goes out of scope and the reference count decrements to zero. As a result, user deinitializes and subsequently deallocates.
 Reference Cycles
 In most cases, ARC works like a charm. As an app developer, you don’t usually have to worry about memory leaks, where unused objects stay alive indefinitely.
 But it’s not all smooth sailing. Leaks can happen!
 How can these leaks occur? Imagine a situation where two objects are no longer required, but each references the other. Since each has a non-zero reference count, neither object can deallocate.
 
 This is a strong reference cycle. It fools ARC and prevents it from cleaning up.
 As you can see, the reference count at the end is not zero, and even though neither is still required, object1 and object2 are never deallocated.
 Checking Your References
 To see this in action, add the following code after User in MainViewController.swift:
 class Phone {
 let model: String
 var owner: User?
 
 init(model: String) {
 self.model = model
 print("Phone \(model) was initialized")
 }
 
 deinit {
 print("Deallocating phone named: \(model)")
 }
 }
 
 This adds a new class called Phone. It has two properties, one for the model and one for the owner, with init and deinit methods. The owner property is optional, since a Phone can exist without a User.
 Next add the following line to runScenario():
 let iPhone = Phone(model: "iPhone Xs")
 
 This creates an instance of Phone.
 Hold the Phone(s)
 Next, add the following code to User, immediately after the name property:
 private(set) var phones: [Phone] = []
 
 func add(phone: Phone) {
 phones.append(phone)
 phone.owner = self
 }
 
 This adds a phones array property to hold all phones owned by a user. The setter is private, so clients have to use add(phone:). This method ensures that owner is set properly when you add it.
 Build and run. As you can see in the console, the Phone and User objects deallocate as expected.
 User John was initialized
 Phone iPhone XS was initialized
 Deallocating phone named: iPhone Xs
 Deallocating user named: John
 
 Now, add the following at the end of runScenario():
 user.add(phone: iPhone)
 
 Here, you add iPhone to user. add(phone:) also sets the owner property of iPhone to user.
 Now build and run, and you’ll see user and iPhone do not deallocate. A strong reference cycle between the two objects prevents ARC from deallocating either of them.
 UserIphoneCycle
 Weak References
 To break strong reference cycles, you can specify the relationship between reference counted objects as weak.
 Unless otherwise specified, all references are strong and impact reference counts. Weak references, however, don’t increase the reference count of an object.
 In other words, weak references don’t participate in the lifecycle management of an object. Additionally, weak references are always declared as optional types. This means when the reference count goes to zero, the reference can automatically be set to nil.
 WeakReference
 In the image above, the dashed arrow represents a weak reference. Notice how the reference count of object1 is 1 because variable1 refers to it. The reference count of object2 is 2, because both variable2 and object1 refer to it.
 While object2 references object1, it does so weakly, meaning it doesn’t affect the strong reference count of object1.
 When both variable1 and variable2 go away, object1 will have a reference count of zero and deinit will run. This removes the strong reference to object2, which subsequently deinitializes.
 Back in the Phone class, change the owner declaration to match the following:
 weak var owner: User?
 
 This breaks the User to Phone reference cycle by making the owner reference weak.
 UserIphoneCycleWeaked
 Build and run again. Now user and phone deallocate properly once the runScenario() method exits scope.
 Unowned References
 There is another reference modifier you can use that doesn’t increase the reference count: unowned.
 What’s the difference between unowned and weak? A weak reference is always optional and automatically becomes nil when the referenced object goes away.
 That’s why you must define weak properties as optional var types for your code to compile: The property needs to change.
 Unowned references, by contrast, are never optional types. If you try to access an unowned property that refers to a deinitialized object, you’ll trigger a runtime error comparable to force unwrapping a nil optional type.
 Table
 Time to get some practice using unowned.
 Add a new class CarrierSubscription at the end of MainViewController.swift:
 class CarrierSubscription {
 let name: String
 let countryCode: String
 let number: String
 let user: User
 
 init(name: String, countryCode: String, number: String, user: User) {
 self.name = name
 self.countryCode = countryCode
 self.number = number
 self.user = user
 
 print("CarrierSubscription \(name) is initialized")
 }
 
 deinit {
 print("Deallocating CarrierSubscription named: \(name)")
 }
 }
 
 CarrierSubscription has four properties:
 Name: Name of the subscription.
 CountryCode: Country of the subscription.
 Number: Phone number.
 User: Reference to a Userobject.
 Who’s Your Carrier?
 Next, add the following to User after the name property:
 var subscriptions: [CarrierSubscription] = []
 
 This adds a subscriptions property, which holds an array of CarrierSubscription objects.
 Also, add the following to the top of the Phone class, after the owner property:
 var carrierSubscription: CarrierSubscription?
 
 func provision(carrierSubscription: CarrierSubscription) {
 self.carrierSubscription = carrierSubscription
 }
 
 func decommission() {
 carrierSubscription = nil
 }
 
 This adds an optional CarrierSubscription property and two new methods to provision and decommission a carrier subscription on the phone.
 Next, add the following to init inside CarrierSubscription, just before the print statement:
 user.subscriptions.append(self)
 
 This adds CarrierSubscription to the user’s array of subscriptions.
 Finally, add the following to the end of runScenario():
 let subscription = CarrierSubscription(
 name: "TelBel",
 countryCode: "0032",
 number: "31415926",
 user: user)
 iPhone.provision(carrierSubscription: subscription)
 
 This creates a CarrierSubscription for user and provisions iPhone with it.
 Build and run. Notice the console printout:
 User John was initialized
 Phone iPhone Xs was initialized
 CarrierSubscription TelBel is initialized
 
 Again, you see a reference cycle: Neither user, iPhone or subscription gets deallocated at the end.
 Can you find where the issue is now?
 
 Break the Chain
 Either the reference from user to subscription or the reference from subscription to user should be unowned to break the cycle. The question is, which of the two to choose. This is where a little bit of knowledge of your domain helps.
 A user owns a carrier subscription, but, contrary to what carriers may think, the carrier subscription does not own the user.
 Moreover, it doesn’t make sense for a CarrierSubscription to exist without an owning User. This is why you declared it as an immutable let property in the first place.
 Since a User with no CarrierSubscription can exist, but no CarrierSubscription can exist without a User, the user reference should be unowned.
 Change the user declaration in CarrierSubscription to the following:
 unowned let user: User
 
 user is now unowned, breaking the reference cycle and allowing every object to deallocate. Build and run to confirm.
 
 Reference Cycles With Closures
 Reference cycles for objects occur when properties reference each other. Like objects, closures are also reference types and can cause cycles. Closures capture, or close over, the objects they operate on.
 For example, if you assign a closure to a property of a class, and that closure uses instance properties of that same class, you have a reference cycle. In other words, the object holds a reference to the closure via a stored property. The closure holds a reference to the object via the captured value of self.
 Closure Reference
 Add the following to CarrierSubscription, just after the user property:
 lazy var completePhoneNumber: () -> String = {
 self.countryCode + " " + self.number
 }
 
 This closure computes and returns a complete phone number. The property is lazy, meaning that you’ll delay its assignment until the first time you use the property.
 This is necessary because it’s using self.countryCode and self.number, which aren’t available until after the initializer runs.
 Add the following line at the end of runScenario():
 print(subscription.completePhoneNumber())
 
 Accessing completePhoneNumber() will force the closure to run and assign the property.
 Build and run, and you’ll notice that user and iPhone deallocate, but CarrierSubscription does not, due to the strong reference cycle between the object and the closure.
 
 Capture Lists
 Swift has a simple, elegant way to break strong reference cycles in closures. You declare a capture list in which you define the relationships between the closure and the objects it captures.
 To illustrate how the capture list works, consider the following code:
 var x = 5
 var y = 5
 
 let someClosure = { [x] in
 print("\(x), \(y)")
 }
 x = 6
 y = 6
 
 someClosure()        // Prints 5, 6
 print("\(x), \(y)")  // Prints 6, 6
 
 x is in the closure capture list, so you copy x at the definition point of the closure. It’s captured by value.
 y is not in the capture list, and is instead captured by reference. This means that y will be whatever it is when the closure runs, rather than what it was at the point of capture.
 Capture lists come in handy for defining a weak or unowned relationship between objects used in a closure. In this case, unowned is a good fit, since the closure cannot exist if the instance of CarrierSubscription has gone away.
 Capture Your Self
 Replace the declaration of completePhoneNumber in CarrierSubscription with the following:
 lazy var completePhoneNumber: () -> String = { [unowned self] in
 return self.countryCode + " " + self.number
 }
 
 This adds [unowned self] to the capture list for the closure. It means that you’ve captured self as an unowned reference instead of a strong reference.
 Build and run, and you’ll see CarrierSubscription now gets deallocated. This solves the reference cycle. Hooray!
 The syntax used here is actually a shorthand for a longer capture syntax, which introduces a new identifier. Consider the longer form:
 var closure = { [unowned newID = self] in
 // Use unowned newID here...
 }
 
 Here, newID is an unowned copy of self. Outside the closure’s scope, self keeps its original meaning. In the short form, which you used above, you are creating a new self variable, which shadows the existing self variable only during the closure’s scope.
 Using Unowned With Care
 In your code, the relationship between self and completePhoneNumber is unowned.
 If you are sure that a referenced object from a closure will never deallocate, you can use unowned. However, if it does deallocate, you are in trouble.
 Add the following code to the end of MainViewController.swift:
 class WWDCGreeting {
 let who: String
 
 init(who: String) {
 self.who = who
 }
 
 lazy var greetingMaker: () -> String = { [unowned self] in
 return "Hello \(self.who)."
 }
 }
 
 Next, add the following code block to the end of runScenario():
 let greetingMaker: () -> String
 
 do {
 let mermaid = WWDCGreeting(who: "caffeinated mermaid")
 greetingMaker = mermaid.greetingMaker
 }
 
 print(greetingMaker()) // TRAP!
 
 Build and run, and you’ll crash with something like the following in the console:
 User John was initialized
 Phone iPhone XS was initialized
 CarrierSubscription TelBel is initialized
 0032 31415926
 Fatal error: Attempted to read an unowned reference but object 0x600000f0de30 was already deallocated2019-02-24 12:29:40.744248-0600 Cycles[33489:5926466] Fatal error: Attempted to read an unowned reference but object 0x600000f0de30 was already deallocated
 
 The app hit a runtime exception because the closure expected self.who to still be valid, but you deallocated it when mermaid went out of scope at the end of the do block.
 This example may seem contrived, but it happens in real life. An example would be when you use closures to run something much later, such as after an asynchronous network call has finished.
 Disarming the Trap
 Replace the greetingMaker variable in WWDCGreeting with the following:
 lazy var greetingMaker: () -> String = { [weak self] in
 return "Hello \(self?.who)."
 }
 
 Here, you’ve made two changes to the original greetingMaker. First, you replaced unowned with weak. Second, since self became weak, you needed to access the who property with self?.who. You can ignore the Xcode warning; you’ll fix it shortly.
 The app no longer crashes, but when you build and run, you get a curious result in the console: “Hello nil.”
 Now for Something Different
 Perhaps this result is acceptable in your situation, but more often, you’ll want to do something completely different if the object is gone. Swift’s guard let makes this easy.
 Replace the closure one last time with the following:
 lazy var greetingMaker: () -> String = { [weak self] in
 guard let self = self else {
 return "No greeting available."
 }
 return "Hello \(self.who)."
 }
 
 The guard statement binds self from weak self. If self is nil, the closure returns “No greeting available.”
 On the other hand, if self is not nil, it makes self a strong reference, so the object is guaranteed to live until the end of the closure.
 This idiom, sometimes referred to as the strong-weak dance, is part of the Ray Wenderlich Swift Style Guide, since it’s a robust pattern for handling this behavior in closures.
 testskillz
 Build and run to see that you now get the appropriate message.
 Finding Reference Cycles in Xcode 10
 Now that you understand the principles of ARC, what reference cycles are and how to break them, it’s time to look at a real world example.
 Open the Starter project inside the Contacts folder in Xcode.
 Build and run the project, and you’ll see the following:
 
 This is a simple contacts app. Feel free to tap on a contact to get more information or add contacts using the + button on the top right-hand side of the screen.
 Have a look at the code:
 ContactsTableViewController: Shows all the Contact objects from the database.
 DetailViewController: Shows the details for a certain Contact object.
 NewContactViewController: Allows the user to add a new contact.
 ContactTableViewCell: A custom table view cell that shows the details of a Contact object.
 Contact: The model for a contact in the database.
 Number: The model for a phone number.
 There is, however, something horribly wrong with the project: Buried in there is a reference cycle. Your user won’t notice the issue for quite some time since the leaking objects are small, and their size makes the leak even harder to trace.
 Fortunately, Xcode 10 has a built-in tool to help you find even the smallest leaks.
 Build and run the app again. Delete three or four contacts by swiping their cells to the left and tapping delete. They appear to have disappeared completely, right?
 
 Where Is That Leak?
 While the app is still running, move over to the bottom of Xcode and click the Debug Memory Graph button:
 ss2
 Observe the Runtime Issues in the Debug navigator. They are marked by purple squares with white exclamation marks inside, such as the one selected in this screenshot:
 
 In the navigator, select one of the problematic Contact objects. The cycle is clearly visible: The Contact and Number objects keep each other alive by referencing one another.
 
 These issues are a sign for you to look into your code. Consider that a Contact can exist without a Number, but a Number should not exist without a Contact.
 How would you solve the cycle? Should the reference from Contact to Number or the reference from Number to Contact be weak or unowned?
 Give it your best shot first, then take a look below if you need help!
 Reveal
 Bonus: Cycles With Value Types and Reference Types
 Swift types are reference types, like classes, or value types, like structures or enumerations. You copy a value type when you pass it, whereas reference types share a single copy of the information they reference.
 This means that you can’t have cycles with value types. Everything with value types is a copy, not a reference, meaning that they can’t create cyclical relationships. You need at least two references to make a cycle.
 Back in the Cycles project, add the following at the end of MainViewController.swift:
 struct Node { // Error
 var payload = 0
 var next: Node?
 }
 
 Hmm, the compiler’s not happy. A struct value type cannot be recursive or use an instance of itself. Otherwise, a struct of this type would have an infinite size.
 Change struct to a class:
 class Node {
 var payload = 0
 var next: Node?
 }
 
 Self reference is not an issue for classes (i.e. reference types), so the compiler error disappears.
 Now, add this to the end of MainViewController.swift:
 class Person {
 var name: String
 var friends: [Person] = []
 init(name: String) {
 self.name = name
 print("New person instance: \(name)")
 }
 
 deinit {
 print("Person instance \(name) is being deallocated")
 }
 }
 
 And add this to the end of runScenario()
 do {
 let ernie = Person(name: "Ernie")
 let bert = Person(name: "Bert")
 
 ernie.friends.append(bert) // Not deallocated
 bert.friends.append(ernie) // Not deallocated
 }
 
 Build and run. Notice that neither Bert nor Ernie is deallocated.
 Reference and Value
 This is an example of a mixture of value types and reference types that form a reference cycle.
 ernie and bert stay alive by keeping a reference to each other in their friends array, although the array itself is a value type.
 Make the friends array unowned and Xcode will show an error: unowned only applies to class types.
 To break the cycle here, you’ll have to create a generic wrapper object and use it to add instances to the array. If you don’t know what generics are or how to use them, check out the Introduction to Generics tutorial on this site.
 Add the following above the definition of the Person class:
 class Unowned<T: AnyObject> {
 unowned var value: T
 init (_ value: T) {
 self.value = value
 }
 }
 
 Then, change the definition of friends in Person like so:
 var friends: [Unowned<Person>] = []
 
 And finally, replace the do block in runScenario() with the following:
 do {
 let ernie = Person(name: "Ernie")
 let bert = Person(name: "Bert")
 
 ernie.friends.append(Unowned(bert))
 bert.friends.append(Unowned(ernie))
 }
 
 Build and run. ernie and bert now deallocate happily!
 The friends array isn’t a collection of Person objects anymore, but instead a collection of Unowned objects that serve as wrappers for the Person instances.
 To access the Person object within Unowned, use the value property, like so:
 let firstFriend = bert.friends.first?.value // get ernie */
