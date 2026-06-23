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

// 8. Custom operators 
// Aliases can also define custom operators for DSLs.
alias `~=`(a, b) {
    a == b 
}

// Usage:
print(5 ~= 5) // Expands to: print(5 == 5) => true

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

// ==========================================
// 10. ASYNC & CONCURRENCY
// ==========================================

/*
  Unified Model:
  - Channels are the primitive for communication.
  - `await` is syntactic sugar for `<-` (left-to-right readability).
  - `async function` is sugar for a channel-returning function with a spawned body.
  - `when` works with channels natively (reactive + async are unified).
  - NO function coloring: any function can call any other function.
*/

// ======== 10a. CHANNELS (Primitive) ========

ch: channel[int] = channel[int](5)    // buffered channel, capacity 5
ch: channel[int] = channel[int]()     // unbuffered channel

ch <- value                            // send (blocks if full / no receiver)
v = <- ch                              // receive (blocks if empty / closed)

// Non-blocking receive with default
v = <- ch or default_value

// Channel state queries (using existing `can` pattern)
if (can <- ch) {
    print("Channel is open and has a value")
} else {
    print("Channel is closed or empty")
}

if (ch closed) {
    print("Channel is definitely closed")
}

// Iterating over a channel (auto-closes when channel is closed)
for value in <- ch {
    print("got: ${value}")
}

// ======== 10b. CONCURRENCY (Lightweight Tasks) ========

// `run` spawns a lightweight concurrent task (like Go's `go`)
run function() {
    ch <- 42
}

// Block-syntax shortcut for lightweight cases
run {
    ch <- 42
}

// ======== 10c. REACTIVE INTEGRATION with `when` ========

// `when` on a channel reacts to every new message — no RxJS needed
when ch {
    print("received: ${new(ch)}")
}

// React to channel closure
when ch closed {
    print("channel closed, no more messages")
}

// React to an async function call directly
when fetch_data("url") {
    update_ui(new(ch))
}

// ======== 10d. SELECT (Multiplexing Channels) ========

select {
    case v <- ch1 {
        print("got ${v} from ch1")
    }
    case v <- ch2 {
        print("got ${v} from ch2")
    }
    case <- time.after(1s) {
        print("timeout — no channel ready within 1 second")
    }
    default {
        print("no channel ready right now")
    }
}

// ======== 10e. AWAIT (Syntactic Sugar for `<-`) ========

/*
  `await` is NOT a special keyword that requires special contexts.
  It is simply `<-` written left-to-right for readability:

    await expr   ≡   <- expr

  This is especially helpful for deeply nested calls:
*/

// Right-to-left (hard to read):
data = <- parse(<- fetch("url"))

// Left-to-right with await (clearer chain):
data = await parse(await fetch("url"))

// `await` can be used ANYWHERE — no async context required
result = await compute_something()

// ======== 10f. ASYNC FUNCTION (Syntactic Sugar) ========

/*
  An `async function` is sugar that tells the compiler:
    1. Return type becomes channel<T> automatically.
    2. The function body runs in a spawned task.
*/

async function fetch(url: string): string {
    response = http.get(url)           // blocks THIS task, not the caller
    return response.body               // sends result to channel
}

/* Desugars to exactly this:

function fetch(url: string): channel[string] {
    ch: channel[string] = channel[string](1)
    run {
        response = http.get(url)
        ch <- response.body
    }
    return ch
}
*/

// Contracts work naturally with async functions
async function divide(a: int, b: int): int {
    requires { b != 0 }
    ensure  { result == a / b }
    return a / b
}

// ======== 10g. NO FUNCTION COLORING ========

/*
  Because `async function` is just sugar and `await` is just sugar,
  there is NO colored-function problem. You can call any function
  from anywhere in any style:
*/

// Block and wait
result = await fetch("url")

// Get the channel, process later
future = fetch("url")

// React to it reactively
when fetch("url") {
    update_ui(new(ch))
}

// Process in another task
run {
    result = <- fetch("url")
    print(result)
}

// Pass the channel around — channels are just values
ch = fetch("url")

// Pattern matching on channel receive
match <- ch {
    case Ok(val) { print("got ${val}") }
    case Err(e)  { print("error: ${e.message}") }
    default      { print("channel closed") }
}

// ==========================================
// 11. GENERICS (Parametric Polymorphism)
// ==========================================

/*
  Generics use square brackets [T], consistent with []type for arrays.
  Constraints reuse the contract system (requires / ensures).
  The `can` keyword works at compile time for type introspection.
*/

// ======== 11a. GENERIC FUNCTIONS ========

function identity[T](value: T): T {
    return value
}

// Multiple type parameters
function pair[A, B](a: A, b: B): (A, B) {
    return (a, b)
}

// ======== 11b. GENERIC CLASSES ========

class Box[T] {
    value: T

    init(value: T) {
        this.value = value
    }

    function get(): T {
        return this.value
    }
}

// Usage with explicit type
b: Box[int] = Box[int](42)

