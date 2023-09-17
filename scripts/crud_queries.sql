UPDATE schema.User SET date_of_birth = '1966-01-01' WHERE user_id = 1;
--- 1.Поменял дату рождения пользователя с индексом 1


UPDATE schema.User SET surname = 'Tuchel' where surname = 'Muller';
--- 2.Поменял фамилию пользователей с фамилией Muller на Tuchel

DELETE FROM schema.Miner WHERE name = 'Bitmain Antminer T19';
--- 3.Удалил из таблицы Miner майнер с именем Bitmain Antminer T19

SELECT * FROM schema.User WHERE date_of_birth < '1990-01-01';
--- 4.Получаем пользователей, которые родились до 1990-01-01



INSERT INTO schema.Miner (miner_id, crypto_id, name, efficiency)
VALUES
(34, 6, 'MIPT fake miner', 19000);
--- 5.Добавляем в таблицу Miner майнер с такими параметрами


INSERT INTO schema.User (user_id, date_of_birth, name, surname)
VALUES
(11, '2003-01-01', 'Gurgen', 'Norekyan'),
(22, '2003-01-01', 'Vahan', 'Harutyunyan'),
(777, '2003-12-23', 'Tigran', 'Arakelyan');
--- 6.Добавляем в таблицу User следующих пользователей


SELECT name as Name, surname as Surname from schema.User where surname = 'Norekyan';
--- 7.Выбрали из таблицы User пользователей с фамилией Norekyan


SELECT name as Miner_name, efficiency from schema.miner where efficiency > 200;
--- 8.Выбрали из таблицы Miner майнеры с эффективностью больше 200(скоростью майнинга крипты в час)
