
CREATE SCHEMA IF NOT EXISTS schema;

CREATE TABLE if not exists schema.cryptocurrencies (
   id            NUMERIC                PRIMARY KEY,
   name          VARCHAR(50)           NOT NULL,
   symbol        VARCHAR(50)           NOT NULL,
   price         NUMERIC                NOT NULL,
   market_cap    NUMERIC,
   volume_24h    NUMERIC,
   change_24h    NUMERIC
);
CREATE TABLE if not exists schema.User (
    user_id       NUMERIC PRIMARY KEY,
    date_of_birth TIMESTAMP,
    name          VARCHAR(50) NOT NULL,
    surname       VARCHAR(50)
);
CREATE TABLE if not exists schema.Wallet (
   wallet_id     NUMERIC               PRIMARY KEY,
   user_id       NUMERIC               NOT NULL REFERENCES schema.User(user_id),
   name          VARCHAR(20)          NOT NULL,
   total_balance NUMERIC               NOT NULL
);

CREATE TABLE if not exists schema.InfoAboutWallet (
   wallet_id  NUMERIC NOT NULL,
   crypto_id  NUMERIC NOT NULL,
   amount     NUMERIC NOT NULL,
   total_sum  numeric NOT NULL,

   CONSTRAINT pk_InfoAboutWallet PRIMARY KEY (wallet_id, crypto_id),
   CONSTRAINT fk_InfoAboutWallet_wallet FOREIGN KEY (wallet_id)
       REFERENCES schema.Wallet(wallet_id) ON DELETE CASCADE,
   CONSTRAINT fk_InfoAboutWallet_crypto FOREIGN KEY (crypto_id)
       REFERENCES schema.cryptocurrencies(id) ON DELETE CASCADE
);

CREATE TABLE if not exists schema.Miner (
  miner_id NUMERIC PRIMARY KEY,
  crypto_id NUMERIC REFERENCES schema.cryptocurrencies(id),
  name VARCHAR(50) DEFAULT NULL,
  efficiency NUMERIC NOT NULL
);


CREATE TABLE if not exists schema.WalletChangeHistory (
  change_id NUMERIC PRIMARY KEY,
  wallet_id NUMERIC NOT NULL REFERENCES schema.Wallet(wallet_id),
  balance_before NUMERIC NOT NULL,
  valid_to TIMESTAMP NOT NULL,
  change_date TIMESTAMP NOT NULL
);


CREATE TABLE if not exists schema.Transaction (
    transaction_id NUMERIC PRIMARY KEY,
    sender_id NUMERIC NOT NULL,
    reciever_id NUMERIC NOT NULL,
    crypto_id NUMERIC NOT NULL,
    date_time TIMESTAMP NOT NULL,
    price NUMERIC NOT NULL,
    fee NUMERIC NOT NULL,
    type VARCHAR(20) NOT NULL,
    FOREIGN KEY (sender_id) REFERENCES schema.Wallet(wallet_id),
    FOREIGN KEY (reciever_id) REFERENCES schema.Wallet(wallet_id),
    FOREIGN KEY (crypto_id) REFERENCES schema.cryptocurrencies(id)
);








INSERT INTO cryptocurrencies (id, name, symbol, price, market_cap, volume_24h, change_24h) 
VALUES 
(366279, 'Bitcoin', 'BTC', 59000, 1000000, 500000, 122),
(432970, 'Ethereum', 'ETH', 4000, 50000000, 20000, 341),
(982155, 'Binance Coin', 'BNB', 600, 900000, 100000, 52),
(173246, 'Cardano', 'ADA', 2, 5000000, 500000, 0.3),
(648191, 'Dogecoin', 'DOGE', 0.4, 50000000, 1000000, 1),
(518983, 'XRP', 'XRP', 1.5, 70000000, 50000000, 1),
(219864, 'Polkadot', 'DOT', 40, 4000000, 50000000, 1),
(795041, 'Uniswap', 'UNI', 50, 2000000, 10000000, 3),
(434554, 'Chainlink', 'LINK', 30, 15000000, 50000000, 3),
(234332, 'Litecoin', 'LTC', 300, 200000, 200000, 2);


INSERT INTO schema.User (user_id, date_of_birth, name, surname) 
VALUES 
(1322332, '1985-01-01', 'Suren', 'Norekyan'),
(2345337572, '1990-05-12', 'Erling', 'Haaland'),
(3344633433, '1988-09-30', 'Kyllian', 'Mbappe'),
(46838738, '1995-03-25', 'Diego', 'Maradona'),
(5487384743, '1992-12-10', 'David', 'Bekham'),
(658374749, '1987-05-27', 'Lionel', 'Messi'),
(7322, '1998-11-20', 'Joshua', 'Kimmich'),
(999, '1989-02-28', 'Olivier', 'Giroud'),
(777, '1993-08-05', 'Cristiano', 'Ronaldo'),
(10011, '1996-04-18', 'Thomas', 'Muller');

