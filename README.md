## 0) Global fields

```SQL
    is_active BOOLEAN DEFAULT 1
```

The "is_active" field is required to allow for soft deletion, this is in case certain data is not ideal to completely delete and would just avoid being shown when soft deleted.

```SQL
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
```

The "created_at" and the "update_at" are self explanatory, they follow the creation/update of the item that is to be entered into the database.

## 1) Users table

```SQL
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
```

- ID, first name, last name, email and password are required as they are the basis for the user themselves.
- The phone number is text as it would take it directly including the country code (Example: "+973 33223231").
- Role is ideal to separate those who are using it as affiliate, customer, or an admin of the website.
- The field checking if the user is active allows for soft deletion, which in this case for an e-commerce is ideal.
- Default created and updated fields to ensure when the user's account has been created/modified.

## 2) Categories table

```SQL
CREATE TABLE IF NOT EXISTS CATEGORIES (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    parent_id INTEGER,
    is_active BOOLEAN DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES CATEGORIES(id)
);
```

- Default id and name values, required for base identification. The description is nullable, not required to keep when unnecessary.
- The parent id is needed for base categories (Example: Electronics (id: 1) has Laptops (id: 4, parent_id: 1) as the child, and it can have nested children like Gaming Laptops(id: 8, parent_id: 4)).
- Soft deletion enabled to preserve category hierarchy when categories are removed.

## 3) Products table

```SQL
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
```

- Name and price are required for basic product information.
- SKU (Stock Keeping Unit) is unique for inventory tracking, nullable for products without specific codes.
- `compare_at_price` allows for showing "was $X, now $Y" pricing for sales.
- `cost_price` tracks wholesale cost for profit margin calculations.
- `weight` and `requires_shipping` handle shipping calculations and digital products.
- `taxable` determines if tax should be applied to the product.

## 4) Product Variants table

```SQL
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
```

- Handles product variations like size, color, or different specifications.
- Each variant can have its own price, SKU, inventory, and weight.
- `ON DELETE CASCADE` ensures variants are removed when parent product is deleted.
- `inventory_quantity` tracks stock levels for each specific variant.

## 5) Orders table

```SQL
CREATE TABLE IF NOT EXISTS ORDERS (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    email TEXT NOT NULL,
    status TEXT CHECK(status IN ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled')) DEFAULT 'pending',
    subtotal DECIMAL(10, 2) NOT NULL,
    tax_amount DECIMAL(10, 2) DEFAULT 0,
    shipping_amount DECIMAL(10, 2) DEFAULT 0,
    total_amount DECIMAL(10, 2) NOT NULL,
    currency TEXT DEFAULT 'USD',
    payment_status TEXT CHECK(payment_status IN ('pending', 'paid', 'failed', 'refunded')) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES USERS(id)
);
```

- `user_id` is nullable to support guest checkout.
- Email is required for order confirmation and tracking.
- Separate `status` (fulfillment) and `payment_status` tracking.
- Financial breakdown with subtotal, tax, shipping, and total amounts.
- Currency field supports international sales.

## 6) Order Items table

```SQL
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
```

- Links products to orders with quantity and pricing at time of purchase.
- `variant_id` is nullable for products without variants.
- Stores historical pricing to preserve order accuracy even if product prices change.
- `ON DELETE CASCADE` removes items when order is deleted.

## 7) Addresses table

```SQL
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
```

- Supports both user saved addresses and order-specific addresses.
- **Address type as boolean**: `is_shipping` field where `0 = billing address`, `1 = shipping address`
- `company` is optional for business orders.
- `address2` handles apartment numbers, suite numbers, etc.
- Phone number stored as text to handle international formats.

### Boolean Field Conventions (IS SHIPPING)

For fields with only two possible values, we use boolean fields for better performance and simpler queries:

- **`is_shipping`**: `0` for billing addresses, `1` for shipping addresses
  - Query billing addresses: `WHERE is_shipping = 0`
  - Query shipping addresses: `WHERE is_shipping = 1`
  - More efficient than string comparisons
  - Uses less storage space
  - Eliminates typos in address type values
  - Faster filtering for checkout processes

## 8) Shopping Cart table

```SQL
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
```

- Supports both logged-in users (`user_id`) and guest users (`session_id`).
- `variant_id` is nullable for products without variants.
- `updated_at` tracks when cart items were last modified for cleanup of abandoned carts.

## 9) Discounts/Coupons table

```SQL
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
```

- **Discount type as boolean**: `is_percentage` field where `1 = percentage discount`, `0 = fixed amount discount`
- `value` represents either percentage (e.g., 15.00 for 15%) or fixed amount (e.g., 10.00 for $10 off)
- `minimum_order_amount` sets threshold for discount eligibility
- Usage tracking with `usage_limit` and `used_count`
- Date range validation with `start_date` and `end_date`

### Boolean Field Conventions (IS PERCENTAGE)

For fields with only two possible values, we use boolean fields for better performance and simpler queries:

- **`is_percentage`**: `1` for percentage discounts, `0` for fixed amount discounts
  - Query percentage discounts: `WHERE is_percentage = 1`
  - Query fixed amount discounts: `WHERE is_percentage = 0`
  - More efficient than string comparisons
  - Uses less storage space
  - Eliminates typos in discount type values
  - Simpler discount calculation logic in application code

## Performance Indexes

The schema includes optimized indexes for common query patterns:

- `idx_users_email`: Fast user authentication and lookups
- `idx_products_category`: Quick product filtering by category
- `idx_products_sku`: Fast product lookups by SKU
- `idx_orders_user`: Quick access to user's order history
- `idx_orders_status`: Fast filtering by order status for admin dashboards
- `idx_order_items_order`: Quick retrieval of items in an order
- `idx_cart_user`: Fast cart loading for logged-in users
- `idx_cart_session`: Cart access for guest users

## How to set up (USING SQLITE3)

```bash
chmod +x SCRIPT.sh
./SCRIPT.sh
```