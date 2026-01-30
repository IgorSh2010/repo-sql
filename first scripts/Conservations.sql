CREATE TABLE judithsstil.conversations (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES judithsstil.orders(id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES users(id),
    admin_id INTEGER REFERENCES users(id), -- NULL, заповнюється коли адмін відповідає вперше
    status VARCHAR(20) DEFAULT 'open', -- open, resolved, archived
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE judithsstil.messages (
    id SERIAL PRIMARY KEY,
    conversation_id INTEGER REFERENCES judithsstil.conversations(id) ON DELETE CASCADE,
    sender_id INTEGER REFERENCES users(id),
    content TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    unread_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW()
);

drop TABLE judithsstil.conversations cascade;
drop TABLE judithsstil.messages cascade;

select * from judithsstil.conversations;
select * from judithsstil.messages order by created_at asc;

alter table judithsstil.messages drop column unread_count;
alter table judithsstil.conversations add column unread_count NUMERIC;
alter table judithsstil.conversations add column title VARCHAR(300);
alter table judithsstil.conversations rename column user_id_1 to user_id;
alter table judithsstil.conversations rename column user_id_2 to admin_id;

delete from judithsstil.messages where created_at >'2025-11-21';

SELECT COUNT(*) as message_count FROM judithsstil.messages WHERE sender_id != 6 and not is_read;

update judithsstil.conversations
set title = 'Test conversation 2'
where id = 3;

INSERT INTO judithsstil.conversations
(id, order_id, user_id, admin_id, status, created_at, updated_at, unread_count)
VALUES(nextval('judithsstil.conversations_id_seq'::regclass), 55, 7, 6, 'open'::character varying, now(), now(), 0);

INSERT INTO judithsstil.messages 
(id, conversation_id, sender_id, "content", is_read, created_at)
VALUES
(nextval('judithsstil.messages_id_seq'), 1, 10, 'Dzień dobry, chciałem zapytać o status mojego zamówienia numer #1045.', false, now() - INTERVAL '1 hour'),
(nextval('judithsstil.messages_id_seq'), 1, 6, 'Dzień dobry! Już sprawdzam — chwileczkę.', false, now() - INTERVAL '1 hour'),
(nextval('judithsstil.messages_id_seq'), 1, 6, 'Widzę, że zamówienie jest opłacone i właśnie pakowane.', false, now() - INTERVAL '1 hour'),
(nextval('judithsstil.messages_id_seq'), 1, 10, 'Super, a czy mogę jeszcze zmienić adres dostawy?', false, now() - INTERVAL '1 hour'),
(nextval('judithsstil.messages_id_seq'), 1, 6, 'Jasne, proszę podać nowy adres.', false, now() - INTERVAL '1 hour'),
(nextval('judithsstil.messages_id_seq'), 1, 10, 'Warszawa, ul. Kwiatowa 22/5, 01-234.', false, now() - INTERVAL '1 hour'),
(nextval('judithsstil.messages_id_seq'), 1, 6, 'Dziękuję, już zaktualizowane.', false, now() - INTERVAL '1 hour'),
(nextval('judithsstil.messages_id_seq'), 1, 6, 'Kurier odbierze paczkę dziś do 17:00.', false, now() - INTERVAL '1 hour'),
(nextval('judithsstil.messages_id_seq'), 1, 10, 'Idealnie, dzięki za szybkie działanie.', false, now() - INTERVAL '1 hour'),
(nextval('judithsstil.messages_id_seq'), 1, 6, 'Cała przyjemność po naszej stronie!', false, now() - INTERVAL '1 hour'),
(nextval('judithsstil.messages_id_seq'), 1, 10, 'A mogę prosić jeszcze o numer śledzenia, jak już będzie dostępny?', false, now() - INTERVAL '1 hour'),
(nextval('judithsstil.messages_id_seq'), 1, 6, 'Oczywiście — wyślę go tutaj od razu po nadaniu.', false, now() - INTERVAL '1 hour'),
(nextval('judithsstil.messages_id_seq'), 1, 6, 'Paczka właśnie została nadana.', false, now() - INTERVAL '1 hour'),
(nextval('judithsstil.messages_id_seq'), 1, 6, 'Numer śledzenia: 003590234234.', false, now() - INTERVAL '1 hour'),
(nextval('judithsstil.messages_id_seq'), 1, 10, 'Mega, dzięki!', false, now() - INTERVAL '1 hour'),
(nextval('judithsstil.messages_id_seq'), 1, 10, 'O, działa — widzę, że jest już w transporcie.', false, now() - INTERVAL '1 hour'),
(nextval('judithsstil.messages_id_seq'), 1, 6, 'Tak, kurier szybko ruszył z magazynu.', false, now() - INTERVAL '1 hour'),
(nextval('judithsstil.messages_id_seq'), 1, 10, 'Szacun, obsługa na poziomie.', false, now() - INTERVAL '1 hour'),
(nextval('judithsstil.messages_id_seq'), 1, 6, 'Staramy się! Jeśli będą pytania, pisz śmiało.', false, now() - INTERVAL '1 hour'),
(nextval('judithsstil.messages_id_seq'), 1, 10, 'Nie mam więcej pytań, wszystko jasne.', false, now() - INTERVAL '1 hour'),
(nextval('judithsstil.messages_id_seq'), 1, 6, 'W takim razie życzę miłego dnia!', false, now() - INTERVAL '1 hour'),
(nextval('judithsstil.messages_id_seq'), 1, 10, 'Wzajemnie 🙂', false, now() - INTERVAL '1 hour'),
(nextval('judithsstil.messages_id_seq'), 1, 6, 'Gdy paczka dotrze, system automatycznie zaktualizuje status.', false, now() - INTERVAL '1 hour'),
(nextval('judithsstil.messages_id_seq'), 1, 10, 'W porządku, będę śledził.', false, now() - INTERVAL '1 hour'),
(nextval('judithsstil.messages_id_seq'), 1, 6, 'Dziękuję za zakupy w naszym sklepie!', false, now() - INTERVAL '1 hour');


SELECT 
                id, 
                conversation_id, 
                sender_id,
                CASE
			        WHEN sender_id = 6 THEN 'me'
			        ELSE 'interlocutor'
			    END AS participant,
                content,
                is_read,
                created_at                
            FROM judithsstil.messages 
            WHERE conversation_id = 1
            ORDER BY created_at asc;