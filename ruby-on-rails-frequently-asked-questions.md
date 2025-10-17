# Ruby on Rails - Most Frequently Asked Interview Questions

## Table of Contents

### 🔥 **TOP 50 MOST FREQUENTLY ASKED QUESTIONS**

#### **Basic Rails Concepts (Questions 1-15)**
1. [What is Ruby on Rails?](ruby-on-rails-interview-questions.md#what-is-ruby-on-rails)
2. [Explain the MVC pattern in Rails](ruby-on-rails-interview-questions.md#explain-the-mvc-pattern-in-rails)
3. [What are Rails conventions?](ruby-on-rails-interview-questions.md#what-are-the-rails-conventions)
4. [What is ActiveRecord?](ruby-on-rails-interview-questions.md#what-is-activerecord)
5. [Explain Rails associations](ruby-on-rails-interview-questions.md#explain-rails-associations)
6. [What are Rails validations?](ruby-on-rails-interview-questions.md#what-are-rails-validations)
7. [Explain Rails callbacks](ruby-on-rails-interview-questions.md#explain-rails-callbacks)
8. [Explain Rails routing](ruby-on-rails-interview-questions.md#explain-rails-routing)
9. [What are strong parameters?](ruby-on-rails-interview-questions.md#what-are-strong-parameters)
10. [What are Rails migrations?](ruby-on-rails-interview-questions.md#what-are-rails-migrations)
11. [What are Rails scopes?](ruby-on-rails-interview-questions.md#what-are-rails-scopes)
12. [What is Rack in Rails?](ruby-on-rails-interview-questions.md#what-is-rack-in-rails)
13. [What are Rails gems?](ruby-on-rails-interview-questions.md#what-are-rails-gems)
14. [What are Rails concerns?](ruby-on-rails-interview-questions.md#what-are-rails-concerns)
15. [How does caching work in Ruby on Rails?](ruby-on-rails-interview-questions.md#how-does-caching-work-in-ruby-on-rails)

#### **ActiveRecord & Database (Questions 16-25)**
16. [What is the N+1 query problem?](ruby-on-rails-interview-questions.md#what-is-the-n1-query-problem)
17. [How do you solve N+1 queries?](ruby-on-rails-interview-questions.md#how-do-you-solve-n1-queries)
18. [Explain eager loading vs lazy loading](core-concepts-part-1.md#eager-loading-vs-lazy-loading)
19. [What are database transactions?](ruby-on-rails-interview-questions.md#what-are-database-transactions)
20. [Explain polymorphic associations](core-concepts-part-1.md#polymorphic-association)
21. [What is Single Table Inheritance (STI)?](core-concepts-part-2.md#single-table-inheritance)
22. [Explain self joins](ruby-on-rails-activerecord-interview-questions.md#self-joins)
23. [What are Rails scopes vs class methods?](ruby-on-rails-advanced-interview-questions.md#what-are-rails-scopes-vs-class-methods)
24. [How do you find duplicate records?](ruby-on-rails-activerecord-interview-questions.md#find-duplicate-records)
25. [How do you find the nth highest salary?](ruby-on-rails-activerecord-interview-questions.md#find-nth-highest-salary)

#### **Ruby Fundamentals (Questions 26-35)**
26. [What is self in Ruby?](core-concepts-part-2.md#self-in-ruby)
27. [Explain include vs extend](core-concepts-part-1.md#include-vs-extends)
28. [What is mixing in Ruby?](core-concepts-part-2.md#mixing-in-ruby)
29. [Explain blocks, procs, and lambdas](core-concepts-part-3.md#block-proc-lambda)
30. [What is the difference between strings and symbols?](core-concepts-part-3.md#string-vs-symbol)
31. [Explain OOP concepts in Ruby](core-concepts-part-2.md#oops-concepts)
32. [What is the difference between require and load?](core-concepts-part-1.md#require-vs-load)
33. [Explain access control (private, protected, public)](core-concepts-part-3.md#access-control)
34. [What is the difference between select, collect, and map?](core-concepts-part-3.md#select-collect-map-difference)
35. [Explain module vs class](core-concepts-part-3.md#module-vs-class)

#### **Security & Performance (Questions 36-45)**
36. [What are common Rails security concerns?](ruby-on-rails-advanced-interview-questions.md#explain-rails-security-best-practices-in-detail)
37. [How do you prevent SQL injection?](ruby-on-rails-advanced-interview-questions.md#explain-rails-security-best-practices-in-detail)
38. [How do you prevent XSS attacks?](ruby-on-rails-advanced-interview-questions.md#explain-rails-security-best-practices-in-detail)
39. [How do you optimize Rails performance?](ruby-on-rails-advanced-interview-questions.md#explain-rails-performance-optimization-in-detail)
40. [How do you handle background jobs?](ruby-on-rails-advanced-interview-questions.md#explain-rails-background-job-processing)
41. [What is Sidekiq?](ruby-on-rails-advanced-interview-questions.md#what-is-sidekiq)
42. [How do you implement authentication?](ruby-on-rails-advanced-interview-questions.md#explain-rails-security-best-practices-in-detail)
43. [How do you implement authorization?](ruby-on-rails-advanced-interview-questions.md#explain-rails-security-best-practices-in-detail)
44. [What are Rails security best practices?](ruby-on-rails-advanced-interview-questions.md#explain-rails-security-best-practices-in-detail)

#### **Advanced Topics (Questions 46-50)**
46. [What are Rails engines?](ruby-on-rails-advanced-interview-questions.md#what-are-rails-engines)
47. [Explain Rails API design patterns](ruby-on-rails-advanced-interview-questions.md#explain-rails-api-design-patterns)
48. [What are Rails testing strategies?](ruby-on-rails-advanced-interview-questions.md#explain-rails-testing-strategies)
49. [How do you deploy Rails applications?](ruby-on-rails-advanced-interview-questions.md#explain-rails-deployment-and-devops)
50. [What are Rails architectural patterns?](ruby-on-rails-advanced-interview-questions.md#explain-rails-application-architecture-patterns)

---

## **🎯 Quick Reference Guide**

### **Most Critical Topics to Master:**
1. **MVC Pattern** - Core Rails architecture
2. **ActiveRecord Associations** - Database relationships
3. **N+1 Query Problem** - Performance optimization
4. **Strong Parameters** - Security fundamentals
5. **Rails Routing** - URL mapping
6. **Validations & Callbacks** - Data integrity
7. **Rails Security** - XSS, CSRF, SQL injection
8. **Caching Strategies** - Performance optimization
9. **Background Jobs** - Async processing
10. **Testing** - RSpec, FactoryBot

### **Interview Preparation Tips:**
- Practice writing Rails code without IDE
- Understand ActiveRecord query generation
- Know common gems and their purposes
- Be familiar with Rails conventions
- Practice explaining concepts clearly
- Show enthusiasm for learning and growth

---

## **📁 Related Files for Detailed Answers:**

- **[Main Rails Interview Questions](ruby-on-rails-interview-questions.md)** - Comprehensive Rails questions with detailed answers (Questions 1-15, 16-17, 19)
- **[Advanced Rails Questions](ruby-on-rails-advanced-interview-questions.md)** - Senior-level Rails concepts and architecture patterns
- **[Core Ruby & Rails Concepts - Part 1](core-concepts-part-1.md)** - Routing, basics, associations (Questions 18, 20, 27, 32)
- **[Core Ruby & Rails Concepts - Part 2](core-concepts-part-2.md)** - Architecture, OOP, modules (Questions 21, 26, 28, 31)
- **[Core Ruby & Rails Concepts - Part 3](core-concepts-part-3.md)** - Advanced patterns, data types (Questions 29, 30, 33-35)
- **[ActiveRecord Questions](ruby-on-rails-activerecord-interview-questions.md)** - Database query problems and specific ActiveRecord challenges (Questions 22, 24-25)
- **[Additional Concepts](ruby-on-rails-additional-concepts-interview-questions.md)** - Extra Rails concepts and patterns
- **[Situation-Based Questions](ruby-on-rails-situation-based-interview-questions.md)** - Real-world scenario questions

---

**💡 Pro Tip**: Use this file as your master reference. Each question links to the specific file and section where you can find the detailed answer. This approach helps you quickly locate information during interview preparation and demonstrates organized knowledge of Rails concepts.
