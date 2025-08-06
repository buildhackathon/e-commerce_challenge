echo "🛒 Setting up E-Commerce Database..."

# Remove existing database if it exists
if [ -f "ecommerce.db" ]; then
    echo "Removing existing database..."
    rm ecommerce.db
fi

# Create database and run schema
echo "Creating database schema..."
sqlite3 ecommerce.db < DATABASE.sql

# Seed the database
echo "Seeding database with sample data..."
sqlite3 ecommerce.db << 'EOF'

-- =============================================================================
-- SEED DATA FOR E-COMMERCE DATABASE
-- =============================================================================

-- Insert Users
INSERT INTO USERS (first_name, last_name, email, password, role, phone) VALUES
('John', 'Doe', 'john.doe@email.com', 'hashed_password_123', 'customer', '+1-555-0101'),
('Jane', 'Smith', 'jane.smith@email.com', 'hashed_password_456', 'customer', '+1-555-0102'),
('Mike', 'Johnson', 'mike.johnson@email.com', 'hashed_password_789', 'customer', '+1-555-0103'),
('Admin', 'User', 'admin@store.com', 'admin_password_999', 'admin', '+1-555-0001'),
('Sarah', 'Wilson', 'sarah.wilson@email.com', 'hashed_password_321', 'affiliate', '+1-555-0104'),
('David', 'Brown', 'david.brown@email.com', 'hashed_password_654', 'customer', '+1-555-0105');

-- Insert Categories
INSERT INTO CATEGORIES (name, description, parent_id) VALUES
('Electronics', 'Electronic devices and gadgets', NULL),
('Computers', 'Desktop and laptop computers', 1),
('Smartphones', 'Mobile phones and accessories', 1),
('Clothing', 'Fashion and apparel', NULL),
('Men''s Clothing', 'Clothing for men', 4),
('Women''s Clothing', 'Clothing for women', 4),
('Books', 'Physical and digital books', NULL),
('Fiction', 'Fiction books and novels', 7),
('Non-Fiction', 'Educational and reference books', 7);

-- Insert Products
INSERT INTO PRODUCTS (name, description, sku, price, compare_at_price, cost_price, category_id, weight, requires_shipping, taxable) VALUES
('MacBook Pro 16"', 'High-performance laptop for professionals', 'MBP-16-2023', 2499.99, 2799.99, 1800.00, 2, 4.3, 1, 1),
('iPhone 15 Pro', 'Latest flagship smartphone', 'IPH-15-PRO', 999.99, NULL, 650.00, 3, 0.5, 1, 1),
('Samsung Galaxy S24', 'Android flagship phone', 'SGS-24-ULT', 899.99, 999.99, 580.00, 3, 0.45, 1, 1),
('Classic T-Shirt', 'Comfortable cotton t-shirt', 'TSH-CLT-001', 29.99, NULL, 12.00, 5, 0.2, 1, 1),
('Designer Jeans', 'Premium denim jeans', 'JNS-DSG-001', 149.99, 199.99, 75.00, 5, 0.8, 1, 1),
('Summer Dress', 'Light and airy summer dress', 'DRS-SUM-001', 79.99, NULL, 35.00, 6, 0.3, 1, 1),
('Programming Guide', 'Complete guide to modern programming', 'BK-PROG-001', 49.99, 59.99, 25.00, 8, 1.2, 1, 1),
('Digital Marketing E-book', 'Learn digital marketing strategies', 'BK-DM-EBOOK', 19.99, NULL, 5.00, 9, 0.0, 0, 1);

-- Insert Product Variants
INSERT INTO PRODUCT_VARIANTS (product_id, title, price, sku, inventory_quantity, weight) VALUES
(1, 'Space Gray', 2499.99, 'MBP-16-SG', 25, 4.3),
(1, 'Silver', 2499.99, 'MBP-16-SL', 30, 4.3),
(2, 'Natural Titanium 128GB', 999.99, 'IPH-15-NT-128', 50, 0.5),
(2, 'Blue Titanium 256GB', 1099.99, 'IPH-15-BT-256', 45, 0.5),
(3, 'Phantom Black 256GB', 899.99, 'SGS-24-PB-256', 35, 0.45),
(4, 'Small - Red', 29.99, 'TSH-CLT-S-RD', 100, 0.2),
(4, 'Medium - Blue', 29.99, 'TSH-CLT-M-BL', 150, 0.2),
(4, 'Large - Black', 29.99, 'TSH-CLT-L-BK', 120, 0.2),
(5, 'Size 32 - Dark Blue', 149.99, 'JNS-DSG-32-DB', 25, 0.8),
(5, 'Size 34 - Light Blue', 149.99, 'JNS-DSG-34-LB', 20, 0.8),
(6, 'Size M - Floral', 79.99, 'DRS-SUM-M-FL', 40, 0.3);

