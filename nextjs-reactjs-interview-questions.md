# Next.js & React.js Interview Questions

## 📋 Table of Contents

### Next.js Interview Questions
- [What is Next.js?](#what-is-nextjs)
- [Explain the difference between SSR and SSG in Next.js](#explain-the-difference-between-ssr-and-ssg-in-nextjs)
- [What are the different rendering methods in Next.js?](#what-are-the-different-rendering-methods-in-nextjs)
- [Explain Next.js file-based routing](#explain-nextjs-file-based-routing)
- [What are dynamic routes in Next.js?](#what-are-dynamic-routes-in-nextjs)
- [What is the App Router in Next.js 13+?](#what-is-the-app-router-in-nextjs-13)
- [How do you create API routes in Next.js?](#how-do-you-create-api-routes-in-nextjs)
- [What are Route Handlers in Next.js 13+?](#what-are-route-handlers-in-nextjs-13)
- [What styling options does Next.js support?](#what-styling-options-does-nextjs-support)
- [How do you use CSS Modules in Next.js?](#how-do-you-use-css-modules-in-nextjs)
- [What is Image Optimization in Next.js?](#what-is-image-optimization-in-nextjs)
- [Explain Next.js middleware](#explain-nextjs-middleware)

### React.js Interview Questions
- [What is React?](#what-is-react)
- [Explain JSX](#explain-jsx)
- [What are React components?](#what-are-react-components)
- [Explain the difference between state and props](#explain-the-difference-between-state-and-props)
- [What are React hooks?](#what-are-react-hooks)
- [Explain useEffect hook](#explain-useeffect-hook)
- [What are the different useEffect patterns?](#what-are-the-different-useeffect-patterns)
- [Explain React component lifecycle (Class Components)](#explain-react-component-lifecycle-class-components)
- [How do you optimize React performance?](#how-do-you-optimize-react-performance)
- [What is React.lazy and Suspense?](#what-is-reactlazy-and-suspense)
- [What is React Context?](#what-is-react-context)
- [When would you use Redux vs Context?](#when-would-you-use-redux-vs-context)
- [Explain Redux Toolkit](#explain-redux-toolkit)
- [What are React portals?](#what-are-react-portals)
- [Explain React Error Boundaries](#explain-react-error-boundaries)
- [What are React refs?](#what-are-react-refs)

### Practical Coding Questions
- [Create a Next.js page with data fetching](#create-a-nextjs-page-with-data-fetching)
- [Create a Next.js API route with authentication](#create-a-nextjs-api-route-with-authentication)
- [Create a custom hook](#create-a-custom-hook)
- [Create a reusable component](#create-a-reusable-component)
- [Create a form with validation](#create-a-form-with-validation)

### System Design Questions
- [How would you design a real-time chat application?](#how-would-you-design-a-realtime-chat-application)
- [Design a URL shortener service](#design-a-url-shortener-service)

### Behavioral Questions
- [How do you handle technical disagreements with team members?](#how-do-you-handle-technical-disagreements-with-team-members)
- [Describe a challenging bug you've debugged](#describe-a-challenging-bug-youve-debugged)

---

## Next.js Interview Questions

### Basic Concepts

<a id="what-is-nextjs"></a>
1. **What is Next.js?**
   - Next.js is a React framework that provides server-side rendering, static site generation, and other features
   - It's built on top of React and provides additional functionality for production applications

<a id="explain-the-difference-between-ssr-and-ssg-in-nextjs"></a>
2. **Explain the difference between SSR and SSG in Next.js**
   - **SSR (Server-Side Rendering)**: Pages are rendered on the server for each request
   - **SSG (Static Site Generation)**: Pages are pre-rendered at build time
   - **ISR (Incremental Static Regeneration)**: Combines benefits of both

<a id="what-are-the-different-rendering-methods-in-nextjs"></a>
3. **What are the different rendering methods in Next.js?**
   ```javascript
   // Static Generation (default)
   export default function Page() {
     return <h1>Static Page</h1>
   }
   
   // Server-Side Rendering
   export async function getServerSideProps() {
     const data = await fetchData()
     return { props: { data } }
   }
   
   // Static Generation with data
   export async function getStaticProps() {
     const data = await fetchData()
     return { props: { data } }
   }
   ```

### File-based Routing

<a id="explain-nextjs-file-based-routing"></a>
4. **Explain Next.js file-based routing**
   ```
   pages/
   ├── index.js          // / (home page)
   ├── about.js          // /about
   ├── blog/
   │   ├── index.js      // /blog
   │   └── [id].js       // /blog/123, /blog/hello
   └── api/
       └── users.js      // /api/users
   ```

<a id="what-are-dynamic-routes-in-nextjs"></a>
5. **What are dynamic routes in Next.js?**
   ```javascript
   // pages/posts/[id].js
   export default function Post({ post }) {
     return <h1>{post.title}</h1>
   }
   
   export async function getStaticPaths() {
     const paths = [
       { params: { id: '1' } },
       { params: { id: '2' } }
     ]
     return { paths, fallback: false }
   }
   
   export async function getStaticProps({ params }) {
     const post = await getPost(params.id)
     return { props: { post } }
   }
   ```

<a id="what-is-the-app-router-in-nextjs-13"></a>
6. **What is the App Router in Next.js 13+?**
   ```javascript
   // app/page.tsx (App Router)
   export default function Page() {
     return <h1>Hello World</h1>
   }
   
   // app/blog/[slug]/page.tsx
   export default function BlogPost({ params }) {
     return <h1>Blog Post: {params.slug}</h1>
   }
   ```

### API Routes

<a id="how-do-you-create-api-routes-in-nextjs"></a>
7. **How do you create API routes in Next.js?**
   ```javascript
   // pages/api/users.js
   export default function handler(req, res) {
     if (req.method === 'GET') {
       res.status(200).json({ users: [] })
     } else if (req.method === 'POST') {
       // Handle POST request
       res.status(201).json({ message: 'User created' })
     }
   }
   ```

<a id="what-are-route-handlers-in-nextjs-13"></a>
8. **What are Route Handlers in Next.js 13+?**
   ```javascript
   // app/api/users/route.ts
   import { NextRequest, NextResponse } from 'next/server'
   
   export async function GET() {
     return NextResponse.json({ users: [] })
   }
   
   export async function POST(request: NextRequest) {
     const body = await request.json()
     return NextResponse.json({ message: 'User created' }, { status: 201 })
   }
   ```

### Styling & CSS

<a id="what-styling-options-does-nextjs-support"></a>
9. **What styling options does Next.js support?**
   - CSS Modules
   - Sass/SCSS
   - Styled JSX
   - Tailwind CSS
   - CSS-in-JS libraries

<a id="how-do-you-use-css-modules-in-nextjs"></a>
10. **How do you use CSS Modules in Next.js?**
    ```javascript
    // styles/Button.module.css
    .button {
      background: blue;
      color: white;
    }
    
    // components/Button.js
    import styles from '../styles/Button.module.css'
    
    export default function Button() {
      return <button className={styles.button}>Click me</button>
    }
    ```

### Advanced Next.js Features

<a id="what-is-image-optimization-in-nextjs"></a>
11. **What is Image Optimization in Next.js?**
    ```javascript
    import Image from 'next/image'
    
    export default function MyImage() {
      return (
        <Image
          src="/profile.jpg"
          alt="Profile"
          width={500}
          height={300}
          priority
        />
      )
    }
    ```

<a id="explain-nextjs-middleware"></a>
12. **Explain Next.js middleware**
    ```javascript
    // middleware.ts
    import { NextResponse } from 'next/server'
    import type { NextRequest } from 'next/server'
    
    export function middleware(request: NextRequest) {
      const token = request.cookies.get('token')
      
      if (!token && request.nextUrl.pathname.startsWith('/dashboard')) {
        return NextResponse.redirect(new URL('/login', request.url))
      }
      
      return NextResponse.next()
    }
    
    export const config = {
      matcher: '/dashboard/:path*'
    }
    ```

## React.js Interview Questions

### Core Concepts

<a id="what-is-react"></a>
13. **What is React?**
    - React is a JavaScript library for building user interfaces
    - It uses a component-based architecture and virtual DOM
    - Developed by Facebook (Meta)

<a id="explain-jsx"></a>
14. **Explain JSX**
    ```javascript
    // JSX allows you to write HTML-like code in JavaScript
    const element = <h1>Hello, {name}!</h1>
    
    // It gets compiled to:
    const element = React.createElement('h1', null, 'Hello, ', name, '!')
    ```

<a id="what-are-react-components"></a>
15. **What are React components?**
    ```javascript
    // Functional Component
    function Welcome(props) {
      return <h1>Hello, {props.name}</h1>
    }
    
    // Class Component
    class Welcome extends React.Component {
      render() {
        return <h1>Hello, {this.props.name}</h1>
      }
    }
    ```

### State & Props

<a id="explain-the-difference-between-state-and-props"></a>
16. **Explain the difference between state and props**
    - **Props**: Read-only data passed from parent to child
    - **State**: Mutable data managed within a component
    ```javascript
    function Counter() {
      const [count, setCount] = useState(0) // State
      
      return (
        <div>
          <p>Count: {count}</p>
          <button onClick={() => setCount(count + 1)}>
            Increment
          </button>
        </div>
      )
    }
    ```

<a id="what-are-react-hooks"></a>
17. **What are React hooks?**
    ```javascript
    import { useState, useEffect, useContext } from 'react'
    
    function Example() {
      const [count, setCount] = useState(0)
      
      useEffect(() => {
        document.title = `Count: ${count}`
      }, [count])
      
      return <div>{count}</div>
    }
    ```

### Lifecycle & Effects

<a id="explain-useeffect-hook"></a>
18. **Explain useEffect hook**
    ```javascript
    useEffect(() => {
      // Side effect code
      const subscription = subscribe()
      
      // Cleanup function
      return () => {
        subscription.unsubscribe()
      }
    }, [dependency]) // Dependency array
    ```

<a id="what-are-the-different-useeffect-patterns"></a>
19. **What are the different useEffect patterns?**
    ```javascript
    // Run on every render
    useEffect(() => {
      console.log('Every render')
    })
    
    // Run only on mount
    useEffect(() => {
      console.log('Only on mount')
    }, [])
    
    // Run when dependency changes
    useEffect(() => {
      console.log('When count changes')
    }, [count])
    ```

<a id="explain-react-component-lifecycle-class-components"></a>
20. **Explain React component lifecycle (Class Components)**
    ```javascript
    class MyComponent extends React.Component {
      constructor(props) {
        super(props)
        this.state = { count: 0 }
      }
      
      componentDidMount() {
        // Called after component mounts
      }
      
      componentDidUpdate(prevProps, prevState) {
        // Called after component updates
      }
      
      componentWillUnmount() {
        // Called before component unmounts
      }
      
      render() {
        return <div>{this.state.count}</div>
      }
    }
    ```

### Performance

<a id="how-do-you-optimize-react-performance"></a>
21. **How do you optimize React performance?**
    ```javascript
    // React.memo for functional components
    const MemoizedComponent = React.memo(function MyComponent(props) {
      return <div>{props.value}</div>
    })
    
    // useMemo for expensive calculations
    const expensiveValue = useMemo(() => {
      return computeExpensiveValue(a, b)
    }, [a, b])
    
    // useCallback for function memoization
    const memoizedCallback = useCallback(() => {
      doSomething(a, b)
    }, [a, b])
    ```

<a id="what-is-reactlazy-and-suspense"></a>
22. **What is React.lazy and Suspense?**
    ```javascript
    import React, { Suspense } from 'react'
    
    const LazyComponent = React.lazy(() => import('./LazyComponent'))
    
    function App() {
      return (
        <Suspense fallback={<div>Loading...</div>}>
          <LazyComponent />
        </Suspense>
      )
    }
    ```

### Context & State Management

<a id="what-is-react-context"></a>
23. **What is React Context?**
    ```javascript
    const ThemeContext = React.createContext()
    
    function App() {
      return (
        <ThemeContext.Provider value="dark">
          <ThemedButton />
        </ThemeContext.Provider>
      )
    }
    
    function ThemedButton() {
      const theme = useContext(ThemeContext)
      return <button className={theme}>Themed Button</button>
    }
    ```

<a id="when-would-you-use-redux-vs-context"></a>
24. **When would you use Redux vs Context?**
    - **Redux**: Large applications with complex state management
    - **Context**: Simple state sharing between components
    - **Zustand**: Lightweight alternative to Redux

<a id="explain-redux-toolkit"></a>
25. **Explain Redux Toolkit**
    ```javascript
    import { createSlice } from '@reduxjs/toolkit'
    
    const counterSlice = createSlice({
      name: 'counter',
      initialState: { value: 0 },
      reducers: {
        increment: (state) => {
          state.value += 1
        },
        decrement: (state) => {
          state.value -= 1
        }
      }
    })
    
    export const { increment, decrement } = counterSlice.actions
    export default counterSlice.reducer
    ```

### Advanced Topics

<a id="what-are-react-portals"></a>
26. **What are React portals?**
    ```javascript
    import { createPortal } from 'react-dom'
    
    function Modal({ children }) {
      return createPortal(
        <div className="modal">{children}</div>,
        document.getElementById('modal-root')
      )
    }
    ```

<a id="explain-react-error-boundaries"></a>
27. **Explain React Error Boundaries**
    ```javascript
    class ErrorBoundary extends React.Component {
      constructor(props) {
        super(props)
        this.state = { hasError: false }
      }
      
      static getDerivedStateFromError(error) {
        return { hasError: true }
      }
      
      componentDidCatch(error, errorInfo) {
        console.log(error, errorInfo)
      }
      
      render() {
        if (this.state.hasError) {
          return <h1>Something went wrong.</h1>
        }
        
        return this.props.children
      }
    }
    ```

<a id="what-are-react-refs"></a>
28. **What are React refs?**
    ```javascript
    function TextInputWithFocusButton() {
      const inputRef = useRef(null)
      
      const onButtonClick = () => {
        inputRef.current.focus()
      }
      
      return (
        <>
          <input ref={inputRef} type="text" />
          <button onClick={onButtonClick}>Focus the input</button>
        </>
      )
    }
    ```

## Practical Coding Questions

### Next.js

<a id="create-a-nextjs-page-with-data-fetching"></a>
29. **Create a Next.js page with data fetching**
    ```javascript
    // pages/posts/[id].js
    export default function Post({ post }) {
      return (
        <article>
          <h1>{post.title}</h1>
          <p>{post.content}</p>
        </article>
      )
    }
    
    export async function getStaticPaths() {
      const posts = await getPosts()
      const paths = posts.map((post) => ({
        params: { id: post.id.toString() }
      }))
      
      return { paths, fallback: false }
    }
    
    export async function getStaticProps({ params }) {
      const post = await getPost(params.id)
      return { props: { post } }
    }
    ```

<a id="create-a-nextjs-api-route-with-authentication"></a>
30. **Create a Next.js API route with authentication**
    ```javascript
    // pages/api/protected.js
    import { verifyToken } from '../../lib/auth'
    
    export default async function handler(req, res) {
      if (req.method !== 'GET') {
        return res.status(405).json({ message: 'Method not allowed' })
      }
      
      try {
        const token = req.headers.authorization?.replace('Bearer ', '')
        const user = await verifyToken(token)
        
        res.status(200).json({ data: 'Protected data', user })
      } catch (error) {
        res.status(401).json({ message: 'Unauthorized' })
      }
    }
    ```

### React

<a id="create-a-custom-hook"></a>
31. **Create a custom hook**
    ```javascript
    function useLocalStorage(key, initialValue) {
      const [storedValue, setStoredValue] = useState(() => {
        try {
          const item = window.localStorage.getItem(key)
          return item ? JSON.parse(item) : initialValue
        } catch (error) {
          return initialValue
        }
      })
      
      const setValue = value => {
        try {
          setStoredValue(value)
          window.localStorage.setItem(key, JSON.stringify(value))
        } catch (error) {
          console.log(error)
        }
      }
      
      return [storedValue, setValue]
    }
    ```

<a id="create-a-reusable-component"></a>
32. **Create a reusable component**
    ```javascript
    function Button({ children, variant = 'primary', size = 'medium', ...props }) {
      const baseClasses = 'px-4 py-2 rounded font-medium transition-colors'
      const variants = {
        primary: 'bg-blue-500 text-white hover:bg-blue-600',
        secondary: 'bg-gray-200 text-gray-800 hover:bg-gray-300'
      }
      const sizes = {
        small: 'px-2 py-1 text-sm',
        medium: 'px-4 py-2',
        large: 'px-6 py-3 text-lg'
      }
      
      return (
        <button
          className={`${baseClasses} ${variants[variant]} ${sizes[size]}`}
          {...props}
        >
          {children}
        </button>
      )
    }
    ```

<a id="create-a-form-with-validation"></a>
33. **Create a form with validation**
    ```javascript
    function ContactForm() {
      const [formData, setFormData] = useState({
        name: '',
        email: '',
        message: ''
      })
      const [errors, setErrors] = useState({})
      
      const validate = () => {
        const newErrors = {}
        if (!formData.name) newErrors.name = 'Name is required'
        if (!formData.email) newErrors.email = 'Email is required'
        if (!formData.message) newErrors.message = 'Message is required'
        return newErrors
      }
      
      const handleSubmit = (e) => {
        e.preventDefault()
        const newErrors = validate()
        if (Object.keys(newErrors).length === 0) {
          // Submit form
          console.log('Form submitted:', formData)
        } else {
          setErrors(newErrors)
        }
      }
      
      return (
        <form onSubmit={handleSubmit}>
          <input
            type="text"
            value={formData.name}
            onChange={(e) => setFormData({...formData, name: e.target.value})}
            placeholder="Name"
          />
          {errors.name && <span>{errors.name}</span>}
          {/* Similar for email and message */}
          <button type="submit">Submit</button>
        </form>
      )
    }
    ```

## System Design Questions

<a id="how-would-you-design-a-realtime-chat-application"></a>
34. **How would you design a real-time chat application?**
    - WebSocket connections for real-time communication
    - Redis for session management and caching
    - PostgreSQL for message persistence
    - Load balancers for scaling

<a id="design-a-url-shortener-service"></a>
35. **Design a URL shortener service**
    - Hash function to generate short URLs
    - Database to store mappings
    - Cache frequently accessed URLs
    - Analytics tracking

## Behavioral Questions

<a id="how-do-you-handle-technical-disagreements-with-team-members"></a>
36. **How do you handle technical disagreements with team members?**
    - Focus on data and evidence
    - Consider multiple perspectives
    - Be open to changing your mind
    - Document decisions and rationale

<a id="describe-a-challenging-bug-youve-debugged"></a>
37. **Describe a challenging bug you've debugged**
    - Explain your debugging process
    - Show systematic thinking
    - Demonstrate persistence and problem-solving skills

## Tips for Interview Success

- Practice coding on a whiteboard or in a simple text editor
- Think out loud while solving problems
- Ask clarifying questions before starting
- Consider edge cases and error handling
- Be honest about what you don't know
- Show enthusiasm for learning and growth
- Understand React's virtual DOM and reconciliation
- Know the differences between Next.js and Create React App
- Practice writing clean, readable code
- Understand modern React patterns (hooks, functional components)
