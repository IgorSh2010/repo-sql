CREATE TABLE user_logins (
  id SERIAL PRIMARY KEY,
  user_id INT REFERENCES users(id),
  login_time TIMESTAMP DEFAULT NOW(),
  ip_address TEXT,
  user_agent TEXT,
  database_user TEXT DEFAULT current_user
);

CREATE TABLE user_refresh_tokens (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  token TEXT NOT NULL,
  user_agent TEXT,
  ip_address TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  expires_at TIMESTAMP
);

alter table user_logins 
add column refresh_token TEXT;

alter table user_logins 
add column created_reftoken_at TIMESTAMP;

alter table user_logins 
add column expires_reftoken_at TIMESTAMP;

alter table user_logins 
drop column expires_reftoken_at;


CREATE OR REPLACE FUNCTION set_db_user()
RETURNS TRIGGER AS $$
BEGIN
  NEW.database_user := current_user;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_db_user_trigger
BEFORE INSERT ON user_logins
FOR EACH ROW
EXECUTE FUNCTION set_db_user();

CREATE TABLE judithsstil.products (
	id serial4 NOT NULL,
	title VARCHAR(255) NOT NULL,
	image_folder_uuid VARCHAR(64),
	quantity int4 DEFAULT 1 NULL,
	price NUMERIC(10,2),
	description TEXT,
	is_available bool DEFAULT true NULL,
	created_at  timestamp DEFAULT now(),
	updated_at timestamp DEFAULT now(),
	CONSTRAINT products_pkey PRIMARY KEY (id)
);

