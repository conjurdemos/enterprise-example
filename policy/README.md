##Organizing Policies

1. All policies live in the 'policies' directory
2. Workflows are a collection of policies.
3. Policies can be scoped to just about anything -- use cases, applications, jobs, services, hosts, workflows, layers, etc.

![policy info arch](https://raw.githubusercontent.com/conjurdemos/enterprise-example/ee-policy-tax/policy/policy-ia.png =200)

##Policy Naming Conventions

1. Avoid extra long folder names and complex hierarchical structures.
2. Use the underscore ( _ ) as element delimiter.
3. Elements should be ordered from general to specific detail of importance as much as possible.
4. Dates should be ordered: YEAR, MONTH, DAY. (e.g. YYYYMMDD, YYYYMMDD, YYYYMM). 
