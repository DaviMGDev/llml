// ==========================================
// 01. BASICS: COMMENTS, VARIABLES & TYPES
// ==========================================

// Single-line comment

/*
  Multi-line comment
*/

// Variable declaration
// Type annotation is optional, but recommended for clarity
x: int = 5
y = 10.12

// Constants
const pi: float = 3.14159

/*
  Primitive Types:
  - int, float, number (int | float), string, bool, byte
  - any (generic type, union of all types)
  - void (no return value)
  - error (used for error handling)

  Union Types: type1 | type2 | ... | typeN 
*/

// ==========================================
// 02. DATA STRUCTURES
// ==========================================

/*
  - Dynamic Array: []type 
  - Fixed Array: [size]type
  - Map: map[key_type]value_type
  - Set: set[type]
  - Tuple: (type1, type2, ...)
*/

// ==========================================
// 03. OBJECT-ORIENTED PROGRAMMING (OOP)
// ==========================================

class Class(BaseClass) { // Optional inheritance

    attr1: type1 = value1 // Attribute with default value
    attr2: type2          // Attribute without default value

    // Constructor
    init(a1, a2) {
        this.attr1 = a1
        this.attr2 = a2
    }

    function method1() {
        // method body
    }
}

// ==========================================
// 04. DESIGN BY CONTRACT (Invariants & Requirements)
// ==========================================

// Type Invariants
type natural(int) {
    invariants {
        this >= 0
    }
}

// The `can` keyword checks validity (both invariants and types).
n: natural = 5 
print(can n = -1) // Prints false (violates invariant)

if (can n = -1) {
    print("n can be -1")
} else {
    print("n cannot be -1")
}

// Class Invariants
class Person {
    name: string
    age: natural

    init(name: string, age: natural) {
        this.name = name
        this.age = age
    }

    function greet() {
        print("Hello, my name is ${this.name} and I am ${this.age} years old.")
    }
}

class Adult(Person) {
    invariants {
        this.age >= 18
    }
}

print(can Adult("John", 17)) // Prints false (violates Adult invariant)

// Method Contracts (Preconditions and Postconditions)
class Container {
    value: int

    invariants {
        this.value >= 0
    }

    init(value: int) {
        this.value = value
    }

    function increment(val: int) {
        requires {
            val > 0
        }
        ensure {
            this.value == old(this.value) + val 
        }
        this.value += val
    }
}

// Function Contracts
function add(a: number, b: number): number {
    requires {
        a >= 0
        b >= 0
    }
    ensure {
        result >= a
        result >= b
    }
    return a + b
}

// ==========================================
// 05. REACTIVE & ASPECT-ORIENTED PROGRAMMING
// ==========================================

/*
  Triggers: when, before, after
  Rule: Observers cannot change the state they are observing.
*/

a = 0

when a {
    print("a changed to ${new(a)}")
}

when a > 5 {
    print("a is greater than 5 now")
}

function add_nums(a, b) {
    return a + b
}

when add_nums(2, 3) > 5 {
    print("add_nums returned a value greater than 5")
}

// AOP: Before and After advice
class PersonAOP {
    name: string

    init(name: string) { 
        this.name = name
    }

    function greet() {
        print("Hello, my name is ${this.name}")
    }

    before greet() {
        print("greet is about to be called")
    }

    after greet() {
        print("greet was just called")
    }
}

// ==========================================
// 06. COMPILE-TIME MACROS (Aliases & DSLs)
// ==========================================

/*
  The `alias` keyword creates compile-time macros/syntactic sugar.
  They are processed before runtime/compilation.
  
  Syntax Rules:
  - Regular parameters use parentheses: (param1, param2)
  - Trailing block parameters use brackets: [block1, block2]
  - Compile-time directives inside macros use the `@` symbol: @if, @for
*/

// 1. Simple Keyword Aliases
alias method {function}

method myMethod() {
    // body
}

