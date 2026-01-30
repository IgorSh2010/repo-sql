-- =============================================
-- 📦 Основна таблиця замовлень
-- =============================================
CREATE TABLE lsstudio.orders (
  id SERIAL PRIMARY KEY,
  user_id INTEGER references users(id) ON DELETE SET NULL,
  total_price NUMERIC(10,2) NOT NULL CHECK (total_price >= 0),
  status_id INTEGER REFERENCES lsstudio.order_statuses(id),  -- поточний статус
  payment_id INTEGER,
  description TEXT, 
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

drop table lsstudio.orders cascade;

-- =============================================
-- 🧾 Довідник статусів замовлень
-- =============================================
CREATE TABLE judithsstil.order_statuses (
  id SERIAL PRIMARY KEY,
  code VARCHAR(50) UNIQUE NOT NULL,       -- внутрішнє ім’я, наприклад 'pending'
  label VARCHAR(100) NOT NULL,            -- видиме ім’я, наприклад 'Очікує оплату'
  description TEXT,                       -- опціонально, для адміністрування
  created_at TIMESTAMP DEFAULT NOW()
);
CREATE TABLE lsstudio.order_statuses (
  id SERIAL PRIMARY KEY,
  code VARCHAR(50) UNIQUE NOT NULL,       -- внутрішнє ім’я, наприклад 'pending'
  label VARCHAR(100) NOT NULL,            -- видиме ім’я, наприклад 'Очікує оплату'
  description TEXT,                       -- опціонально, для адміністрування
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE judithsstil.payments (
  id SERIAL PRIMARY KEY,
  order_id INTEGER REFERENCES judithsstil.orders(id) ON DELETE CASCADE,
  user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
  amount NUMERIC(10,2) NOT NULL CHECK (amount >= 0),
  currency VARCHAR(10) DEFAULT 'PLN',
  method VARCHAR(50) DEFAULT 'Brak płatności',                  -- наприклад: 'stripe', 'payu', 'blik', 'transfer'
  status VARCHAR(50) DEFAULT 'pending',-- 'pending', 'success', 'failed', 'refunded'
  external_id VARCHAR(100),            -- ID транзакції з платіжної системи
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Стандартні статуси (можеш одразу наситити таблицю)
INSERT INTO judithsstil.order_statuses (code, label) VALUES
  ('pending', 'Nowe'),
  ('awaiting_payment', 'Oczekujące na opłatę'),
  ('paid', 'Opłacone, w realizacji'),
  ('shipped', 'Wysłane'),
  ('delivered', 'Dostarczone'),
  ('completed', 'Zrealizowane'),
  ('cancelled', 'Anulowane');

INSERT INTO lsstudio.order_statuses (code, label) VALUES
  ('pending', 'Nowe'),
  ('awaiting_payment', 'Oczekujące na opłatę'),
  ('paid', 'Opłacone, w realizacji'),
  ('shipped', 'Wysłane'),
  ('delivered', 'Dostarczone'),
  ('completed', 'Zrealizowane'),
  ('cancelled', 'Anulowane');
 --<option value="Nowe">📜 Nowe</option>
 -- <option value="oczekujące na opłatę">⏳ oczekujące na opłatę</option>
 -- <option value="opłacone, w realizacji">📌 opłacone, w realizacji</option>
 -- <option value="wysłane">🚀 wysłane</option>
 -- <option value="zrealizowane">✅ zrealizowane</option>
 -- <option value="anulowane">❌ anulowane</option>

CREATE TABLE judithsstil.order_items (
  id SERIAL PRIMARY KEY,
  order_id INTEGER REFERENCES judithsstil.orders(id) ON DELETE CASCADE,
  product_id INTEGER REFERENCES judithsstil.products(id),
  quantity INTEGER NOT NULL,
  price NUMERIC(10,2) NOT NULL
);

-- =============================================
-- 🕓 Історія змін статусів
-- =============================================
CREATE TABLE judithsstil.order_status_history (
  id SERIAL PRIMARY KEY,
  order_id INTEGER REFERENCES judithsstil.orders(id) ON DELETE CASCADE,
  user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,  -- хто змінив
  status_id INTEGER REFERENCES judithsstil.order_statuses(id),          -- який статус
  note TEXT,                                                             -- опціональний коментар (наприклад "Оплата підтверджена вручну")
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE lsstudio.order_status_history (
  id SERIAL PRIMARY KEY,
  order_id INTEGER REFERENCES judithsstil.orders(id) ON DELETE CASCADE,
  user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,  -- хто змінив
  status_id INTEGER REFERENCES judithsstil.order_statuses(id),          -- який статус
  note TEXT,                                                             -- опціональний коментар (наприклад "Оплата підтверджена вручну")
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
-- =============================================
-- 🪄 Тригери (опціонально)
-- =============================================

-- 1️⃣ Автоматичне оновлення поля updated_at у orders при зміні
CREATE OR REPLACE FUNCTION lsstudio.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_orders_updated_at
BEFORE UPDATE ON lsstudio.orders
FOR EACH ROW
EXECUTE FUNCTION lsstudio.update_updated_at_column();

-- 2️⃣ Автоматичне створення запису в історії при зміні статусу
CREATE OR REPLACE FUNCTION lsstudio.log_order_status_change()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status_id IS DISTINCT FROM OLD.status_id THEN
    INSERT INTO lsstudio.order_status_history (order_id, user_id, status_id)
    VALUES (NEW.id, NEW.user_id, NEW.status_id);
  END IF;
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER order_status_change_trigger
AFTER UPDATE ON lsstudio.orders
FOR EACH ROW
EXECUTE FUNCTION lsstudio.log_order_status_change();

INSERT INTO judithsstil.order_items
(order_id, product_id, quantity, price)
VALUES(6, 10, 1, 294.00);

select * from judithsstil.order_statuses os ;
select * from judithsstil.orders where user_id = 10;
select * from judithsstil.order_items where order_id = 55;
select * from judithsstil.order_status_history ORDER BY updated_at desc;
select * from judithsstil.payments ;
select * from judithsstil.carts ;
select * from judithsstil.cart_items where id = 2;

select * from lsstudio.orders;
SELECT date_trunc('month', current_date);

SELECT COUNT(*) as order_count FROM judithsstil.orders WHERE status_id = 1

INSERT INTO judithsstil.cart_items
(id, cart_id, product_id, quantity, price)
VALUES(22, 1, 13, 1, 150.00);

SELECT o.*, 
      u.username AS customer_name,
      u.email AS customer_email,
      u.phone AS customer_phone,
      u.adress AS customer_adress 
FROM judithsstil.orders o
LEFT JOIN users u 
  ON o.user_id = u.id
WHERE o.id = 55;

SELECT distinct UPPER(method) FROM judithsstil.payments;

ALTER TABLE judithsstil.cart_items ADD CONSTRAINT citems_cart_product_unique UNIQUE (cart_id, product_id);
ALTER TABLE judithsstil.carts ADD CONSTRAINT cart_user_unique UNIQUE (user_id);

Truncate table judithsstil.orders cascade;
Truncate table judithsstil.order_items;
Truncate table judithsstil.order_status_history;
Truncate table judithsstil.payments;
Truncate table judithsstil.cart_items;
Truncate table judithsstil.carts;

SELECT o.*, os.label as status_label  FROM judithsstil.orders o
left join judithsstil.order_statuses os 
	on o.status_id = os.id 
WHERE user_id = 6

SELECT 
    o.id, 
    u.username, 
    u.email, 
    u.phone, 
    u.adress, 
    o.total_price, 
    o.status_id,
    p.method as payment_method, 
    p.status as payment_status,
    p.external_id as payment_external_id,
    p.created_at as payment_date,
    o.created_at as order_date,
    o.updated_at as order_updated_at,
    (SELECT 
        oi.id,
        p.id AS product_id,
        p.title,
        pi.image_url,
        p.price AS product_price,
        oi.quantity,
        oi.price AS item_price,
        (oi.quantity * oi.price) AS total_item
        FROM judithsstil.order_items oi
        left JOIN judithsstil.products p ON p.id = oi.product_id
        left JOIN judithsstil.product_images pi ON pi.product_id = oi.product_id
        WHERE oi.order_id = 2) as products,
    o.description
 FROM judithsstil.orders o
  LEFT JOIN public.users u ON o.user_id = u.id
  LEFT JOIN judithsstil.payments p ON o.payment_id = p.id
  WHERE o.id = 2
  ORDER BY o.updated_at desc;

drop table judithsstil.orders;
drop table judithsstil.order_items;
truncate table judithsstil.payments;
-- Тестові дані для замовлень користувачів 6 і 7
-- Статуси: oczekujące na opłatę, opłacone, przygotowywane, wysłane, dostarczone, anulowane

-- === INSERT orders ===
INSERT INTO judithsstil.orders (user_id, total_price, status_id, created_at)
VALUES
(6, 299.99, 1, NOW() - INTERVAL '20 days'),
(6, 159.99, 2, NOW() - INTERVAL '18 days'),
(6, 589.50, 3, NOW() - INTERVAL '17 days'),
(6, 199.00, 4, NOW() - INTERVAL '16 days'),
(6, 299.99, 5, NOW() - INTERVAL '15 days'),
(6, 129.00, 6, NOW() - INTERVAL '14 days'),
(6, 199.00, 1, NOW() - INTERVAL '13 days'),
(6, 229.99, 2, NOW() - INTERVAL '12 days'),
(6, 459.99, 3, NOW() - INTERVAL '11 days'),
(6, 129.00, 4, NOW() - INTERVAL '10 days'),
(6, 249.99, 5, NOW() - INTERVAL '9 days'),
(6, 179.00, 6, NOW() - INTERVAL '8 days'),
(6, 199.00, 1, NOW() - INTERVAL '7 days'),
(6, 279.99, 2, NOW() - INTERVAL '6 days'),
(6, 189.99, 3, NOW() - INTERVAL '5 days'),
(6, 329.00, 4, NOW() - INTERVAL '4 days'),
(7, 249.99, 5, NOW() - INTERVAL '15 days'),
(7, 159.00, 6, NOW() - INTERVAL '14 days'),
(7, 349.99, 1, NOW() - INTERVAL '13 days'),
(7, 499.00, 2, NOW() - INTERVAL '12 days'),
(7, 229.00, 3, NOW() - INTERVAL '11 days'),
(7, 139.99, 4, NOW() - INTERVAL '10 days'),
(7, 259.99, 5, NOW() - INTERVAL '9 days'),
(7, 289.00, 6, NOW() - INTERVAL '8 days'),
(7, 379.00, 1, NOW() - INTERVAL '7 days'),
(7, 199.99, 2, NOW() - INTERVAL '6 days'),
(7, 449.00, 3, NOW() - INTERVAL '5 days'),
(7, 299.00, 4, NOW() - INTERVAL '4 days'),
(7, 239.99, 5, NOW() - INTERVAL '3 days'),
(7, 199.00, 6, NOW() - INTERVAL '2 days'),
(6, 189.99, 1, NOW() - INTERVAL '19 days'),
(6, 219.00, 2, NOW() - INTERVAL '18 days'),
(6, 299.00, 3, NOW() - INTERVAL '17 days'),
(6, 149.99, 4, NOW() - INTERVAL '16 days'),
(6, 499.00, 5, NOW() - INTERVAL '15 days'),
(6, 199.00, 6, NOW() - INTERVAL '14 days'),
(7, 289.99, 1, NOW() - INTERVAL '13 days'),
(7, 249.00, 2, NOW() - INTERVAL '12 days'),
(7, 319.00, 3, NOW() - INTERVAL '11 days'),
(7, 269.00, 4, NOW() - INTERVAL '10 days'),
(7, 359.99, 5, NOW() - INTERVAL '9 days'),
(7, 299.00, 6, NOW() - INTERVAL '8 days'),
(7, 199.99, 1, NOW() - INTERVAL '7 days'),
(7, 279.00, 2, NOW() - INTERVAL '6 days'),
(7, 339.00, 3, NOW() - INTERVAL '5 days'),
(7, 229.99, 4, NOW() - INTERVAL '4 days'),
(7, 389.99, 5, NOW() - INTERVAL '3 days'),
(7, 189.00, 6, NOW() - INTERVAL '2 days'),
(6, 299.00, 1, NOW() - INTERVAL '1 day'),
(7, 249.00, 2, NOW());

-- === INSERT order_items ===
-- Припустимо, кожне замовлення має 1–3 товари з випадковими кількостями
INSERT INTO judithsstil.order_items (order_id, product_id, quantity, price)
SELECT o.id, (ARRAY[9,10,11])[floor(random()*3)+1], (floor(random()*3)+1), (floor(random()*200)+100)
FROM judithsstil.orders o;

select floor(random()*500000000)+1 as Random_Num;
select gen_random_uuid();

-- === INSERT order_status_history ===
INSERT INTO judithsstil.order_status_history (order_id, user_id, status_id, created_at)
SELECT id, user_id, 2, created_at FROM judithsstil.orders WHERE status_id >= 2
UNION ALL
SELECT id, user_id, 3, created_at + INTERVAL '1 day' FROM judithsstil.orders WHERE status_id >= 3
UNION ALL
--SELECT id, user_id, 'przygotowywane', created_at + INTERVAL '2 day' FROM judithsstil.orders WHERE status_id >= 3
--UNION ALL
SELECT id, user_id, 4, created_at + INTERVAL '2 day' FROM judithsstil.orders WHERE status_id >= 4
UNION ALL
SELECT id, user_id, 5, created_at + INTERVAL '4 day' FROM judithsstil.orders WHERE status_id >= 5
UNION all
SELECT id, user_id, 6, created_at + INTERVAL '7 day' FROM judithsstil.orders WHERE status_id >= 6
UNION ALL
SELECT id, user_id, 7, created_at + INTERVAL '1 day' FROM judithsstil.orders WHERE status_id = 7;

-- === INSERT payments ===
-- Для статусів oczekujące на opłatę – без запису, інші мають платіж
INSERT INTO judithsstil.payments (order_id, user_id, amount, method, status, external_id, created_at)
SELECT id, user_id, total_price, 
       (ARRAY['blik','karta','przelew'])[floor(random()*3)+1],
       CASE WHEN status_id = 1 THEN 'oczekujące' ELSE 'zakończona' END,       
       gen_random_uuid(),
       created_at + INTERVAL '1 hour'
FROM judithsstil.orders
WHERE status_id > 1;

SELECT 
    oi.id,
    p.id AS product_id,
    p.title,
    pi.image_url,
    p.price AS product_price,
    oi.quantity,
    oi.price AS item_price,
    (oi.quantity * oi.price) AS total_item
    FROM judithsstil.order_items oi
    left JOIN judithsstil.products p ON p.id = oi.product_id 
    left JOIN judithsstil.product_images pi ON pi.product_id = oi.product_id
    WHERE oi.order_id = 6;

-- =============================================
-- 📦 Робота над кошиком клієнта
-- =============================================
CREATE TABLE judithsstil.carts (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  amount NUMERIC(10,2) NOT NULL CHECK (amount >= 0),
  is_finished bool DEFAULT false NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE judithsstil.cart_items (
  id SERIAL PRIMARY KEY,
  cart_id INTEGER REFERENCES judithsstil.carts(id) ON DELETE CASCADE,
  product_id INTEGER REFERENCES judithsstil.products(id),
  quantity INTEGER DEFAULT 1,
  price NUMERIC(10,2) NOT NULL
);

drop table judithsstil.carts CASCADE;


CREATE TABLE lsstudio.order_statuses (
	id serial4 NOT NULL,
	code varchar(50) NOT NULL,
	"label" varchar(100) NOT NULL,
	description text NULL,
	created_at timestamp DEFAULT now() NULL,
	CONSTRAINT order_statuses_code_key UNIQUE (code),
	CONSTRAINT order_statuses_pkey PRIMARY KEY (id)
);
