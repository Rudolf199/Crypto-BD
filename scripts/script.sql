CREATE SCHEMA IF NOT EXISTS cd;

USE cd;

CREATE TABLE IF NOT EXISTS User (
    user_id INTEGER PRIMARY KEY,
    date_of_birth TIMESTAMP,
    name VARCHAR(20) NOT NULL,
    surname VARCHAR(20)
);



CREATE TABLE if not exists Cryptocurrency (
    id            INTEGER                PRIMARY KEY,
    name          VARCHAR(20)           NOT NULL,
    symbol        VARCHAR(20)           NOT NULL,
    price         INTEGER                NOT NULL,
    market_cap    INTEGER,
    volume_24h    INTEGER,
    change_24h    INTEGER
);

CREATE TABLE if not exists Wallet (
    wallet_id     INTEGER               PRIMARY KEY,
    user_id       INTEGER               NOT NULL REFERENCES users(user_id),
    name          VARCHAR(20)          NOT NULL,
    total_balance INTEGER               NOT NULL
);

CREATE TABLE if not exists InfoAboutWallet (
    wallet_id  INTEGER NOT NULL,
    crypto_id  INTEGER NOT NULL,
    amount     INTEGER NOT NULL,
    total_sum  INTEGER NOT NULL,
    CONSTRAINT pk_InfoAboutWallet PRIMARY KEY (wallet_id, crypto_id),
    CONSTRAINT fk_InfoAboutWallet_wallet FOREIGN KEY (wallet_id)
     REFERENCES wallets(wallet_id) ON DELETE CASCADE,
    CONSTRAINT fk_InfoAboutWallet_crypto FOREIGN KEY (crypto_id)
     REFERENCES cryptocurrencies(crypto_id) ON DELETE CASCADE
);


CREATE TABLE if not exists Miner (
    miner_id INTEGER PRIMARY KEY,
    crypto_id INTEGER REFERENCES Crypto (crypto_id),
    name VARCHAR(20) DEFAULT NULL,
    efficiency INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS Transaction (
    transaction_id INTEGER PRIMARY KEY,
    sender_id INTEGER REFERENCES User(user_id),
    receiver_id INTEGER REFERENCES User(user_id),
    crypto_id INTEGER REFERENCES Crypto(crypto_id),
    date_time TIMESTAMP,
    price INTEGER,
    fee INTEGER,
    type VARCHAR(20) NOT NULL
);

CREATE TABLE IF NOT EXISTS WalletChangeHistory (
    change_id INTEGER PRIMARY KEY,
    wallet_id INTEGER REFERENCES Wallet(wallet_id),
    balance_before INTEGER NOT NULL,
    valid_to TIMESTAMP NOT NULL,
    change_date TIMESTAMP NOT NULL
);


