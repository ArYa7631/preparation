# JavaScript Interview Questions

## **📋 Question: What is the difference between callbacks and promises in JavaScript?**

**Interview Approach**: Start with a brief explanation of both concepts, then show practical examples, highlight the problems with callbacks, and explain how promises solve those problems.

---

## **🔄 Callbacks vs Promises - Key Differences**

### **1. Basic Definition**

**Callbacks**: Functions passed as arguments to other functions, executed when an asynchronous operation completes.

**Promises**: Objects that represent the eventual completion (or failure) of an asynchronous operation and its resulting value.

### **2. Syntax Comparison**

```javascript
// Callback approach
function fetchUserData(userId, callback) {
    setTimeout(() => {
        const user = { id: userId, name: 'John Doe' };
        callback(null, user);
    }, 1000);
}

fetchUserData(123, function(error, user) {
    if (error) {
        console.error('Error:', error);
        return;
    }
    console.log('User:', user);
});

// Promise approach
function fetchUserDataPromise(userId) {
    return new Promise((resolve, reject) => {
        setTimeout(() => {
            const user = { id: userId, name: 'John Doe' };
            resolve(user);
        }, 1000);
    });
}

fetchUserDataPromise(123)
    .then(user => console.log('User:', user))
    .catch(error => console.error('Error:', error));
```

### **3. Main Problems with Callbacks**

#### **Callback Hell (Pyramid of Doom)**
```javascript
// ❌ Callback Hell - Hard to read and maintain
fetchUserData(123, function(error, user) {
    if (error) return console.error(error);
    
    fetchUserPosts(user.id, function(error, posts) {
        if (error) return console.error(error);
        
        fetchPostComments(posts[0].id, function(error, comments) {
            if (error) return console.error(error);
            
            console.log('Comments:', comments);
        });
    });
});
```

#### **Repetitive Error Handling**
```javascript
// ❌ Repetitive error handling in each callback
function processData(data, callback) {
    validateData(data, function(error, validatedData) {
        if (error) {
            callback(error);
            return;
        }
        
        transformData(validatedData, function(error, transformedData) {
            if (error) {
                callback(error);
                return;
            }
            
            saveData(transformedData, function(error, savedData) {
                if (error) {
                    callback(error);
                    return;
                }
                
                callback(null, savedData);
            });
        });
    });
}
```

### **4. How Promises Solve These Problems**

#### **Clean Chainable Code**
```javascript
// ✅ Promise chain - Clean and readable
fetchUserDataPromise(123)
    .then(user => {
        console.log('User:', user);
        return fetchUserPostsPromise(user.id);
    })
    .then(posts => {
        console.log('Posts:', posts);
        return fetchPostCommentsPromise(posts[0].id);
    })
    .then(comments => {
        console.log('Comments:', comments);
    })
    .catch(error => {
        console.error('Error in any step:', error);
    });
```

#### **Centralized Error Handling**
```javascript
// ✅ Single error handler for entire chain
fetchUserDataPromise(123)
    .then(user => {
        if (!user) throw new Error('User not found');
        return fetchUserPostsPromise(user.id);
    })
    .then(posts => {
        if (!posts.length) throw new Error('No posts found');
        return fetchPostCommentsPromise(posts[0].id);
    })
    .then(comments => {
        console.log('Comments:', comments);
    })
    .catch(error => {
        // Handles errors from any step in the chain
        console.error('Error:', error.message);
    });
```

#### **Easy Parallel Execution**
```javascript
// ✅ Parallel execution with Promise.all()
Promise.all([
    fetchUserDataPromise(123),
    fetchUserPostsPromise(123),
    fetchUserCommentsPromise(123)
])
.then(([user, posts, comments]) => {
    console.log('All data:', { user, posts, comments });
})
.catch(error => {
    console.error('Error:', error);
});
```

### **5. Modern Async/Await Syntax**

```javascript
// ✅ Async/await - Even cleaner syntax
async function fetchUserDataChain() {
    try {
        const user = await fetchUserDataPromise(123);
        console.log('User:', user);
        
        const posts = await fetchUserPostsPromise(user.id);
        console.log('Posts:', posts);
        
        const comments = await fetchPostCommentsPromise(posts[0].id);
        console.log('Comments:', comments);
        
        return comments;
    } catch (error) {
        console.error('Error:', error);
        throw error;
    }
}
```

---

## **📊 Comparison Summary**

| Aspect | Callbacks | Promises |
|--------|-----------|----------|
| **Readability** | ❌ Poor (Callback Hell) | ✅ Good (Chainable) |
| **Error Handling** | ❌ Repetitive | ✅ Centralized |
| **Parallel Execution** | ❌ Complex | ✅ Simple |
| **Composition** | ❌ Difficult | ✅ Easy |
| **Debugging** | ❌ Hard | ✅ Easier |
| **Async/Await Support** | ❌ No | ✅ Yes |

---

## **🎯 Key Points for Interview**

### **Why Promises are Better:**
1. **Eliminates Callback Hell**: Clean, readable code
2. **Centralized Error Handling**: Single `.catch()` for entire chain
3. **Easy Composition**: Chain multiple operations
4. **Parallel Execution**: Simple with `Promise.all()`
5. **Modern Syntax**: Supports async/await

### **When to Use Each:**
- **Callbacks**: Legacy code, simple async operations, Node.js streams
- **Promises**: Modern JavaScript, complex async flows, API calls
- **Async/Await**: Current best practice, cleaner than promise chains

### **Sample Interview Questions:**
1. "What is callback hell and how do promises solve it?"
2. "How would you convert a callback function to use promises?"
3. "What's the difference between Promise.all() and Promise.race()?"
4. "When would you use async/await vs .then() chains?"

---

*This covers the essential differences between callbacks and promises, focusing on the key problems callbacks create and how promises solve them.*
