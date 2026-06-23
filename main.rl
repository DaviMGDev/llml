// this is a comment
/*
this is a multiline comment 
*/

// how to declare and initialize a var:
x: int = 5 // type annotation is optional, but recommended for clarity
y = 10.12

// consts:
const pi: float = 3.14159

/* primitive types:
int, float, number(number is int | float),
string, bool, byte,
any (generic type), 
void (no return value)
error (used for error handling)
union types: type1 | type2 | ... | typeN (any is a union type of all types basically)
*/

/* data structures:
array: [size]type
map: map[key_type]value_type
set: set[type]
tuple: (type1, type2, ...)
*/

// class:
class Class(BaseClass) { // optional inheritance
    attr1: type1 = value1 // attribute with default value.
    attr2: type2 // attribute without default value.
    (a1, a2) {
        this.attr1 = a1
        this.attr2 = a2
    }
    function method1() {
        // method body
    }
}

// invariants system. must be used when defining a type, or class.
type natural(int) {
    invariants {
        this >= 0
    }
}

n: natural = -1 // this will throw an error because -1 is not a natural number
// this might become a problem, so we will add a new keyword to handle this type of situation.
// "can" keyword will be used to indicate that a variable can do something of not

print(can n = -1) // this will print false because n cannot be -1
if (can n = -1) {
    print("n can be -1")
} else {
    print("n cannot be -1")
}

// an example with a class:
class Person {
    name: string 
    age: natural 
    (name: string, age: natural) {
        this.name = name
        this.age = age
    }
    function greet() {
        print("Hello, my name is " + this.name + " and I am " + this.age + " years old.")
    }
}

class Adult(Person) {
    invariants {
        this.age >= 18
    }
}

someone: Adult = Adult("John", 17) // this will throw an error because 17 is not a valid age for an adult 
print(can Adult("John", 17)) // this will print false because someone cannot be an adult with age 17

// requirements and guarantees:
class Container {
    value: int 
    invariants {
        this.value >= 0
    }
    (value: int) {
        this.value = value 
    }
    fnction increment(value: int) {
        requires {
            value > 0
        }
        ensure {
            this.value + value > old(this.value)
        }
        this.value += value 
    }
}

// can be used in functions as well:
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

// disclaimer: while this language supports this kind of programming, the developer still can write without using these features, or using only when really needed. The language is designed to be flexible and not force the developer to use these features if they don't want to.

// btw, something cool of this language too is reactive programming with the keywords "when/before/after".
/* reactive programming:
when condition {}
when statechange {}

a = 0
when a {
    print("a changed to ${new(a)}")
}

when a > 5 {
    print("a is greater than 5 now")
}

also works with functions:
function add(a, b) {
    return a + b 
}

when add(2, 3) {
    print("add was called with 2 and 3")
}

when add(a, b) {
    print("add was called with ${a} and ${b}")
}

when add(2, 3) > 5 {
    print("add returned a value greater than 5")
}

before/after can be used to run code before or after something happens 

before a {
    print("something is accessing a")
}

before add(2, 3) {
    print("add is about to be called with 2 and 3")
}

before add(a, b) {
    print("add is about to be called with ${a} and ${b}")
}

after a {
    print("something just accessed a")
}

after add(2, 3) {
    print("add was just called with 2 and 3")
}

after add(a, b) {
    print("add was just called with ${a} and ${b}")
}

with classes, you can use before/after to run code before or after a method is called:
class Person {
    name: string
    (name: string) {
        this.name = name
    }
    function greet() {
        print("Hello, my name is " + this.name)
    }
    before greet() {
        print("greet is about to be called")
    }
    after greet() {
        print("greet was just called")
    }
}

important rule!!!: when/before/after can not change the state, it can only read the state, it can change others states, but not the same state what is being observed. this is to avoid infinite loops and other problems.

other cool thing here is "alias" keyword which can be used to create an alias for **anything** 

alias method {function}

method methodName() {
    // body 
}

// alias can accept parameters too 

alias method(name, params) {function name(...params)}

method(greet, (greeting, name)) {
    return "${greeting}, my name is ${name}!"
}

// alias are not a runtime/compilation feature, it is a preprocessor feature, like macros in C/C++

*/