INSERT INTO schema.Wallet (wallet_id, user_id, name, total_balance)
VALUES
(1655789698804432, 1322332, 'Surens wallet', 50000),
(2389832773052097, 2345337572, 'Ethereum Wallet', 24000),
(8534200078101289, 7322, 'Litecoin Wallet', 10000),
(1295668546235311, 1322332, 'Bitcoin Wallet 1337', 750000),
(7642687175103036, 658374749, 'Argentina', 1500000000),
(6305379463610206, 46838738, 'England', 500000000),
(1463290514172675, 10011, 'FC Barcelona salary', 10000000),
(6420180785088938, 3344633433, 'For beer', 2000),
(7409923867255704, 999, 'France Wallet', 3500000),
(5698644245119293, 777, 'Al Nassr salary', 50000000);

INSERT INTO schema.InfoAboutWallet (wallet_id, crypto_id, amount, total_sum)
VALUES
((SELECT wallet_id from schema.wallet where name = 'Surens wallet'), (SELECT id FROM schema.Cryptocurrencies WHERE symbol = 'ETH'), 12, 48000);

INSERT INTO schema.InfoAboutWallet (wallet_id, crypto_id, amount, total_sum)
VALUES
((SELECT wallet_id from schema.wallet where name = 'Ethereum Wallet'), (SELECT id FROM schema.Cryptocurrencies WHERE symbol = 'ETH'), 12, 48000), 
((SELECT wallet_id from schema.wallet where name = 'Surens wallet'), (SELECT id FROM schema.Cryptocurrencies WHERE symbol = 'ADA'), 1000, 2000),
((SELECT wallet_id from schema.wallet where name = 'Litecoin Wallet'), (SELECT id FROM schema.Cryptocurrencies WHERE symbol = 'LTC'), 30, 9000),
((SELECT wallet_id from schema.wallet where name = 'Litecoin Wallet'), (SELECT id FROM schema.Cryptocurrencies WHERE symbol = 'UNI'), 20, 1000),
((SELECT wallet_id from schema.wallet where name = 'Al Nassr salary'), (SELECT id FROM schema.Cryptocurrencies WHERE symbol = 'BTC'), 847, 49973000),
((SELECT wallet_id from schema.wallet where name = 'FC Barcelona salary'), (SELECT id FROM schema.Cryptocurrencies WHERE symbol = 'BNB'), 16600, 9960000),
((SELECT wallet_id from schema.wallet where name = 'England'), (SELECT id FROM schema.Cryptocurrencies WHERE symbol = 'DOGE'), 1250000000, 500000000),
((SELECT wallet_id from schema.wallet where name = 'For beer'), (SELECT id FROM schema.Cryptocurrencies WHERE symbol = 'XRP'), 1300, 1950),
((SELECT wallet_id from schema.wallet where name = 'Argentina'), (SELECT id FROM schema.Cryptocurrencies WHERE symbol = 'DOT'), 37500000, 1500000000);


INSERT INTO schema.Miner (miner_id, crypto_id, name, efficiency)
VALUES
(133, (SELECT id from schema.cryptocurrencies where symbol = 'DOGE'), 'Antminer S9', 1500),
(234, (SELECT id from schema.cryptocurrencies where symbol = 'UNI'), 'AvalonMiner 741', 60),
(398, (SELECT id from schema.cryptocurrencies where symbol = 'BTC'), 'Bitmain Antminer L3+', 0.5),
(410, (SELEct id from schema.cryptocurrencies where symbol = 'ETH'), 'Bitmain Antminer S19 Pro', 3),
(555, (SELECT id from schema.cryptocurrencies where symbol = 'BNB'), 'Nvidia GeForce GTX 1080 Ti', 32),
(67, (SELECT id from schema.cryptocurrencies where symbol = 'LTC'), 'AMD Radeon RX 580', 69),
(77, (SELECT id from schema.cryptocurrencies where symbol = 'ADA'), 'Bitmain Antminer T19', 84),
(80, (SELECT id from schema.cryptocurrencies where symbol = 'LINK'), 'Bitmain Antminer S17 Pro', 56),
(99, (SELECT id from schema.cryptocurrencies where symbol = 'LINK'), 'MicroBT Whatsminer M30S', 5),
(100, (SELECT id from schema.cryptocurrencies where symbol = 'XRP'), 'Bitmain Antminer E9', 30);


