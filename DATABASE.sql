-- Users table
CREATE TABLE IF NOT EXISTS USERS (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,
    role TEXT CHECK(role IN ('customer', 'affiliate', 'admin')) NOT NULL DEFAULT 'customer',
    phone TEXT,
    is_active BOOLEAN DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- Categories table
CREATE TABLE IF NOT EXISTS CATEGORIES (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    parent_id INTEGER,
    is_active BOOLEAN DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES CATEGORIES(id)
);
-- Products table
CREATE TABLE IF NOT EXISTS PRODUCTS (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    sku TEXT UNIQUE,
    price DECIMAL(10, 2) NOT NULL,
    compare_at_price DECIMAL(10, 2),
    cost_price DECIMAL(10, 2),
    category_id INTEGER,
    is_active BOOLEAN DEFAULT 1,
    weight DECIMAL(8, 2),
    requires_shipping BOOLEAN DEFAULT 1,
    taxable BOOLEAN DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES CATEGORIES(id)
);
-- Product variants table
CREATE TABLE IF NOT EXISTS PRODUCT_VARIANTS (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    sku TEXT UNIQUE,
    inventory_quantity INTEGER DEFAULT 0,
    weight DECIMAL(8, 2),
    is_active BOOLEAN DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES PRODUCTS(id) ON DELETE CASCADE
);
-- Orders table
CREATE TABLE IF NOT EXISTS ORDERS (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    email TEXT NOT NULL,
    status TEXT CHECK(
        status IN (
            'pending',
            'confirmed',
            'shipped',
            'delivered',
            'cancelled'
        )
    ) DEFAULT 'pending',
    subtotal DECIMAL(10, 2) NOT NULL,
    tax_amount DECIMAL(10, 2) DEFAULT 0,
    shipping_amount DECIMAL(10, 2) DEFAULT 0,
    total_amount DECIMAL(10, 2) NOT NULL,
    currency TEXT DEFAULT 'USD',
    payment_status TEXT CHECK(
        payment_status IN ('pending', 'paid', 'failed', 'refunded')
    ) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES USERS(id)
);
-- Order items table
CREATE TABLE IF NOT EXISTS ORDER_ITEMS (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    variant_id INTEGER,
    quantity INTEGER NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    total DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES ORDERS(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES PRODUCTS(id),
    FOREIGN KEY (variant_id) REFERENCES PRODUCT_VARIANTS(id)
);
-- Addresses table
CREATE TABLE IF NOT EXISTS ADDRESSES (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    order_id INTEGER,
    is_shipping BOOLEAN NOT NULL DEFAULT 0,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    company TEXT,
    address1 TEXT NOT NULL,
    address2 TEXT,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    zip TEXT NOT NULL,
    country TEXT NOT NULL DEFAULT 'US',
    phone TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES USERS(id),
    FOREIGN KEY (order_id) REFERENCES ORDERS(id)
);
-- Shopping cart table
CREATE TABLE IF NOT EXISTS CART_ITEMS (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    session_id TEXT,
    product_id INTEGER NOT NULL,
    variant_id INTEGER,
    quantity INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES USERS(id),
    FOREIGN KEY (product_id) REFERENCES PRODUCTS(id),
    FOREIGN KEY (variant_id) REFERENCES PRODUCT_VARIANTS(id)
);
-- Discounts/Coupons table
CREATE TABLE IF NOT EXISTS DISCOUNTS (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT UNIQUE NOT NULL,
    description TEXT,
    is_percentage BOOLEAN NOT NULL DEFAULT 1,
    value DECIMAL(10, 2) NOT NULL,
    minimum_order_amount DECIMAL(10, 2),
    usage_limit INTEGER,
    used_count INTEGER DEFAULT 0,
    start_date DATE,
    end_date DATE,
    is_active BOOLEAN DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- Indexes, made for performance optimization
CREATE INDEX IF NOT EXISTS idx_users_email ON USERS(email);
CREATE INDEX IF NOT EXISTS idx_products_category ON PRODUCTS(category_id);
CREATE INDEX IF NOT EXISTS idx_products_sku ON PRODUCTS(sku);
CREATE INDEX IF NOT EXISTS idx_orders_user ON ORDERS(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON ORDERS(status);
CREATE INDEX IF NOT EXISTS idx_order_items_order ON ORDER_ITEMS(order_id);
CREATE INDEX IF NOT EXISTS idx_cart_user ON CART_ITEMS(user_id);
CREATE INDEX IF NOT EXISTS idx_cart_session ON CART_ITEMS(session_id);