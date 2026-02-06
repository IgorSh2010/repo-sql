ALTER SCHEMA judithsstil OWNER TO judithsstil_user;
ALTER SCHEMA lsstudio OWNER TO lsstudio_user;

GRANT ALL ON SCHEMA judithsstil TO judithsstil_user;
GRANT ALL ON SCHEMA lsstudio TO lsstudio_user;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA judithsstil TO judithsstil_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA judithsstil TO judithsstil_user;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA judithsstil TO judithsstil_user;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA lsstudio TO lsstudio_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA lsstudio TO lsstudio_user;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA lsstudio TO lsstudio_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA judithsstil
GRANT ALL ON TABLES TO judithsstil_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA judithsstil
GRANT ALL ON SEQUENCES TO judithsstil_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA judithsstil
GRANT ALL ON FUNCTIONS TO judithsstil_user;


ALTER DEFAULT PRIVILEGES IN SCHEMA lsstudio
GRANT ALL ON TABLES TO lsstudio_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA lsstudio
GRANT ALL ON SEQUENCES TO lsstudio_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA lsstudio
GRANT ALL ON FUNCTIONS TO lsstudio_user;

GRANT SELECT, INSERT, UPDATE ON public.users TO lsstudio_user, judithsstil_user;
GRANT SELECT, INSERT, UPDATE ON public.user_logins TO lsstudio_user, judithsstil_user;
GRANT SELECT, INSERT, update, DELETE ON public.user_refresh_tokens TO lsstudio_user, judithsstil_user;

--check access
SET ROLE lsstudio_user;
SELECT * FROM judithsstil.products;  -- має працювати
SELECT * from users;
SELECT * FROM lsstudio.products;  -- має впасти з помилкою доступу
RESET ROLE;