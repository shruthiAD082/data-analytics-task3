# Internship Task 3 - SQL for Data Analysis
## 🧪 Tools Used
- SQL Editor (MySQL Workbench / SQL Developer)

## What I did
- Created a small ecommerce database (`internship_task3`)
- Implemented tables: customers, products, orders, order_items
- Inserted sample data
- Ran analysis queries: total revenue, ARPU, top products, monthly revenue, customers without orders.

## How to run
1. Open MySQL Workbench and connect to Local instance.
2. Open `task3.sql` and run the script (run the schema + inserts first, then the analysis queries).
3. Take screenshots of the query outputs and add them to `/screenshots`.

## Key queries
- Total revenue: `SELECT SUM(oi.unit_price * oi.quantity) ...`
- ARPU: `SELECT AVG(user_rev) ...`
- Top products: `GROUP BY` on `order_items` joined with `products`
- Monthly revenue: view `monthly_revenue`

## Insights (example)
- Total revenue: <include number from your screenshot>
- Top product: <product name> with revenue <value>

## Files included
- `task3.sql` — full schema, sample data, analysis queries
- `mysql workbench ` — result images
