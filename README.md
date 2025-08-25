# Sales-Analytics-DWH-Project
This project demonstrates a complete end-to-end Business Intelligence solution built using Microsoft technologies. It extracts raw data from a transactional database, transforms and loads it into a star-schema Data Warehouse, and delivers actionable insights using Power BI dashboards powered by an SSAS cube.

---

## 🚀 Project Overview

### 🔧 Technologies Used:
- **SQL Server** – for staging and DWH storage
- **SSIS** – for ETL pipelines and incremental data load
- **SSAS (Multidimensional)** – for building and exposing an analytical data model (cube)
- **Power BI** – for data visualization and dashboarding

---

## 🧱 Data Warehouse Design

### ⭐ Star Schema Structure:
- **Fact Table**: `fact_sales`
  - Measures: `extended_sales`, `extended_cost`, `tax_amount`, `freight`, `quantity`, etc.
  - Columns: `order_date_key`, `product_key`, `customer_key`, `territory_key`, etc.

- **Dimension Tables**:
  - `dim_date`
  - `dim_product`
  - `dim_customer`
  - `dim_territory`

### 🕒 Slowly Changing Dimensions (SCD):
- `dim_product`:  
  - Type 1: `color`, `model_name`, `product_category`, `subcategory`, `standard_cost`
  - Type 2: `reorder_point`
- `dim_customer`:  
  - Type 1: `address1`, `address2`, `city`, `customer_name`  
  - Type 2: `phone`

All dimension tables (except `dim_date`) include:
- `start_date`, `end_date`, `is_current`, `source_system_code`

---

## 🔄 ETL Process (SSIS)

- Used **Lookup** and **Derived Columns** for combining source tables and cleaning data
- **SCD components** implemented for historical tracking
- **Incremental Load** implemented by storing `last_load_date` in a separate control table
- Used `Execute SQL Task` to dynamically populate `dim_date` table between `MIN` and `MAX` date from source

---

## 📊 SSAS Cube

- Created cube on top of the DWH
- Defined measures: Total Sales, Cost, Tax, Quantity, Freight, Profit, etc.
- Enabled browsing through time, customer, product, and territory hierarchies

---

## 📈 Power BI Dashboard

- Connected to the SSAS cube via import connection
- Designed visuals to answer the following 10 key business questions:
  1. Total sales trends over time
  2. Top-performing products by revenue
  3. Top customers by purchase amount
  4. Profitability analysis by product (price/cost difference)
  5. Sales performance by customer
  6. Most profitable products
  7. Sales trend by quarter
  8. Impact of weekends/holidays on sales
  9. Top Selling Products by Quantity
  10. Peak selling periods

- KPI cards for total revenue, cost, freight, tax, and quantity sold

---

## 📁 Folder Structure

📂 SSIS-Packages/

📂 SQL-Scripts/

📂 SSAS-Cube/

📂 PowerBI-Report/

📂 Images/

📄 README.md


---

## 📌 Notes

- All ETL packages are reusable and designed for scalability
- Power BI visuals are interactive 
- Cube is optimized for high performance browsing

---

## 📬 Contact

For feedback or questions, feel free to reach out:
**Mahmoud Reda** – [LinkedIn](https://www.linkedin.com/in/mahmoud-reda2001/)  
📧 mahmoud.reda.eltabakh@gmail.com


