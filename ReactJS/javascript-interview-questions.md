# JavaScript Interview Questions

## Table of Contents
- [What is the difference between Callbacks and Promises?](#callbacks-vs-promises)
- [What is the Event Loop in JavaScript?](#event-loop)

---

## callbacks-vs-promises
## What is the difference between Callbacks and Promises?

**Answer:**

Callbacks and Promises are both ways to handle asynchronous operations in JavaScript, but they differ significantly in their approach and capabilities.

### Callbacks
Callbacks are functions passed as arguments to other functions, which are executed once the asynchronous operation completes.

**Simple Example:**
```javascript
// Callback approach
function fetchUserData(userId, callback) {
    setTimeout(() => {
        const user = { id: userId, name: "John Doe" };
        callback(user);
    }, 1000);
}

fetchUserData(123, (user) => {
    console.log("User:", user.name);
});
```

**Problems with Callbacks:**
- **Callback Hell**: Nested callbacks become hard to read and maintain
- **Error Handling**: Difficult to handle errors properly
- **Inversion of Control**: You lose control over when the callback executes

### Promises
Promises represent the eventual completion (or failure) of an asynchronous operation and its resulting value.

**Simple Example:**
```javascript
// Promise approach
function fetchUserData(userId) {
    return new Promise((resolve, reject) => {
        setTimeout(() => {
            const user = { id: userId, name: "John Doe" };
            resolve(user);
        }, 1000);
    });
}

fetchUserData(123)
    .then(user => console.log("User:", user.name))
    .catch(error => console.error("Error:", error));
```

**Advantages of Promises:**
- **Better Error Handling**: Using `.catch()` for centralized error handling
- **Chaining**: Easy to chain multiple operations with `.then()`
- **Async/Await**: Can be used with modern async/await syntax

**Async/Await Example:**
```javascript
async function getUserData() {
    try {
        const user = await fetchUserData(123);
        console.log("User:", user.name);
    } catch (error) {
        console.error("Error:", error);
    }
}
```

---
## event-loop
## What is the Event Loop in JavaScript?

**Answer:**

The Event Loop is a fundamental mechanism in JavaScript that allows it to perform non-blocking operations despite being single-threaded. It's what makes JavaScript asynchronous.

### How the Event Loop Works

JavaScript has a **single-threaded** execution model, meaning it can only execute one piece of code at a time. However, it can handle multiple operations through the Event Loop.

**Simple Example:**
```javascript
console.log("1. Start");

setTimeout(() => {
    console.log("3. Timeout callback");
}, 0);

console.log("2. End");

// Output:
// 1. Start
// 2. End
// 3. Timeout callback
```

### Event Loop Components

1. **Call Stack**: Where synchronous code executes
2. **Web APIs**: Browser APIs (setTimeout, fetch, DOM events)
3. **Callback Queue**: Where callbacks wait to be executed
4. **Event Loop**: Continuously checks if call stack is empty

**Detailed Example:**
```javascript
console.log("1. Synchronous code starts");

setTimeout(() => {
    console.log("4. Timeout 1 (0ms)");
}, 0);

setTimeout(() => {
    console.log("5. Timeout 2 (100ms)");
}, 100);

Promise.resolve().then(() => {
    console.log("3. Microtask (Promise)");
});

console.log("2. Synchronous code ends");

// Output:
// 1. Synchronous code starts
// 2. Synchronous code ends
// 3. Microtask (Promise)
// 4. Timeout 1 (0ms)
// 5. Timeout 2 (100ms)
```

### Execution Order

1. **Synchronous code** executes first (Call Stack)
2. **Microtasks** execute next (Promises, queueMicrotask)
3. **Macrotasks** execute last (setTimeout, setInterval, DOM events)

**Microtask vs Macrotask Example:**
```javascript
console.log("1. Start");

setTimeout(() => {
    console.log("5. Macrotask (setTimeout)");
}, 0);

Promise.resolve().then(() => {
    console.log("3. Microtask 1");
    return Promise.resolve();
}).then(() => {
    console.log("4. Microtask 2");
});

console.log("2. End");

// Output:
// 1. Start
// 2. End
// 3. Microtask 1
// 4. Microtask 2
// 5. Macrotask (setTimeout)
```

### Why This Matters

Understanding the Event Loop helps you:
- Write more predictable asynchronous code
- Avoid blocking the main thread
- Understand why certain operations execute in specific order
- Debug timing-related issues

**Common Interview Follow-up:**
- "What's the difference between microtasks and macrotasks?"
- "How would you prevent blocking the main thread?"
- "What happens if you have an infinite loop in your code?"

---

## How to Make Links Clickable in Markdown

### Option 1: Use a Markdown Viewer/Editor
- **VS Code**: Links work automatically in preview mode
- **Typora**: Links work automatically
- **GitHub**: Links work automatically when viewing the file
- **Obsidian**: Links work automatically

### Option 2: Convert to HTML (if needed)
If you need clickable links in a browser, you can convert this markdown to HTML using:
- Online converters
- VS Code extensions
- Command line tools like `pandoc`

### Option 3: Use Markdown with TOC Support
Many markdown viewers support table of contents with clickable links automatically.

## How to Add More Questions

To add a new question:

1. **Add to Table of Contents** (at the top):
   ```markdown
   - [Your Question Title?](#descriptive-anchor-name)
   ```

2. **Add the question section** (anywhere you want):
   ```markdown
   ## Your Question Title?
   
   **Answer:**
   
   Your detailed answer here...
   
   ---
   ```

3. **Use consistent formatting**:
   - Question titles as `##` headers
   - Use `**Answer:**` for the main explanation
   - Include code examples in ```javascript blocks
   - Add `---` separators between questions

4. **Anchor Link Rules**:
   - Use descriptive, lowercase names with hyphens
   - No numbers in anchor links
   - Examples: `#callbacks-vs-promises`, `#event-loop`, `#closures`, `#hoisting`