-- Insert Addresses
INSERT INTO ADDRESSES (user_id, is_shipping, first_name, last_name, address1, city, state, zip, country, phone) VALUES
(1, 0, 'John', 'Doe', '123 Main St', 'New York', 'NY', '10001', 'US', '+1-555-0101'),
(1, 1, 'John', 'Doe', '123 Main St', 'New York', 'NY', '10001', 'US', '+1-555-0101'),
(2, 0, 'Jane', 'Smith', '456 Oak Ave', 'Los Angeles', 'CA', '90210', 'US', '+1-555-0102'),
(2, 1, 'Jane', 'Smith', '789 Pine St', 'Los Angeles', 'CA', '90211', 'US', '+1-555-0102'),
(3, 0, 'Mike', 'Johnson', '789 Pine Rd', 'Chicago', 'IL', '60601', 'US', '+1-555-0103'),
(6, 1, 'David', 'Brown', '321 Elm St', 'Phoenix', 'AZ', '85001', 'US', '+1-555-0105');

-- Insert Orders
INSERT INTO ORDERS (user_id, email, status, subtotal, tax_amount, shipping_amount, total_amount, payment_status) VALUES
(1, 'john.doe@email.com', 'delivered', 2499.99, 199.99, 0.00, 2699.98, 'paid'),
(2, 'jane.smith@email.com', 'shipped', 1029.98, 82.40, 15.99, 1128.37, 'paid'),
(3, 'mike.johnson@email.com', 'confirmed', 79.99, 6.40, 9.99, 96.38, 'paid'),
(1, 'john.doe@email.com', 'pending', 179.98, 14.40, 12.99, 207.37, 'pending'),
(6, 'david.brown@email.com', 'cancelled', 49.99, 4.00, 5.99, 59.98, 'failed');

-- Insert Order Items
INSERT INTO ORDER_ITEMS (order_id, product_id, variant_id, quantity, price, total) VALUES
(1, 1, 1, 1, 2499.99, 2499.99),
(2, 4, 6, 1, 29.99, 29.99),
(2, 2, 4, 1, 999.99, 999.99),
(3, 6, 11, 1, 79.99, 79.99),
(4, 4, 7, 2, 29.99, 59.98),
(4, 5, 9, 1, 149.99, 149.99),
(5, 7, NULL, 1, 49.99, 49.99);

-- Insert Cart Items
INSERT INTO CART_ITEMS (user_id, product_id, variant_id, quantity) VALUES
(2, 3, 5, 1),
(3, 1, 2, 1),
(6, 8, NULL, 1),
(1, 4, 8, 3);

-- Insert Discounts
INSERT INTO DISCOUNTS (code, description, is_percentage, value, minimum_order_amount, usage_limit, used_count, start_date, end_date) VALUES
('WELCOME10', '10% off for new customers', 1, 10.00, 50.00, 100, 25, '2024-01-01', '2024-12-31'),
('SAVE20', '$20 off orders over $100', 0, 20.00, 100.00, 500, 150, '2024-01-01', '2024-06-30'),
('SUMMER15', '15% off summer collection', 1, 15.00, 75.00, 200, 45, '2024-06-01', '2024-08-31'),
('FREESHIP', 'Free shipping on orders over $50', 0, 0.00, 50.00, 1000, 320, '2024-01-01', '2024-12-31'),
('BLACKFRIDAY', '25% off everything', 1, 25.00, 0.00, 10000, 2500, '2024-11-29', '2024-11-29');

EOF

echo "✅ Database setup complete!"
echo ""
echo "📊 Database Statistics:"
sqlite3 ecommerce.db << 'EOF'
SELECT 'Users: ' || COUNT(*) FROM USERS;
SELECT 'Categories: ' || COUNT(*) FROM CATEGORIES;
SELECT 'Products: ' || COUNT(*) FROM PRODUCTS;
SELECT 'Product Variants: ' || COUNT(*) FROM PRODUCT_VARIANTS;
SELECT 'Orders: ' || COUNT(*) FROM ORDERS;
SELECT 'Order Items: ' || COUNT(*) FROM ORDER_ITEMS;
SELECT 'Cart Items: ' || COUNT(*) FROM CART_ITEMS;
SELECT 'Addresses: ' || COUNT(*) FROM ADDRESSES;
SELECT 'Discounts: ' || COUNT(*) FROM DISCOUNTS;
EOF

echo ""
echo "🎯 Sample Queries:"
echo "View all products: sqlite3 ecommerce.db 'SELECT p.name, p.price, c.name as category FROM PRODUCTS p JOIN CATEGORIES c ON p.category_id = c.id;'"
echo "View orders with totals: sqlite3 ecommerce.db 'SELECT u.first_name, u.last_name, o.status, o.total_amount FROM ORDERS o JOIN USERS u ON o.user_id = u.id;'"
echo "View cart contents: sqlite3 ecommerce.db 'SELECT u.first_name, p.name, ci.quantity FROM CART_ITEMS ci JOIN USERS u ON ci.user_id = u.id JOIN PRODUCTS p ON ci.product_id = p.id;'"
echo ""
echo "🛒 E-commerce database is ready for your use!"