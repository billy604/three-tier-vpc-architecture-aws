# Security Group Matrix — Three-Tier VPC Architecture

| Source | Destination | Port | Protocol | Purpose |
|---|---|---|---|---|
| Internet (0.0.0.0/0) | ALB Security Group | 80 | TCP | Public HTTPS/HTTP entry point |
| ALB Security Group | App Security Group | 80 | TCP | Load balancer forwards to app tier |
| App Security Group | DB Security Group | 5432 | TCP | App tier queries the PostgreSQL database |
| — | App / DB Security Groups | 22 | TCP | **Closed.** No SSH access; use AWS Systems Manager Session Manager for admin access instead |

## Design Principle

Each tier's security group only trusts traffic from the *security group* of the tier directly above it in the request path — never a raw IP range, and never "the whole VPC." This means:

- The App tier is unreachable from the internet, even though it lives in the same VPC as the ALB.
- The DB tier is unreachable from anything except instances wearing the App security group — not even the ALB can reach it directly.
- If an attacker somehow gained a foothold in the App tier, the DB tier's blast radius is still contained to exactly what the App tier's security group is permitted to do.

This is "defense in depth" — the private subnet placement *and* the security group rules independently enforce the same boundary, so a misconfiguration in one layer doesn't automatically compromise the other.