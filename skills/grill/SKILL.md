# Grill — Design Interrogation

Before implementing anything non-trivial, interview the user relentlessly about every aspect of their idea until you reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one by one. If a question can be answered by exploring the codebase, explore the codebase instead of asking.

**Oracle integration:** Before starting the interview, check the project's PJL frontmatter for `oracles:`. If an oracle exists, query it for the domain being grilled: "What are the industry standards and established patterns for {topic}?" Use the oracle's response as an external pressure dimension during the interview. For each major design decision, check whether the user's approach aligns with or departs from what the oracle reports. Surface departures as questions: "The oracle notes that most {domain} systems use {pattern}, but you're proposing {alternative}. Is this an intentional departure?" See [[SD - Oracle System]].

One question at a time. Adapt based on answers. Do not propose a solution until the interview is complete.