INSERT INTO schema.WalletChangeHistory (change_id, wallet_id, balance_before, valid_to, change_date)
VALUES
(443542, (select wallet_id from schema.wallet where name = 'Surens wallet'), 1023200, '2023-05-01 12:50:43', '2020-11-02 10:00:00'),
(23464, (SELECT wallet_id from schema.wallet where name = 'England'), 800000, '2023-05-02 23:59:59', '2019-05-02 14:30:00'),
(45675653, (SELECT wallet_id from schema.wallet where name ='Argentina'), 300000000, '2023-05-01 23:59:59', '2021-05-01 11:45:00'),
(435674, (SELECT wallet_id from schema.wallet where name = 'For beer'), 0, '2023-05-02 23:59:59', '2023-05-02 18:00:00'),
(76675, (SELECT wallet_id from schema.wallet where name = 'FC Barcelona salary'), 30000000, '2023-05-01 23:59:59', '2023-05-01 09:15:00'),
(686475, (SELECT wallet_id from schema.wallet where name = 'Al Nassr salary'), 0, '2023-05-03 23:59:59', '2023-05-03 12:00:00'),
(706848, (SELECT wallet_id from schema.wallet where name = 'Surens wallet'), 10000000, '2023-05-01 23:59:59', '2023-05-01 12:50:43'),
(882727, (SELECT wallet_id from schema.wallet where name = 'France Wallet'), 150000, '2023-05-02 23:59:59', '2023-05-02 10:30:00'),
(948326, (SELECT wallet_id from schema.wallet where name = 'Bitcoin Wallet 1337'), 4000, '2023-05-01 23:59:59', '2023-05-01 13:20:00'),
(1018263, (SELECT wallet_id from schema.wallet where name = 'Argentina'), 200000000, '2023-05-03 23:59:59', '2023-05-03 09:00:00');





SELECT wallet_id from schema.wallet where name = 'Surens wallet';

SELECT w.wallet_id from schema.wallet w where w.name = 'Bitcoin Wallet 1337';

INSERT INTO schema.Transaction (transaction_id, sender_id, reciever_id, crypto_id, date_time, price, fee, type)
VALUES
  (123675546424343, (SELECT w.wallet_id from schema.wallet w where w.name = 'Surens wallet'), (SELECT w.wallet_id from schema.wallet w where w.name = 'Bitcoin Wallet 1337'), (SELECT id from schema.cryptocurrencies where symbol = 'ETH'), '2023-05-01 15:30:00', 1000, 50, 'buy');

INSERT INTO schema.Transaction (transaction_id, sender_id, reciever_id, crypto_id, date_time, price, fee, type)
VALUES
  (258264728473, (SELECT wallet_id from schema.wallet where name = 'England'), (SELECT wallet_id from schema.wallet where name = 'Surens wallet'), (SELECT id from schema.cryptocurrencies where symbol = 'BTC'), '2023-06-02 11:23:22', 1000000, 500, 'sell'),
  (3482748935883, (SELECT wallet_id from schema.wallet where name = 'Al Nassr salary'), (SELECT wallet_id from schema.wallet where name = 'FC Barcelona salary'), (SELECT id from schema.cryptocurrencies where symbol = 'BNB'), '2023-05-15 09:45:00', 500, 20, 'buy'),
  (468759283762, (SELECT wallet_id from schema.wallet where name = 'Surens wallet'), (SELECT wallet_id from schema.wallet where name = 'For beer'), (SELECT id from schema.cryptocurrencies where symbol = 'DOGE'), '2023-06-01 16:10:12', 200, 5, 'sell'),
  (5658357398758389, (SELECT wallet_id from schema.wallet where name = 'England'), (SELECT wallet_id from schema.wallet where name = 'Al Nassr salary'), (SELECT id from schema.cryptocurrencies where symbol = 'XRP'), '2023-05-03 14:23:45', 800, 40, 'buy'),
  (659827482744, (SELECT wallet_id from schema.wallet where name = 'Al Nassr salary'), (SELECT wallet_id from schema.wallet where name = 'Argentina'), (SELECT id from schema.cryptocurrencies where symbol = 'DOT'), '2023-05-06 12:30:00', 1500, 75, 'sell'),
  (6373434342, (SELECT wallet_id from schema.wallet where name = 'Bitcoin Wallet 1337'), (SELECT wallet_id from schema.wallet where name = 'Litecoin Wallet'), (SELECT id from schema.cryptocurrencies where symbol = 'UNI'), '2023-05-12 18:15:30', 400, 10, 'buy'),
  (8584873743737, (SELECT wallet_id from schema.wallet where name = 'France Wallet'), (SELECT wallet_id from schema.wallet where name = 'FC Barcelona salary'), (SELECT id from schema.cryptocurrencies where symbol = 'LTC'), '2023-05-20 10:00:00', 0, 0, 'gift'),
  (932846213824618, (SELECT wallet_id from schema.wallet where name = 'Argentina'), (SELECT wallet_id from schema.wallet where name = 'England'), (SELECT id from schema.cryptocurrencies where symbol = 'ETH'), '2023-05-08 21:00:00', 700, 35, 'buy'),
  (1038364728383892, (SELECT wallet_id from schema.wallet where name = 'For beer'), (SELECT wallet_id from schema.wallet where name = 'France Wallet'), (SELECT id from schema.cryptocurrencies where symbol = 'BNB'), '2023-05-17 14:40:20', 1200, 60, 'sell');
;



DELETE from walletchangehistory;


DELETE FROM infoaboutwallet;

DELETE from transaction;

DELETE from wallet;

DELETE from miner;

DELETE from cryptocurrencies;


DELETE from "user";


