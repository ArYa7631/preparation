# Interview Introduction

## Personal Introduction

### About Me
Yeah, thank you for giving me the opportunity to introduce myself.
So, I am Nitesh Arya and I am currently working as a Lead Engineer at HCLTech. I have around 6 years of experience in software development.

I started my career as a Backend developer, mainly working with Ruby on Rails. But over time, I got more into frontend work as well, and for the last 4 and a half years, I’ve been working as a full-stack developer. Overall, I have about 6 years of experience in Ruby on Rails and around 4 years in React.js. 

I have done my bachelor’s degree from SVIET College which is in Chandigarh. I got placed in Jungleworks from there, where I first started as an intern and later got a full-time role. At Jungleworks, I mainly worked on Marketplace SaaS platforms. In some projects, I got the chance to handle things end-to-end — both frontend and backend — and in some cases, I also worked from scratch. That was a great learning phase for me.

After that, I joined HCLTech as a Lead Engineer. Here I have been working on the Highspot project, which is a sales enablement platform. It has multiple microservice projects, and I mainly worked on one of them called Ecosystem.
This platform connects millions of users — around 20 million globally — including sales reps, partners, and customers

In this project, I work with React.js, Next.js, and Ruby on Rails. I’m very much involved in creating and updating features, handling both frontend and backend work. Along with that, testing is also a big part of my role — we use React Testing Library for frontend, RSpec for backend, and TestCafe for end-to-end automation.

Along with development, I also contribute in code reviews, mentoring junior developers, and making sure the team follows best practices.
Outside of my day-to-day work, I like to stay updated with new technologies, especially around React.js and Ruby on Rails. I also like to explore AI-powered tools like Cursor AI which help developers learn faster and write code better.

And lastly, I would say I really love problem solving — whether it’s coding, debugging, or figuring out a new approach, that’s something I enjoy a lot.


### Professional Summary
I'm a Lead Engineer with 6+ years of experience in React.js and 4.5+ years in Ruby on Rails, currently working at HCLTech. I'm passionate about building scalable applications, optimizing performance, and mentoring other developers. My expertise lies in full-stack development, testing strategies, and creating solutions that drive real business value.

## Highspot Project Description
Highspot is basically a sales enablement platform — it helps sales and marketing teams keep all their content, training, and buyer engagement in one place.

In this project, I mainly worked on a microservice called Ecosystem. You can think of it like a bridge that connects Highspot with other tools that companies already use. A very common one is Salesforce.

Now, most sales reps spend their whole day inside Salesforce — updating leads, checking opportunities, things like that. Without Ecosystem, if they wanted to use Highspot content, they’d have to leave Salesforce, go into Highspot, search for what they need, and then bring it back. That’s extra work and slows them down.

Ecosystem makes this easier. It brings Highspot features right inside Salesforce. So while the rep is working in Salesforce, they can directly see the right presentations, product sheets, or training material from Highspot without switching tabs. It feels smooth, like everything is in one place.


### Most typical work on the highspot project for FrontEnd
One of the most typical but also challenging frontend tasks I worked on was in the Ecosystem project. Earlier, in our project, most of the UI components we used—like cards, buttons, dropdowns, inputs—were either React’s default components or from some popular React-based libraries.

But then I got a ticket where the requirement was to stop using those and instead replace them with Highspot’s own design system, called Polar. So the first step was to install the Polar package and then slowly start migrating components. For example, wherever we had a React dropdown, I had to replace it with Polar’s dropdown. Same with cards, inputs, and other UI elements.

The tricky part was that Polar components don’t work in the exact same way as React’s. They have their own props and data structures, so I had to carefully read the documentation and Confluence pages to understand what props were required for specific styles.

Also, to be safe, we kept everything behind a feature flag so that only specific users could see the Polar components while we tested. Sometimes, this migration wasn’t just on the frontend—because the Polar component needed data in a certain format, I also had to make changes in multiple pages and even adjust the backend response in some cases.

It was quite a lengthy task because I had to ensure the flow didn’t break anywhere, and after each replacement I had to thoroughly test using React Testing Library and TestCafe. In the end, it was a great learning experience because I not only understood how to integrate a custom design system but also how to manage such a big UI migration smoothly without impacting users.


### Most typical work on the highspot project for Backend
**“On the backend side with Ruby on Rails, one of the most challenging tasks I worked on in the Ecosystem project was around feature flags and licensing.

Earlier, many of our functionalities were controlled through feature flags. So, if an admin turned a flag on in the Ecosystem panel, the users would get access to that specific feature. But as per a new requirement, we had to move away from feature flags and instead tie those functionalities to licenses.

That meant, instead of checking whether a feature flag was enabled, now we had to check whether the user’s account had the correct license. If they had that license, only then they would get access to those features.

This change wasn’t small because the feature flags were already being used in multiple places across the codebase. So I had to go through many files, remove the old flag checks, and replace them with license checks. Along the way, I had to make sure that nothing else broke and that the features still worked smoothly.

It was a big refactor, but in the end it really cleaned up the code and made the licensing system much more structured. For me, it was a good learning experience in handling large-scale changes across multiple files while ensuring stability.”**


### How does a user get the license in Ecosystem?
**“In the Ecosystem project, licenses are managed at the account level. Basically, a company or organization that uses Highspot purchases a license package, and that license defines what set of features their users can access.

When the admin of that account assigns the license, it gets stored in our backend system. So whenever a user logs in, we check their account details and see which license they have. Based on that license, we decide which features should be available to them.

So instead of manually enabling features through a feature flag, it’s all automated through the license system—much cleaner and easier to manage at scale.”**