// 2. Macros with parameters and a single trailing block
// The [block] syntax tells the compiler that the last argument is a code block.
alias fn(params)[block] {
    function(params) {
        block
    }
}

// Usage:
fn(x, y) {
    print("x: ${x}, y: ${y}")
}
/* Expands to: */
function(x, y) {
    print("x: ${x}, y: ${y}")
}

// 3. Compile-time Directives (@if, @for)
// These run during macro expansion, not at runtime.
alias repeat(n)[block] {
    @for i in 0..n {
        block
    }
}

// Usage:
repeat(3) {
    print("This will print 3 times")
}
/* Expands to: */
print("This will print 3 times")
print("This will print 3 times")
print("This will print 3 times")

// 4. Aliasing Macros (Macros can use other macros)
alias repeat_twice[block] {
    repeat(2) {
        block
    }
}

repeat_twice {
    print("This will print 2 times")
}

// 5. Conditional Compilation
// Top-level or macro-level conditional compilation using @if/@else
@if DEBUG {
    print("Debug mode is ON")
} @else {
    print("Debug mode is OFF")
}

// Inside a macro:
alias gender(person) {
    @if person == "male" {
        "he"
    } @else {
        "she"
    }
}

print(gender("male")) // Expands to: print("he")

// 6. Advanced Code Generation
// Macros can generate dynamic identifiers using string interpolation.
alias batch_fn(n)[block] {
    @for i in 0..n {
        function fn_${i}() {
            block
        }
    }
}

batch_fn(3) {
    print("This is function ${i}")
}

fn_2() // Will print "This is function 2"

// 7. Multiple Trailing Blocks
// Macros can accept more than one block parameter, allowing for complex DSLs.
alias multiblock(n)[block1, block2] {
    @for i in 0..n {
        @if i % 2 == 0 {
            block1
        } @else {
            block2
        }
    }
}

// Usage:
multiblock(4) {
    print("Even block: ${i}")
} {
    print("Odd block: ${i}")
}

/* Expands to: */
print("Even block: 0")
print("Odd block: 1")
print("Even block: 2")
print("Odd block: 3")

// ==========================================
// 07. ERROR HANDLING & TYPE CHECKING
// ==========================================

/*
  Core Concept: Every type is technically also an error type.
  Operations that fail return an `error` state instead of crashing.
*/

z: int = 5

// Type checking using the `can` keyword
if (can z = "string") {
    print("z can be a string")
} else {
    print("z cannot be a string") // This will print
}

// Safe error checking on operations
if typeof(z / 0) == error {
    print((z / 0).message) // prints "division by zero"
}

// If an invalid assignment occurs at runtime, it becomes an error state
z = "hello" // z is now in an error state
print(z.message) // prints "type error: expected int but got string"

// ==========================================
// 08. CONTROL FLOW
// ==========================================

// For loops
for i in iterable {
    // loop body
}

for i in 0..10 { // Range-based loop (Note: define if 10 is inclusive or exclusive!)
    // loop body
}

for key, value in map {
    // loop body
}

for (i = 0; i < 10; i++) { // C-style loop
    // loop body
}

// While loop
while condition {
    // loop body
}

// Pattern Matching
match value {
    case pattern1 {
        // handle pattern1
    }
    case Ok(val) { // Variable binding example
        print("Success: ${val}")
    }
    case Err(e) {
        print("Failed: ${e.message}")
    }
    default {
        // handle default case
    }
}

// ==========================================
// 09. MODULES & VISIBILITY
// ==========================================

package mypackage 

/*
  Files with the same package name are part of the same module.
  They can access each other's private members (Go-style).
*/

import module_name

public class PublicClass {
    private secret: string
    
    init() {
        this.secret = "hidden"
    }
    
    public function getSecret(): string {
        return this.secret
    }
}

/*
  Visibility rules:
  - public: Accessible anywhere.
  - private: Accessible only within the current scope (class, function, or package).
  - Default visibility depends on the scope, but should be intuitive (e.g., private by default in classes).
*/
