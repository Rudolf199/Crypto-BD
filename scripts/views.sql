CREATE VIEW Wallets_and_Cryptocurrencies AS 
SELECT 
    CONCAT(u.name, ' ', u.surname) AS Username,
    w.name AS wallet_name,
    c.name AS cryptocurrency,
    ---i.amount AS amount,
    to_char(i.amount, '9,999,999,999') as amount,
    to_char(i.total_sum, '9,999,999,999.99') AS total_sum
FROM Wallet w
JOIN InfoAboutWallet i ON w.wallet_id = i.wallet_id
JOIN schema."user" u ON u.user_id = w.user_id
JOIN schema.cryptocurrencies c ON i.crypto_id = c.id
ORDER BY w.user_id;
--- Это представление - сводная таблица для отслеживания количества криптовалют на различных кошельках пользователей


CREATE or replace VIEW Wallets_and_Balances AS 
SELECT 
    CONCAT(SUBSTRING(u.name, 1, 1), REPEAT('*', LENGTH(u.name) - 1), ' ', 
           SUBSTRING(u.surname, 1, 1), REPEAT('*', LENGTH(u.surname) - 1)) AS user_masked_name,
    CONCAT(SUBSTRING(w.name, 1, 3), REPEAT('#', 10)) AS wallet_name,
    CONCAT(SUBSTRING(to_char(w.wallet_id::numeric, '9999999999999999'), 1, 8), REPEAT('*', LENGTH(to_char(w.wallet_id::numeric, '9999999999')))) AS WALLET_ID,
    TO_CHAR(ROUND(w.total_balance::numeric, 2), 'FM999G999G999G999D00') AS balance
    ---c.symbol as CryptoSymbol
FROM schema.User u
JOIN schema.Wallet w ON u.user_id = w.user_id
---JOIN schema.InfoAboutWallet i ON w.wallet_id = i.wallet_id
---JOIN schema.cryptocurrencies c ON i.crypto_id = c.id
ORDER BY w.user_id;
--- Это представление показывает балансы пользователей по кошелькам, но скрывая их личные данные

CREATE or replace VIEW Transaction_history_by_user AS 
SELECT 
    ---u.user_id,
    CONCAT(u.name, ' ', COALESCE(u.surname, '')) AS user_name,
    t.transaction_id, 
    c.name AS cryptocurrency,
    t.date_time,
    t.price,
    t.fee,
    t.type
FROM schema."user" u
JOIN schema.wallet w on w.user_id = u.user_id
JOIN schema.transaction t ON t.sender_id = w.wallet_id OR t.reciever_id = w.wallet_id
JOIN schema.cryptocurrencies c ON t.crypto_id = c.id
ORDER BY u.user_id, t.date_time DESC;
--- Это представление показывает история транзакций по каждому пользователю

CREATE or replace VIEW Transactions_with_masked_personal_data AS 
SELECT 
    t.transaction_id, 
    CONCAT(LEFT(u1.name, 1), REPEAT('*', 2*LENGTH(u1.name)-1)) AS sender_name,
    CONCAT(LEFT(u2.name, 1), REPEAT('*', 2*LENGTH(u2.name)-1)) AS receiver_name,
    c.name AS cryptocurrency,
    t.date_time,
    t.price,
    t.fee,
    t.type
FROM schema.transaction t
JOIN schema.wallet w1 on w1.wallet_id = t.sender_id
JOIN schema.wallet w2 on w2.wallet_id = t.reciever_id
JOIN schema."user" u1 ON w1.user_id = u1.user_id
JOIN schema."user" u2 ON w2.user_id = u2.user_id
JOIN schema.cryptocurrencies c ON t.crypto_id = c.id;
--- Это представление показывает все подробности всех транзакций, но с замаскированными личными данными


CREATE or replace VIEW Transaction_Stats_By_Category AS 
SELECT 
    Crypto.name AS category,
    Crypto.symbol as Currency,
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN t.type = 'buy' THEN t.price ELSE 0 END) AS total_buy_price,
    SUM(CASE WHEN t.type = 'sell' THEN t.price ELSE 0 END) AS total_sell_price
FROM 
    (SELECT * FROM Transaction) AS t
JOIN 
    cryptocurrencies Crypto ON t.crypto_id = Crypto.id
GROUP BY 
    category, Currency;
--- Это представление показывает обчую статистику по всем категориям транзакций по всем криптовалютам


CREATE or replace VIEW Wallet_Crypto_Assets AS 
SELECT 
    w.user_id, 
    CONCAT(u.name, ' ', COALESCE(u.surname, '')) AS user_name,
    COUNT(i.crypto_id) AS total_cryptocurrencies, 
    SUM(i.amount * c.price) AS total_crypto_assets 
FROM Wallet w 
LEFT JOIN InfoAboutWallet i ON w.wallet_id = i.wallet_id
LEFT JOIN "user" u on w.user_id = u.user_id
LEFT JOIN cryptocurrencies c ON i.crypto_id = c.id 
GROUP BY w.user_id, user_name;
--- Это представление показывает сколькими типами криптовалютных активов обладает пользователь и сами активы
















