CREATE OR REPLACE FUNCTION update_info_about_wallet()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE schema.infoaboutwallet
    SET total_sum = amount * NEW.price
    WHERE crypto_id = OLD.id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_wallet_info_trigger
AFTER UPDATE OF price ON schema.cryptocurrencies
FOR EACH ROW
EXECUTE FUNCTION update_info_about_wallet();



CREATE or replace FUNCTION update_wallet_balance()
RETURNS TRIGGER as $$
BEGIN
    UPDATE schema.wallet 
    SET total_balance = total_balance - OLD.total_sum + NEW.total_sum
    where wallet_id = old.wallet_id;

    return NEW;
END;
$$ LANGUAGE PLPGSQL;


CREATE TRIGGER update_wallet_balance_trigger
AFTER UPDATE of total_sum on schema.infoaboutwallet
for EACH ROW
EXECUTE FUNCTION update_wallet_balance();



CREATE OR REPLACE FUNCTION schema.delete_user_wallet_info() RETURNS TRIGGER AS $$
BEGIN
    -- удаление всех кошельков пользователя
    DELETE FROM schema.wallet w
    WHERE w.user_id = OLD.user_id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE or replace TRIGGER delete_user_wallet_info_trigger
BEFORE DELETE ON schema.user
FOR EACH ROW
EXECUTE FUNCTION schema.delete_user_wallet_info();


CREATE OR REPLACE FUNCTION schema.delete_wallet_info() RETURNS TRIGGER AS $$
BEGIN
    -- удаление всех кошельков пользователя
    DELETE FROM schema.infoaboutwallet i
    WHERE i.wallet_id = OLD.wallet_id;


    DELETE from schema.transaction t 
    WHERE t.sender_id = OLD.wallet_id or t.reciever_id = OLD.wallet_id;

    DELETE from schema.walletchangehistory w
    WHERE w.wallet_id = OLD.wallet_id;

    RETURN OLD;

END;
$$ LANGUAGE plpgsql;

CREATE or replace TRIGGER delete_wallet_info_trigger
BEFORE DELETE ON schema.wallet
FOR EACH ROW
EXECUTE FUNCTION schema.delete_wallet_info();





INSERT into "user" (user_id, date_of_birth, name, surname)
VALUES
(666, now(), 'Guest', 'Guest');


INSERT into schema.wallet (wallet_id, user_id, name, total_balance)
VALUES
(6666, (SELECT user_id from schema."user" where name = 'Guest'), 'GuestWallet', 0);

DELETE from schema."user" where name = 'Guest';