// Usage with type inference (no annotation needed)
b = Box("hello")          // Box[string] inferred
b = Box(42)                // Box[int] inferred

// ======== 11c. GENERIC CONSTRAINTS (Design by Contract) ========

// Contract-style constraint reuses `requires` — no new keyword
function add[T](a: T, b: T): T 
    requires { T is number }
{
    return a + b
}

// Shorthand for common constraints
function max[T: Comparable](a: T, b: T): T {
    if a > b { return a }
    return b
}

// Multiple constraints
function serialize[T: Serializable & Comparable](items: []T): string {
    // T must be both serializable and comparable
    result = ""
    for item in sort(items) {
        result += item.to_json()
    }
    return result
}

// Constraint with postcondition
function first[T](items: []T): T 
    requires { items.len() > 0 }
{
    return items[0]
}

// ======== 11d. GENERIC COLLECTIONS ========

class Stack[T] {
    items: []T = []

    function push(item: T) {
        items.append(item)
    }

    function pop(): T 
        requires { items.len() > 0 }
    {
        return items.pop()
    }

    function peek(): T 
        requires { items.len() > 0 }
    {
        return items[-1]
    }

    function is_empty(): bool {
        return items.len() == 0
    }
}

class Map[K, V] {
    entries: [(K, V)] = []

    function set(key: K, value: V) {
        // Upsert logic
        for i, (k, _) in entries {
            if k == key {
                entries[i] = (key, value)
                return
            }
        }
        entries.append((key, value))
    }

    function get(key: K): Optional[V] {
        for k, v in entries {
            if k == key {
                return Some(v)
            }
        }
        return none
    }
}

// ======== 11e. GENERIC HIGHER-ORDER FUNCTIONS ========

function map[T, U](items: []T, f: function(T): U): []U {
    result: []U = []
    for item in items {
        result.append(f(item))
    }
    return result
}

function filter[T](items: []T, pred: function(T): bool): []T {
    result: []T = []
    for item in items {
        if pred(item) {
            result.append(item)
        }
    }
    return result
}

function reduce[T, U](items: []T, init: U, f: function(U, T): U): U {
    acc = init
    for item in items {
        acc = f(acc, item)
    }
    return acc
}

// Usage:
squared = map([1, 2, 3, 4], function(x) { x * x })
// => [1, 4, 9, 16]

evens = filter([1, 2, 3, 4], function(x) { x % 2 == 0 })
// => [2, 4]

sum = reduce([1, 2, 3, 4], 0, function(acc, x) { acc + x })
// => 10

// ======== 11f. COMPILE-TIME TYPE INTROSPECTION ========

// The `can` keyword extends naturally to compile-time type queries

function type_name[T](): string {
    if (can T is int)     return "integer"
    if (can T is string)  return "string"
    if (can T is number)  return "numeric"
    if (can T is bool)    return "boolean"
    return "unknown"
}

// Structural checks at compile time
if (can T is Iterable) {
    // T has an iterator — we can loop over it
}

if (can T is Comparable) {
    // T supports comparison operators
}

// ======== 11g. GENERIC TYPE ALIASES ========

// Result[T] — no new syntax needed, works with existing union types
type Result[T] = Ok(T) | Err(error)

function divide(a: int, b: int): Result[int] {
    if b == 0 {
        return Err("division by zero")
    }
    return Ok(a / b)
}

// Pattern match on Result
match divide(10, 2) {
    case Ok(val) { print("result: ${val}") }
    case Err(e)  { print("failed: ${e.message}") }
}

// Optional[T]
type Optional[T] = Some(T) | none

// Recursive tree type
type Tree[T] = Node(T, []Tree[T]) | Leaf(T)

// ======== 11h. GENERICS + INVARIANTS ========

// Type invariants compose with generics
type positive(T) {
    invariants {
        this > 0
    }
}

p: positive(int) = 5        // OK
// p: positive(int) = -1    // Compile-time error: invariant violation

// Class invariants with generic types
class Container[T] {
    value: T

    invariants {
        can value is T       // value always matches the type parameter
    }

    init(value: T) {
        this.value = value
    }

    function set(val: T) {
        requires {
            can val is T
        }
        this.value = val
    }

    function get(): T {
        return this.value
    }
}

// ======== 11i. INTEROPERABILITY PREVIEWS ========

// Generics + Async
async function fetch_json[T](url: string): T {
    requires { T is Serializable }
    ensure  { can result is T }

    raw = await http.get(url)
    return parse_json[T](raw)
}

// Generics + Channels
function broadcast[T](input: channel[T], n: int): []channel[T] {
    outputs: []channel[T] = []
    for i in 0..n {
        outputs.append(channel[T](10))
    }

    run {
        for value in <- input {
            for out in outputs {
                out <- value
            }
        }
        for out in outputs {
            out <- close       // close all outputs when input is exhausted
        }
    }

    return outputs
}

// Generics + Reactive
when broadcast(data_stream, 3) {
    print("broadcast channel has a new value: ${new(ch)}")
}
