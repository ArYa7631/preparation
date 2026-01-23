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


### How do you connect the Salesforce platform to Highspot via the Ecosystem project?

**Question (as asked in interview)**: How can we add/connect the Salesforce platform to our Highspot account via the Ecosystem project?

**Answer (short version)**:  
In Ecosystem, we expose Salesforce as an integration that an admin can connect from Highspot. From the UI, the admin goes to the integrations/Ecosystem area, selects Salesforce, and completes an OAuth flow where they log in to Salesforce and approve the Highspot app. On the backend, the Ecosystem service stores the Salesforce org details and OAuth tokens securely and links them to the Highspot account. Once connected, Ecosystem syncs objects (like accounts, opportunities, and activities) and surfaces Highspot content inside Salesforce using embedded components, so reps can see and use Highspot content directly in Salesforce without leaving their normal workflow.

**Answer (slightly more detailed breakdown)**:
- **1. Discoverability & configuration in Highspot**: Salesforce appears as a configurable integration in the Ecosystem/Integrations UI. Admins can choose which Salesforce org to connect and what permissions/scopes are needed.
- **2. OAuth-based connection**: When the admin clicks “Connect Salesforce”, we redirect them to Salesforce’s OAuth screen. After they approve, Salesforce sends an authorization code back to Ecosystem, which we exchange for access/refresh tokens and store securely.
- **3. Account-level linkage**: Those tokens and org identifiers are associated with the specific Highspot account/tenant so that only that customer’s users can use the integration.
- **4. Data sync & mappings**: Ecosystem configures which Salesforce objects/fields are synced (e.g., opportunities, activities) and how they map to Highspot entities (content engagement, pitches, etc.).
- **5. Embedded experience in Salesforce**: Using Salesforce components (like Lightning components/Visualforce/Canvas), Ecosystem surfaces Highspot UI inside Salesforce pages so reps can search, preview, and attach Highspot content without leaving Salesforce.
- **6. Ongoing maintenance**: Tokens are refreshed automatically, errors are logged/monitored, and admins can disconnect or reconfigure the integration from the Ecosystem settings screen.


### Most typical work on the highspot project for FrontEnd
One of the most typical but also challenging frontend tasks I worked on was in the Ecosystem project. Earlier, in our project, most of the UI components we used—like cards, buttons, dropdowns, inputs—were either React’s default components or from some popular React-based libraries.

But then I got a ticket where the requirement was to stop using those and instead replace them with Highspot’s own design system, called Polar. So the first step was to install the Polar package and then slowly start migrating components. For example, wherever we had a React dropdown, I had to replace it with Polar’s dropdown. Same with cards, inputs, and other UI elements.

The tricky part was that Polar components don’t work in the exact same way as React’s. They have their own props and data structures, so I had to carefully read the documentation and Confluence pages to understand what props were required for specific styles.

Also, to be safe, we kept everything behind a feature flag so that only specific users could see the Polar components while we tested. Sometimes, this migration wasn’t just on the frontend—because the Polar component needed data in a certain format, I also had to make changes in multiple pages and even adjust the backend response in some cases.

It was quite a lengthy task because I had to ensure the flow didn’t break anywhere, and after each replacement I had to thoroughly test using React Testing Library and TestCafe. In the end, it was a great learning experience because I not only understood how to integrate a custom design system but also how to manage such a big UI migration smoothly without impacting users.


### Most typical work on the highspot project for Backend
**"On the backend side with Ruby on Rails, one of the most challenging tasks I worked on in the Ecosystem project was around feature flags and licensing.

Earlier, many of our functionalities were controlled through feature flags. So, if an admin turned a flag on in the Ecosystem panel, the users would get access to that specific feature. But as per a new requirement, we had to move away from feature flags and instead tie those functionalities to licenses.

That meant, instead of checking whether a feature flag was enabled, now we had to check whether the user's account had the correct license. If they had that license, only then they would get access to those features.

One specific example that comes to mind was when I had to remove the `multi_sfdc_support` feature flag and replace it with a license-based check. This was actually a pretty interesting refactoring because it wasn't just about finding and replacing — I had to understand how our licensing system worked and properly integrate this feature into it.

So, the first thing I did was figure out which license SKU should control this feature. After discussing with the team, we decided it should be tied to the 'platform+' SKU, which made sense because multi-Salesforce support is a premium platform-level feature.

Then, I needed to properly register this feature in our domain add-ons system. I started by adding a new constant called `MULTI_SFDC` in the `Hspt::Rights::Domain` module. This constant would serve as the identifier for this feature across the codebase.

Next, I created a new `MultiSFDC` class in the `DomainAddons::Features` module. This class was responsible for defining how the feature authorization works — basically, it checks if an account has the platform+ SKU. I implemented this under the platform-specific path at `web/common/licenses/domain_addons/features/platform/`, which kept it organized with other platform-level features.

After that, I had to register this new feature in the `DomainAddons::Platform` class so the system would recognize it as a valid domain add-on feature. This was important because the registration is what connects everything together and makes the authorization checks work properly.

Now came the actual replacement work. I had to find every single place in the codebase where we were checking for `multi_sfdc_support` feature flag — and there were quite a few of them across different controllers, services, and views. In each of those places, I replaced the old feature flag check with a new method call: `domain.is_addon_feature_authorized?(current_account, Hspt::Rights::Domain::MULTI_SFDC, nil)`. This new check looks at the account's license instead of a feature flag.

The tricky part was making sure I didn't miss any edge cases. Some places had conditional logic around the feature flag that needed to be preserved, and sometimes the feature flag check was nested inside other conditions. I had to carefully review each replacement to ensure the logic flow remained correct.

After all the replacements, I went through a thorough testing process. I tested with accounts that had the platform+ license, accounts that didn't, and made sure the feature behaved exactly as it did before but now controlled by licenses. I also ran our full test suite to catch any regressions.

This change wasn't small — it touched multiple files across the codebase. But in the end, it really cleaned up the code and made the licensing system much more structured and maintainable. Instead of having feature flags scattered around that admins had to manually manage, everything is now tied to the licenses that customers purchase, which makes much more sense from both a business and technical perspective.

For me, it was a great learning experience in handling large-scale refactoring across multiple files while ensuring stability. I also got a deep understanding of how our domain add-ons and licensing architecture works, which has been really valuable for other projects."**


### How does a user get the license in Ecosystem?
**“In the Ecosystem project, licenses are managed at the account level. Basically, a company or organization that uses Highspot purchases a license package, and that license defines what set of features their users can access.

When the admin of that account assigns the license, it gets stored in our backend system. So whenever a user logs in, we check their account details and see which license they have. Based on that license, we decide which features should be available to them.

So instead of manually enabling features through a feature flag, it's all automated through the license system—much cleaner and easier to manage at scale."**

## Previous Work Experience

### Panther
**Role:** Full Stack Developer

**Description:**
Panther is a white-label marketplace platform that enables businesses to launch expert-based consulting or service platforms quickly. It includes features like user onboarding, scheduling, chat/call support, and secure payments. The platform allows full branding customization and helps companies build scalable service marketplaces without heavy development effort.

**Responsibilities:**
- Built a scalable SaaS platform enabling real-time virtual consultations for 50K+ active users
- Integrated Stripe for secure global payments with failover and webhook-based reconciliation
- Implemented AWS S3 for image hosting and optimized SEO for higher organic traffic
- Enhanced automation test coverage using AI-generated Jest test cases
- Focused on AI-based security improvements for transactional workflows

**Technologies Used:** Ruby on Rails, RSpec, React.js, TypeScript, Jest, ChatGPT, GitHub Copilot, AWS S3, Stripe

### Tiger
**Role:** Full Stack Developer

**Description:**
Tiger is a customizable community and networking platform by JungleWorks that enables businesses to build niche community portals, membership networks, and knowledge-sharing ecosystems. It supports role-based access, content sharing, discussions, and monetization through subscriptions or premium features. The platform helps organizations create private branded communities without building from scratch.

**Responsibilities:**
- Integrated Fugu chatbot for automated customer engagement and real-time user support
- Implemented course listing and purchasing modules, including payment flow integration and user access management

**Technologies Used:** Ruby on Rails, React.js, AWS S3, Stripe

### Startup Network
**Role:** Back-End Developer

**Description:**
Startup Network is a platform designed to connect entrepreneurs, investors, mentors, and service providers within a unified ecosystem. It helps early-stage startups gain visibility, access to funding opportunities, and mentorship while enabling investors to discover high-potential ventures. The platform facilitates networking, pitch evaluations, and community-driven growth for emerging founders.

**Responsibilities:**
- Developed a real-time investment matchmaking system connecting VCs and startup founders
- Implemented AWS S3-based storage for media assets and optimized SEO for public listings
- Built server-side logic in Ruby on Rails with search indexing powered by Search Sphinx
- Contributed to backend performance improvements and API response optimization

**Technologies Used:** Ruby on Rails, RSpec, Search Sphinx, AWS S3

### Yelo Web App
**Role:** (Intern + Back-End Developer)

**Description:** 
Yelo is a no-code marketplace platform by JungleWorks that allows businesses to launch hyperlocal marketplaces such as food delivery, grocery, home services, or rental platforms. It provides storefront creation, vendor onboarding, catalog management, order tracking, and payment integrations out of the box. The platform enables quick go-to-market with full branding customization and scalability.

**Responsibilities:**
- Developed a multi-industry online ordering and delivery platform
- Integrated Stripe payment gateways for subscription and transaction-based billing
- Implemented backend business logic and REST APIs for core commerce features

**Technologies Used:** Ruby on Rails, Stripe

### AryaSoftwareTech 2.0 (Personal Project)
**Role:** Full Stack Developer

**Description:**
AryaSoftwareTech 2.0 is a multi-tenant SaaS website builder that lets users launch branded websites with custom domains and automated SSL. It features a visual page builder, JWT-based authentication, role-based access, dynamic domain routing, and cloud storage via AWS S3 for scalable deployments.

**Responsibilities:**
- Multi-tenant SaaS platform with custom domain support and automated SSL
- Architected multi-tenant PostgreSQL system with dynamic domain routing
- Built visual page builder with 8+ sections and real-time updates
- Implemented JWT auth, RBAC, and AWS S3 file storage
- Deployed with Docker, Nginx, and automated SSL (Let's Encrypt)

**Technologies Used:** Ruby on Rails, React.js, PostgreSQL, AWS S3, Docker, Nginx, JWT