CREATE TABLE judithsstil.product_images (
  id SERIAL PRIMARY KEY,
  product_id INTEGER REFERENCES judithsstil.products(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL
);

CREATE TABLE judithsstil.product_categories (
  id SERIAL PRIMARY KEY,
  name TEXT,
  slug TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS judithsstil.settings (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE cascade,
  banner_public_id VARCHAR(255),
  banner_url TEXT,
  logo_public_id VARCHAR(255),
  logo_url TEXT,
  avatar_public_id VARCHAR(255),
  avatar_url TEXT,
  created_by TEXT DEFAULT current_user, 
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

drop table judithsstil.settings;
ALTER TABLE judithsstil.settings ADD CONSTRAINT settings_user_unique UNIQUE (user_id);

alter table judithsstil.products 
drop column image_folder_uuid;

alter table judithsstil.product_images 
add column public_id VARCHAR(255) NOT NULL;

select * from judithsstil.products order by updated_at desc;
select * from judithsstil.product_images;
select * from judithsstil.settings;
select * from judithsstil.product_categories;

INSERT INTO judithsstil.product_categories
(id, "name", slug)
VALUES(6, 'Swetry', 'swetry');

INSERT INTO judithsstil.products
(id, title, quantity, price, description, is_available, created_at, updated_at, category_id, sizes, is_bestseller, is_featured)
VALUES(26, 'Sweterek beżowy w romby', 1, 80.00, 'Rozmiar uniwersalny polecam od S do L|XL . Elastyczny materiał. ', true, '2025-12-01 08:47:39.605', '2025-12-01 08:47:39.605', 6, '{ONESIZE}', false, false);
INSERT INTO judithsstil.products
(id, title, quantity, price, description, is_available, created_at, updated_at, category_id, sizes, is_bestseller, is_featured)
VALUES(25, 'Sukienka czekolada z naszyjnikiem ', 1, 79.00, 'Podwójny materiał na biuscie , elastyczny , marszczenia po bokach przez co możemy regulować długosc . Rozmiar uni polecam od S do L .', true, '2025-12-01 08:43:04.607', '2025-12-01 08:43:04.607', 1, '{ONESIZE}', false, false);
INSERT INTO judithsstil.products
(id, title, quantity, price, description, is_available, created_at, updated_at, category_id, sizes, is_bestseller, is_featured)
VALUES(24, 'Kombinezon czerwony błyszczący', 1, 105.00, 'Piękny  błyszczący kombinezon , rozm uni polecam od S do M , DO 173 cm wzrostu . ', true, '2025-12-01 08:37:25.015', '2025-12-01 08:37:25.015', 5, '{ONESIZE}', false, false);
INSERT INTO judithsstil.products
(id, title, quantity, price, description, is_available, created_at, updated_at, category_id, sizes, is_bestseller, is_featured)
VALUES(23, 'Kombinezon błyszczący brąz', 1, 105.00, 'Piękny  błyszczący kombinezon , rozm uni polecam od S do M , DO 173 cm wzrostu . ', true, '2025-12-01 08:34:50.397', '2025-12-01 08:34:50.397', 5, '{ONESIZE}', false, false);
INSERT INTO judithsstil.products
(id, title, quantity, price, description, is_available, created_at, updated_at, category_id, sizes, is_bestseller, is_featured)
VALUES(22, 'Kombinezon czekolada blink', 1, 107.00, 'Z diamencikami które się pięknie błyszcza pod wpływem światła .  Rozmiar uniwersalny polecam od XS/S do M . 
Max wzrost 173 cm . ', true, '2025-12-01 08:29:00.301', '2025-12-01 08:29:50.703', 5, '{undefined}', false, false);
INSERT INTO judithsstil.products
(id, title, quantity, price, description, is_available, created_at, updated_at, category_id, sizes, is_bestseller, is_featured)
VALUES(21, 'Kombinezon biały blink', 1, 107.00, 'Z diamencikami które się pięknie błyszcza pod wpływem światła .  Rozmiar uniwersalny polecam od XS/S do M . 
Max wzrost 173 cm ', true, '2025-12-01 08:26:39.301', '2025-12-01 08:26:39.301', 5, '{ONESIZE}', false, false);

select * from lsstudio.products order by updated_at desc;
select * from lsstudio.product_images;
select * from lsstudio.settings;
select * from lsstudio.product_categories;

truncate table judithsstil.settings;

SELECT banner_url, logo_url FROM judithsstil.settings where banner_url is not null and logo_url is not null LIMIT 1

alter table judithsstil.products
add column category_id INTEGER REFERENCES judithsstil.product_categories(id)

ALTER TABLE judithsstil.products ADD COLUMN sizes TEXT[];

ALTER TABLE judithsstil.products
--ADD COLUMN is_available BOOLEAN DEFAULT true,
ADD COLUMN is_bestseller BOOLEAN DEFAULT false,
ADD COLUMN is_featured BOOLEAN DEFAULT false;

-- judithsstil.products визначення

-- Drop table

-- DROP TABLE judithsstil.products;

CREATE TABLE lsstudio.products (
	id serial4 NOT NULL,
	title varchar(255) NOT NULL,
	quantity int4 DEFAULT 1 NULL,
	price numeric(10, 2) NULL,
	description text NULL,	
	category_id int4 NULL,
	sizes _text NULL,
	is_available bool DEFAULT true NULL,
	is_bestseller bool DEFAULT false NULL,
	is_featured bool DEFAULT false NULL,
	created_at timestamp DEFAULT now() NULL,
	updated_at timestamp DEFAULT now() NULL,
	
	CONSTRAINT products_pkey PRIMARY KEY (id)
);

CREATE TABLE lsstudio.product_categories (
	id serial4 NOT NULL,
	"name" text NULL,
	slug text NOT NULL,
	CONSTRAINT product_categories_pkey PRIMARY KEY (id)
);

CREATE TABLE lsstudio.product_images (
	id serial4 NOT NULL,
	product_id int4 NULL,
	image_url text NOT NULL,
	public_id varchar(255) NOT NULL,
	CONSTRAINT product_images_pkey PRIMARY KEY (id)
);


-- judithsstil.product_images зовнішні ключі

ALTER TABLE lsstudio.product_images ADD CONSTRAINT product_images_product_id_fkey FOREIGN KEY (product_id) REFERENCES lsstudio.products(id) ON DELETE CASCADE;
ALTER TABLE lsstudio.favorites ADD CONSTRAINT favorites_product_id_fkey FOREIGN KEY (product_id) REFERENCES lsstudio.products(id) ON DELETE CASCADE;

-- judithsstil.products зовнішні ключі

ALTER TABLE lsstudio.products ADD CONSTRAINT products_category_id_fkey FOREIGN KEY (category_id) REFERENCES lsstudio.product_categories(id) ON DELETE CASCADE;

-- lsstudio.products визначення

-- Drop table

DROP TABLE lsstudio.products CASCADE;

--old table from Firebase
/*CREATE TABLE lsstudio.products (
	id serial4 NOT NULL,
	title jsonb NOT NULL,
	images jsonb NOT NULL,
	quantity int4 DEFAULT 1 NULL,
	description jsonb NULL,
	is_available bool DEFAULT true NULL,
	changed_at timestamp DEFAULT now() NULL,
	updated_at timestamp DEFAULT now() NULL,
	CONSTRAINT products_pkey PRIMARY KEY (id)
);*/

