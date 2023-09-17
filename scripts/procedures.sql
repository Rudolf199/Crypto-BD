

--- Процедура изменения цены криптовалюты, на вход принимает идентификатор валюты и новую цену
CREATE OR REPLACE PROCEDURE schema.update_crypto_price(
    IN change_crypto_id NUMERIC,
    IN new_price NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    wallet_record RECORD;
    wallet_balance NUMERIC;
    changes_id NUMERIC;
BEGIN
    --- Теперь он работает через триггеры :)
     -- update the cryptocurrency price in the cryptocurrencies table
    UPDATE schema.cryptocurrencies
    SET change_24h = change_24h + (price - new_price), price = new_price
    WHERE id = change_crypto_id;
END;
$$;



--- Пример вызова изменения цены для BTC

call update_crypto_price(366279, 100000);


--- Процедура проведения транзакции, на вход принимает информацию о сделке
CREATE OR REPLACE PROCEDURE schema.process_transaction(
    --- IN transaction_ids NUMERIC,
    IN sender_ids NUMERIC,
    IN receiver_ids NUMERIC,
    IN crypto_ids NUMERIC,
    IN date_times TIMESTAMP,
    IN prices NUMERIC,
    IN fees NUMERIC,
    IN types VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
DECLARE
transaction_ids NUMERIC;
required_amount NUMERIC;
actual_amount NUMERIC;
changes_id NUMERIC;
wallet_num numeric;
wallet_sum NUMERIC;
sender_wallet NUMERIC;
receiver_wallet NUMERIC;
BEGIN
    SELECT COALESCE(MAX(transaction_id), 0) + 1 INTO transaction_ids FROM schema.transaction;
    required_amount := prices / (SELECT price from cryptocurrencies c where crypto_ids = c.id);
    select amount into actual_amount 
    from infoaboutwallet i  
    join wallet w on i.wallet_id = w.wallet_id 
    where w.user_id = sender_ids;
    IF (actual_amount < required_amount) THEN
    RAISE EXCEPTION 'Не достаточно средств';
    END IF;

    ---------------
    if (types = 'sell' AND actual_amount >= required_amount) then
        -- Обновляем информацию о балансе отправителя

        SELECT COALESCE(MAX(change_id), 0) + 1 INTO changes_id FROM schema.WalletChangeHistory;


        with wallet_mod as (
        UPDATE schema.wallet
        SET total_balance = total_balance - prices
        WHERE user_id = sender_ids AND EXISTS (
            SELECT 1 FROM schema.infoaboutwallet
            WHERE wallet.wallet_id = infoaboutwallet.wallet_id
            AND infoaboutwallet.crypto_id = crypto_ids
        )returning wallet_id, total_balance),
        inserting as (
            INSERT INTO schema.WalletChangeHistory (change_id, wallet_id, balance_before, valid_to, change_date)
        values(changes_id, (SELECT w.wallet_id from wallet_mod w), (SELECT w.total_balance from wallet_mod w), now() + INTERVAL '1 hour', now())
        )
        SELECT w.wallet_id INTO sender_wallet from wallet_mod w;


        
        --- Обновляем информацию о кошельке по данной валюте у отправителя
        UPDATE schema.infoaboutwallet i
        SET amount = amount - ROUND(prices / (SELECT price from cryptocurrencies where crypto_id = crypto_ids LIMIT 1), 2),
        total_sum = amount * (SELECT price from cryptocurrencies WHERE crypto_id = crypto_ids LIMIT 1)
        WHERE wallet_id IN (
            --- SELECT wallet_id FROM schema.wallet
            --- WHERE user_id = sender_ids
            SELECT w.wallet_id FROM schema.wallet w
            JOIN schema.infoaboutwallet i ON w.wallet_id = i.wallet_id
            WHERE w.user_id = sender_ids AND i.crypto_id = crypto_ids
        ) AND crypto_ids = i.crypto_id;


        INSERT INTO schema.InfoAboutWallet (wallet_id, crypto_id, amount, total_sum)
        VALUES ((SELECT w.wallet_id from schema.wallet w where w.user_id = receiver_ids LIMIT 1), crypto_ids, 0, 0)
        ON CONFLICT (wallet_id, crypto_id) DO NOTHING;

        --- Обновляем информацию у кошельке по этой валюте, у получателя
        UPDATE schema.infoaboutwallet i
        SET amount = amount + ROUND(prices / (SELECT price from cryptocurrencies where crypto_id = crypto_ids LIMIT 1), 2), 
        total_sum = amount * (SELECT price from cryptocurrencies WHERE crypto_id = crypto_ids LIMIT 1)
        WHERE wallet_id IN (
            SELECT w.wallet_id FROM schema.wallet w
            join schema.infoaboutwallet i on w.wallet_id = i.wallet_id
            WHERE w.user_id = receiver_ids and i.crypto_id = crypto_ids
        ) AND crypto_ids = i.crypto_id;


        -- Обновляем информацию о балансе получателя
        SELECT COALESCE(MAX(change_id), 0) + 1 INTO changes_id FROM schema.WalletChangeHistory;
        with wallet_mod as (
        UPDATE schema.wallet
        SET total_balance = total_balance + prices - fees
        WHERE user_id = receiver_ids AND EXISTS (
            SELECT 1 FROM schema.infoaboutwallet
            WHERE wallet.wallet_id = infoaboutwallet.wallet_id
            AND infoaboutwallet.crypto_id = crypto_ids
        )RETURNING wallet_id, total_balance),
        --- INSERT INTO schema.WalletChangeHistory (change_id, wallet_id, balance_before, valid_to, change_date)
        --- values(changes_id, (SELECT w.wallet_id from wallet_mod w), (SELECT w.total_balance from wallet_mod w), now() + INTERVAL '1 day', now());
        inserting as (
            INSERT INTO schema.WalletChangeHistory (change_id, wallet_id, balance_before, valid_to, change_date)
        values(changes_id, (SELECT w.wallet_id from wallet_mod w), (SELECT w.total_balance from wallet_mod w), now() + INTERVAL '1 day', now())
        )
        SELECT w.wallet_id INTO receiver_wallet from wallet_mod w;


        -- Добавляем информацию о транзакции в таблицу schema.transaction
        INSERT INTO schema.transaction(
        transaction_id, sender_id, reciever_id, crypto_id, date_time, price, fee, type
        )
        VALUES(
            transaction_ids, sender_wallet, receiver_wallet, crypto_ids, date_times, prices, fees, types
        );
    end if;

    ------

    
    if (types = 'buy') then

    SELECT COALESCE(MAX(change_id), 0) + 1 INTO changes_id FROM schema.WalletChangeHistory;


    -- Обновляем информацию о балансе отправителя
    with wallet_mod as (
    UPDATE schema.wallet
    SET total_balance = total_balance + prices - fees
    WHERE user_id = sender_id AND EXISTS (
        SELECT 1 FROM schema.infoaboutwallet
        WHERE wallet.wallet_id = infoaboutwallet.wallet_id
        AND infoaboutwallet.crypto_id = crypto_ids
    )RETURNING wallet_id, total_balance),
    inserting as (
            INSERT INTO schema.WalletChangeHistory (change_id, wallet_id, balance_before, valid_to, change_date)
            values(changes_id, (SELECT w.wallet_id from wallet_mod w), (SELECT w.total_balance from wallet_mod w), now() + INTERVAL '1 hour', now())
    )
    SELECT w.wallet_id INTO sender_wallet from wallet_mod w;


    INSERT INTO schema.InfoAboutWallet (wallet_id, crypto_id, amount, total_sum)
    VALUES ((SELECT w.wallet_id from schema.wallet w where w.user_id = sender_ids LIMIT 1), crypto_ids, 0, 0)
    ON CONFLICT (wallet_id, crypto_id) DO NOTHING;


    UPDATE schema.infoaboutwallet i 
    SET amount = amount + ROUND(prices / (SELECT price from cryptocurrencies where crypto_ids = crypto_id LIMIT 1), 2),
    total_sum = amount * (SELECT price from cryptocurrencies WHERE crypto_id = crypto_ids LIMIT 1)
    WHERE wallet_id IN (
        SELECT w.wallet_id FROM schema.wallet w
        join schema.infoaboutwallet i on w.wallet_id = i.wallet_id
        WHERE w.user_id = sender_ids and i.crypto_id = crypto_ids
    ) AND crypto_ids = i.crypto_id;
    



    UPDATE schema.infoaboutwallet i
    SET amount = amount - ROUND(prices / (SELECT price from cryptocurrencies where crypto_ids = crypto_id LIMIT 1), 2),
    total_sum = amount * (SELECT price from cryptocurrencies where crypto_id = crypto_ids LIMIT 1)
    WHERE wallet_id IN (
        SELECT w.wallet_id FROM schema.wallet w
        join schema.infoaboutwallet i on w.wallet_id = i.wallet_id
        WHERE w.user_id = receiver_ids and i.crypto_id = crypto_ids
    ) AND crypto_ids = i.crypto_id;
    
    SELECT COALESCE(MAX(change_id), 0) + 1 INTO changes_id FROM schema.WalletChangeHistory;
    -- Обновляем информацию о балансе получателя
    with wallet_mod as (
    UPDATE schema.wallet
    SET total_balance = total_balance + prices
    WHERE user_id = receiver_id AND EXISTS (
        SELECT 1 FROM schema.infoaboutwallet
        WHERE wallet.wallet_id = infoaboutwallet.wallet_id
        AND infoaboutwallet.crypto_id = crypto_ids
    )RETURNING wallet_id, total_balance),
    --- INSERT into schema.walletchangehistory (change_id, wallet_id, balance_before, valid_to, change_date)
    --- VALUES(changes_id, (SELECT w.wallet_id from wallet_mod w),
    --- (SELECT w.total_balance from wallet_mod w), now() + INTERVAL '1 hour', now());
    inserting as (
            INSERT INTO schema.WalletChangeHistory (change_id, wallet_id, balance_before, valid_to, change_date)
            values(changes_id, (SELECT w.wallet_id from wallet_mod w), (SELECT w.total_balance from wallet_mod w), now() + INTERVAL '1 hour', now())
    )
    SELECT w.wallet_id INTO receiver_wallet from wallet_mod w;

    
    -- Добавляем информацию о транзакции в таблицу schema.transaction
    INSERT INTO schema.transaction(
        transaction_id, sender_id, receiver_id, crypto_id, date_time, price, fee, type
    )
    VALUES(
        transaction_ids, sender_wallet, receiver_wallet, crypto_ids, date_times, prices, fees, types
    );
    end IF;


    --------------

    if (types = 'gift') then

    SELECT COALESCE(MAX(change_id), 0) + 1 INTO changes_id FROM schema.WalletChangeHistory;


    -- Обновляем информацию о балансе отправителя
    with wallet_mod as (
    UPDATE schema.wallet
    SET total_balance = total_balance - prices - fees
    WHERE user_id = sender_id AND EXISTS (
        SELECT 1 FROM schema.infoaboutwallet
        WHERE wallet.wallet_id = infoaboutwallet.wallet_id
        AND infoaboutwallet.crypto_id = crypto_ids
    )RETURNING wallet_id, total_balance),
    inserting as (
            INSERT INTO schema.WalletChangeHistory (change_id, wallet_id, balance_before, valid_to, change_date)
            values(changes_id, (SELECT w.wallet_id from wallet_mod w), (SELECT w.total_balance from wallet_mod w), now() + INTERVAL '1 hour', now())
    )
    SELECT w.wallet_id INTO sender_wallet from wallet_mod w;


    UPDATE schema.infoaboutwallet i 
    SET amount = amount - ROUND(prices / (SELECT price from cryptocurrencies where crypto_ids = crypto_id LIMIT 1), 2),
    total_sum = amount * (SELECT price from cryptocurrencies WHERE crypto_id = crypto_ids LIMIT 1)
    WHERE wallet_id IN (
        SELECT w.wallet_id FROM schema.wallet w
        join schema.infoaboutwallet i on w.wallet_id = i.wallet_id
        WHERE w.user_id = sender_ids and i.crypto_id = crypto_ids
    ) AND crypto_ids = i.crypto_id;
    

    INSERT INTO schema.InfoAboutWallet (wallet_id, crypto_id, amount, total_sum)
    VALUES ((SELECT w.wallet_id from schema.wallet w where w.user_id = receiver_ids LIMIT 1), crypto_ids, 0, 0)
    ON CONFLICT (wallet_id, crypto_id) DO NOTHING;

    UPDATE schema.infoaboutwallet i
    SET amount = amount + ROUND(prices / (SELECT price from cryptocurrencies where crypto_ids = crypto_id LIMIT 1), 2),
    total_sum = amount * (SELECT price from cryptocurrencies where crypto_id = crypto_ids LIMIT 1)
    WHERE wallet_id IN (
        SELECT w.wallet_id FROM schema.wallet w
        join schema.infoaboutwallet i on w.wallet_id = i.wallet_id
        WHERE w.user_id = receiver_ids and i.crypto_id = crypto_ids
    ) AND crypto_ids = i.crypto_id;
    

    SELECT COALESCE(MAX(change_id), 0) + 1 INTO changes_id FROM schema.WalletChangeHistory;
    -- Обновляем информацию о балансе получателя
    with wallet_mod as (
    UPDATE schema.wallet
    SET total_balance = total_balance + prices - fees
    WHERE user_id = receiver_id AND EXISTS (
        SELECT 1 FROM schema.infoaboutwallet
        WHERE wallet.wallet_id = infoaboutwallet.wallet_id
        AND infoaboutwallet.crypto_id = crypto_ids
    )RETURNING wallet_id, total_balance),
    inserting as (
            INSERT INTO schema.WalletChangeHistory (change_id, wallet_id, balance_before, valid_to, change_date)
            values(changes_id, (SELECT w.wallet_id from wallet_mod w), (SELECT w.total_balance from wallet_mod w), now() + INTERVAL '1 day', now())
    )
    SELECT w.wallet_id INTO receiver_wallet from wallet_mod w;

    
    -- Добавляем информацию о транзакции в таблицу schema.transaction
    INSERT INTO schema.transaction(
        transaction_id, sender_id, receiver_id, crypto_id, date_time, price, fee, type
    )
    VALUES(
        transaction_ids, sender_wallet, receiver_wallet, crypto_ids, date_times, prices, fees, types
    );
    end IF;
    ----------------
END;
$$;






call process_transaction(777::numeric, 999::NUMERIC, 366279::NUMERIC, now()::TIMESTAMP, 720000::numeric, 2000::numeric, 'sell'::VARCHAR(20))