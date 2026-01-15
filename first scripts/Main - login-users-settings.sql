CREATE TABLE public.users (
	id serial4 NOT NULL,
	username varchar(50) DEFAULT 'client'::character varying NULL,
	email varchar(100) NOT NULL,
	phone varchar(20) NULL,
	password varchar(255) NOT NULL,
	"role" varchar(20) DEFAULT 'user'::character varying NULL,
	is_active bool DEFAULT true NULL,
	last_login timestamp NULL,
	created_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	updated_at timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	CONSTRAINT users_email_key UNIQUE (email),
	CONSTRAINT users_phone_key UNIQUE (phone),
	CONSTRAINT users_pkey PRIMARY KEY (id)
);

drop table users CASCADE;

select * from pg_stat_activity where datid is not NULL;

select * from users;
select * from user_logins order by login_time desc;
select * from user_refresh_tokens order by created_at desc;

drop schema hdb_catalog cascade;

delete from users where username = 'client';
delete from user_refresh_tokens where user_id = 6;-- and created_at < '2025-11-07';


ALTER TABLE users
RENAME COLUMN password TO password_hash;

ALTER TABLE users
ALTER COLUMN password_hash TYPE VARCHAR(255);

ALTER TABLE users
ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE users
ADD COLUMN tenant VARCHAR(100);

ALTER TABLE users
ADD COLUMN adress VARCHAR(1000);

drop TABLE users;
Truncate TABLE users;

SELECT * FROM pg_user;

CREATE USER lsstudio_user WITH PASSWORD 'lsstudio2025';
CREATE USER judithsstil_user WITH PASSWORD 'judithsstil2025';

create schema lsstudio;

CREATE SCHEMA judithsstil AUTHORIZATION judithsstil_user;

GRANT SELECT, INSERT, UPDATE ON public.users TO lsstudio_user, judithsstil_user;

GRANT SELECT, INSERT, UPDATE ON public.user_logins TO lsstudio_user, judithsstil_user;

update set usecreatedb = true, usesuper = true, userepl = true, usebypassrls = true where usename = "dbadmin";

GRANT SELECT, INSERT, update, DELETE ON public.user_refresh_tokens TO lsstudio_user, judithsstil_user;
--GRANT SELECT, INSERT, update, DELETE ON public.user_refresh_tokens TO lsstudio_user, judithsstil_user;

CREATE TABLE products (
    id SERIAL PRIMARY KEY,              -- автоінкрементний унікальний ID
    title JSONB NOT NULL,
    images JSONB NOT NULL,
    quantity INTEGER default 1,
    description JSONB,  
    is_available BOOLEAN DEFAULT true,  
    changed_at TIMESTAMP DEFAULT NOW(),               
    updated_at  TIMESTAMP DEFAULT NOW()
);

CREATE TABLE favorites (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE CASCADE,
    product_id INT REFERENCES products(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, product_id)
);

drop table nomenclature;
--alter table nomenclature add column quantity INTEGER default 1;

select * from lsstudio.products;

CREATE TABLE prices (
    id SERIAL PRIMARY KEY,
    product_id TEXT NOT NULL,
    price NUMERIC(10, 2) CHECK (price >= 0),
    
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id) ON DELETE SET NULL,
    status VARCHAR(50), -- DEFAULT 'pending', -- pending, paid, shipped
    total NUMERIC(10,2),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(id) ON DELETE CASCADE,
    product_id INT REFERENCES products(id) ON DELETE SET NULL,
    quantity INT DEFAULT 1,
    price NUMERIC(10,2), -- ціна на момент замовлення
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE messages (
    id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(id) ON DELETE CASCADE,
    sender VARCHAR(50), -- user/admin
    content TEXT,
    read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE news (
    id SERIAL PRIMARY KEY,
    title JSONB,
    content JSONB, -- текст, фото, відео
    created_by INT REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

select * from favorites;

SHOW max_connections;
SHOW superuser_reserved_connections;
SHOW idle_in_transaction_session_timeout;


ALTER SYSTEM SET max_connections = 360;
ALTER SYSTEM SET idle_in_transaction_session_timeout = '1min';

SELECT pid, usename, datname, client_addr, state, backend_start
FROM pg_stat_activity
ORDER BY backend_start DESC;

select count(state), state, usename, datname, client_addr
FROM pg_stat_activity
where state is not NULL
group by state, usename, datname, client_addr;
--ORDER BY state DESC;

SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE state = 'idle';

SELECT
  rolname,
  rolsuper,
  rolcreatedb,
  rolcreaterole,
  rolcanlogin
FROM pg_roles
ORDER BY rolname;

SELECT
  datname,
  pg_get_userbyid(datdba) AS owner,
  datacl
FROM pg_database
WHERE datname NOT IN ('template0', 'template1');

SELECT
  n.nspname AS schema,
  pg_get_userbyid(n.nspowner) AS owner,
  n.nspacl
FROM pg_namespace n
WHERE n.nspname NOT LIKE 'pg_%'
  AND n.nspname <> 'information_schema';

SELECT
  grantee,
  table_schema,
  table_name,
  privilege_type
FROM information_schema.role_table_grants
where grantee not in ('postgres')
ORDER BY table_schema, table_name, grantee;