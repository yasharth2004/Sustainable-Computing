# Circular Campus

Circular Campus is an offline-first campus resource-sharing ecosystem for Indian college communities. It prioritizes borrowing, lending, sharing and donations over buying and selling.

## Objectives and Sustainable Computing relevance

The application makes underused campus resources discoverable, extends product lifecycles, records verified reuse activity and supports student-led donation drives. It demonstrates sustainable software design through a lightweight, dependency-free frontend, local persistence and transparent activity metrics rather than fabricated environmental claims.

## Technology and architecture

- HTML5, CSS3 and vanilla ES modules
- LocalStorage persistence with a versioned `circular-campus-v1` document
- Hash router for the single-page experience
- `js/database.js` owns persistence; managers encapsulate resources, campaigns and sustainability rules
- `js/supabase-client.js` is a native-fetch Supabase client with session-only configuration and auth sessions; `js/cloud-data.js` contains REST data operations. `supabase/schema.sql` is the PostgreSQL/Supabase schema.

## Structure

`index.html` is the semantic shell. `css/` contains the responsive visual system. `js/` contains constants, seed data, persistence, domain managers, sustainability calculations, routing and UI composition. `assets/illustrations.js` supplies offline inline-safe category illustrations. `supabase/schema.sql` contains tables, constraints, indexes and RLS enablement.

## Implemented modules

Home overview, resource search and filters, resource details and favorites, resource listing and management, borrowing request/approval/rejection/return-request workflow, donation campaigns and contribution pledges, lifecycle timeline, sustainability dashboard, demo user switching, eco points, badges, leaderboard and reset demo data.

## Demo data

The first load seeds 8 users, 16 resources, 8 borrowing records, 4 campaigns, 6 campaign contributions and lifecycle events for all resources. Points are stored as unique transactions to prevent duplicates. The original seed intentionally starts with a clean points ledger so actions performed during the demo are easy to verify.

## Run

Open `index.html` directly in a modern browser, or serve the folder with any static server (for example `python3 -m http.server`). Switch the demo identity in the left navigation. Use **Reset demo data** in the top bar or dashboard to restore the seed.

To connect Supabase, use **Connect Backend** in the footer and enter the project URL plus anon/publishable key. The values are stored only in `sessionStorage` under `circular_campus_config`; never enter a service-role key. The Account button provides login and registration through `/auth/v1`. The schema must be applied in the Supabase SQL editor before REST resource operations can succeed. Cloud REST methods are implemented in `js/cloud-data.js`; the stable LocalStorage demo remains the default when no backend is configured.

## Validation

Run `node --check js/<file>.js` for each JavaScript module. For local browser verification, exercise every navigation link, create a resource, filter resources, save a resource, submit and approve a borrow request, join a campaign, switch identities, refresh, and reset. Cloud authentication and writes require a configured Supabase project with the supplied schema and were not claimed as successful without that setup.

## Known limitations and future enhancements

This is a local demo rather than authenticated production software. Campaign contributions are pledges unless a resource is selected, seeded identities are not secure authentication, and cross-device synchronization is not available. Future work can add real authentication, moderation, notifications, image uploads, server-side transactions, richer charts and verified carbon accounting with documented lifecycle assumptions.
