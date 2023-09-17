---1
SELECT sender_id, type, COUNT(*) AS num_transactions
FROM schema.Transaction
GROUP BY sender_id, type
HAVING COUNT(*) > 0;
--- Получить количество транзакций каждого типа 
---по каждому пользователю
--- у которых есть транзакции каждого типа:

---2
SELECT u.user_id, u.name, u.surname, MAX(t.date_time) AS last_transaction_date
FROM schema.User u
JOIN schema.wallet w on w.user_id = u.user_id
JOIN schema.Transaction t ON w.wallet_id = t.sender_id OR w.wallet_id = t.reciever_id
GROUP BY w.wallet_id, u.user_id
ORDER BY last_transaction_date DESC;
---Получить список пользователей, 
---отсортированный по дате их последней транзакции:

---3
SELECT CONCAT(sender.name, ' ', sender.surname) AS sender_name,
       crypto.name AS crypto_name,
       COUNT(*) OVER (PARTITION BY sender_id, crypto_id) AS num_transactions
FROM schema.Transaction
JOIN schema.wallet w on Transaction.sender_id = w.wallet_id
JOIN schema.User sender on sender.user_id = w.user_id
-- JOIN schema.User AS reciever ON Transaction.reciever_id = reciever.user_id
JOIN schema.cryptocurrencies AS crypto ON Transaction.crypto_id = crypto.id;

--- Получить общее количество отправленных транзакций по каждому 
---пользователю в разрезе каждой криптовалюты:


---4
SELECT CONCAT(sender.name, ' ', sender.surname) as sender_name, sender_id, type, COUNT(*) AS num_transactions,
       RANK() OVER (PARTITION BY sender_id ORDER BY COUNT(*) DESC) AS rank_num_transactions
FROM schema.Transaction
JOIN schema.wallet w on schema.transaction.sender_id = w.wallet_id
JOIN schema.User as sender ON w.user_id = sender.user_id
GROUP BY sender_id, type, sender.name, sender.surname
ORDER BY rank_num_transactions;

--- Получить ранжированный список пользователей по количеству транзакций каждого типа, 
---сгруппированных по каждому пользователю:


---5
SELECT u.user_id, u.name, u.surname, 
       RANK() OVER (ORDER BY COUNT(*) DESC) AS rank_num_transactions
FROM schema.Transaction t
JOIN schema.wallet w on t.sender_id = w.wallet_id or t.reciever_id = w.wallet_id
JOIN schema.User u ON w.user_id = u.user_id
GROUP BY u.user_id
ORDER BY rank_num_transactions;

---Получить ранжированный список 
---пользователей по общему количеству их транзакций,
--- отсортированный по убыванию количества:

---6
SELECT type, 
       AVG(price) AS avg_price,
       percentile_cont(0.5) WITHIN GROUP (ORDER BY price) AS median_price
FROM schema.Transaction
GROUP BY type;
--- Получить среднюю цену всех транзакций и 
---медианное значение цены каждого типа:


