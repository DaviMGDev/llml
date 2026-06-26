# LLML — LLM Language

LLML is a toy programming language that blends deterministic programming with Large Language Models (LLMs). It is designed as a small domain-specific language (DSL) for building agentic applications without the boilerplate of traditional frameworks.

> **Status:** design / proof-of-concept. There is no compiler yet; the goal is to eventually transpile LLML to Go.

---

## Why LLML?

Most LLM frameworks are libraries embedded in general-purpose languages. LLML explores what happens when LLM-native primitives are built directly into the language:

- Semantic comparison (`~=`)
- First-class prompting
- Native tool and agent definitions
- Event-driven agent interactions

---

## Features

### 1. Semantic comparison operator `~=`

Compare values by meaning, not just by exact equality. The compiler/runtime decides whether a comparison can be resolved deterministically or needs an LLM.

```llml
if ("hi" ~= "greeting") {
    print("hi is a greeting")
}

Natural{value: 20} ~= int
Natural{value: 20} ~= "number"
Natural{value: 20} ~= "can be an age"
```

### 2. First-class prompting

Prompt the main agent as a normal expression. By default the result is a string; wrap it in `Response[T]` to request a specific type.

```llml
response := prompt("what is the meaning of life?")
var value Response[int] = prompt("what is 2 + 2?")
```

### 3. Tools

Expose functions to the LLM with the `@tool` decorator.

```llml
@tool("get the weather of a city")
func getWeather(city string) string {
    return "sunny"
}

print(prompt("what is the weather of New York?"))
```

### 4. Subagents

Define agents with their own system prompt, tools, internal state, and helper methods. Subagents are invoked directly from the main program.

```llml
agent Planner {
    system := "You are a planner agent."
    tools := {getWeather}
    attribute := "value"

    func method() string {
        return this.attribute
    }

    @tool("get the agent's internal attribute")
    func getAttribute() string {
        return this.attribute
    }
}

Planner.prompt("what is the weather of New York?")
print(Planner.method())
```

### 5. Event system

Events can be defined globally or inside classes, then emitted and handled with `emit` and `on`.

```llml
event Event {
    id int
}

emit Event { id: 1 }

on Event {
    print("event received with id: " + Event.id)
}
```

### 6. Built-in agent events

Every agent exposes `UserInput` and `AgentResponse` events.

```llml
on UserInput {
    print("user input received: " + UserInput.input)
}

on Planner.AgentResponse {
    print("planner response: " + Planner.AgentResponse.response)
}
```

---

## Example

See [`example.llml`](example.llml) for a commented tour of the language.

---

## Project goals

- Keep agent code concise and readable.
- Make LLM calls, tools, and subagents first-class language features.
- Explore transpilation to Go for concurrency and performance.

---

## License

MIT
