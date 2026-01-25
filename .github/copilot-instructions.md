# SQL Server Learning Project - AI Agent Guide

## Project Overview
Educational SQL Server repository demonstrating fundamental SQL operators, queries, and data manipulation patterns. Focus is on learning T-SQL syntax and practical query examples using a sample product inventory table.

## Architecture & Structure

**Key Components:**
- `Operatorler/` - Main learning module containing SQL demonstrations
  - `tabloolustur.sql` - Table creation and sample data seeding
  - `Calisma.sql` - Query examples demonstrating operators and filtering

**Data Model:**
The project uses a single test table `TestUrunleri` (Test Products) with these columns:
- `UrunID` (INT, IDENTITY) - Primary key, auto-incrementing
- `UrunAdi` (NVARCHAR) - Product name for LIKE pattern matching
- `Kategori` (NVARCHAR) - Category field for IN/filtering examples
- `BirimFiyat` (DECIMAL) - Unit price for arithmetic operations
- `StokAdedi` (INT) - Stock quantity for modulo (%) and arithmetic
- `SonSatisTarihi` (DATETIME, nullable) - Last sale date for IS NULL tests
- `Aciklama` (NVARCHAR, nullable) - Description for NULL handling

## Key SQL Patterns & Conventions

### Arithmetic & Comparison Operators
- Multiplication for tax calculations: `BirimFiyat * 1.20 AS KdvliFiyat`
- Modulo operator for even/odd checks: `StokAdedi % 2 = 0`
- Use DECIMAL(10,2) for price calculations to avoid float precision issues

### Filtering Patterns
- **Compound conditions**: Use `AND`/`OR` with parentheses for clarity
  ```sql
  WHERE BirimFiyat > 2000 AND (Kategori = 'Elektronik' OR Kategori = 'Spor')
  ```
- **IN operator**: Preferred over multiple OR for categorical filtering
  ```sql
  WHERE Kategori IN ('Giyim', 'Spor')
  ```
- **LIKE pattern matching**: Document wildcard usage in comments
  - `'%Pro%'` - Contains pattern
  - `'Laptop%'` - Starts with pattern
  - `'%27 inç'` - Ends with pattern
  - `'_at%'` - Single character wildcard

### NULL Handling
- Test both `IS NULL` and `IS NOT NULL` explicitly
- Remember: `NULL` comparisons always return unknown, never `FALSE`
- Use nullable fields for demonstrating NULL behavior

### Date Comparisons
- Use string comparison format: `'2023-10-01'` for date literals
- `GETDATE()` for current timestamp in INSERT examples
- Document timezone considerations (SQL Server uses server timezone)

## Development Workflows

**Adding Examples:**
1. Edit `Calisma.sql` to add new query demonstrations
2. Always comment examples in Turkish (project language) with what clause demonstrates
3. Keep queries simple and pedagogical - one operator per example when possible

**Testing Changes:**
1. Run `tabloolustur.sql` first to recreate the test table and seed data
2. Then execute queries from `Calisma.sql` to verify output
3. Use simple `SELECT *` queries to inspect full result sets

## Turkish Language Context
- Column/table names are in Turkish (UrunAdi, StokAdedi, etc.)
- Comments are in Turkish; maintain this for consistency
- Common terms: Ürün=Product, Stok=Stock, Fiyat=Price, Kategori=Category

## Important Constraints & Gotchas
- Table uses `IF OBJECT_ID...DROP TABLE` pattern for safe recreation
- Primary key is `IDENTITY(1,1)` - don't manually specify UrunID in INSERTs
- Test data includes edge cases: NULL dates, zero stock, and NULL descriptions
- All prices are stored as DECIMAL(10,2) - respect this for consistency

## When Adding New Content
- Keep educational focus: explain "why" operators work as they do
- Add Turkish-language comments explaining what each query demonstrates
- Use the existing TestUrunleri table schema as the reference
- Avoid complex joins or subqueries - project teaches basic operators only
