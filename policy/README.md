##Policy Repo Structure

1. All policies live in the 'policies' directory
2. Workflows are a collection of policies.
3. Policies can be scoped to just about anything -- use cases, applications, jobs, services, hosts, workflows, layers, etc.

##Policy Naming Conventions

1. Avoid extra long folder names and complex hierarchical structures but use information-rich filenames instead.
2. Put sufficient elements in the structure for easy retrieval and identification but do not overdo it.
3. Use the underscore (_) as element delimiter. Do not use spaces or other characters such as: ! # $ % & ' @ ^ ` ~ + , . ; = ) (
4. Use the hyphen (-) to delimit words within an element or capitalize the first letter of each word within an element.
5. Elements should be ordered from general to specific detail of importance as much as possible.
6. The order of importance rule holds true when elements include date and time stamps. Dates should be ordered: YEAR, MONTH, DAY. (e.g. YYYYMMDD, YYYYMMDD, YYYYMM). Time should be ordered: HOUR, MINUTES, SECONDS (HHMMSS).
7. Personal names within an element should have family name first followed by first names or initials.
8. Abbreviate the content of elements whenever possible.