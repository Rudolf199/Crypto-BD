
# ***Физическая модель***


Таблица ```Cryptocurrency```:

| **Название**     | **Описание**                                      | **Тип данных**    | **Ограничение**   |
|------------------|---------------------------------------------------|-------------------|-------------------|
| ```id```         | Идентификатор                                     | ```INTEGER```     | ```PRIMARY KEY``` |
| ```name```       | Полное название криптовалюты                      | ```VARCHAR(20)``` | ```NOT NULL```    |
| ```symbol```     | Краткое название(ник)                             | ```VARCHAR(20)```   | ```NOT NULL```      |
| ```price```      | Текущая цена криптовалюты                         | ```INTEGER```     | ```NOT NULL```    |
| ```market_cap``` | Рыночная капитализация криптовалюты               | ```INTEGER```     | ```NONE```        |
| ```volume_24h``` | Объем торгов за последние 24 часа                 | ```INTEGER```     | ```NONE```        |
| ```change_24h``` | Изменение курса криптовалюты за последние 24 часа | ```INTEGER```     | ```NONE```        |


```

CREATE TABLE cd.cryptocurrencies (
   id            INTEGER                PRIMARY KEY,
   name          VARCHAR(20)           NOT NULL,
   symbol        VARCHAR(20)           NOT NULL,
   price         INTEGER                NOT NULL,
   market_cap    INTEGER,
   volume_24h    INTEGER,
   change_24h    INTEGER
);
```


-------------------

Таблица ```Wallet```:

| **Название**        | **Описание**                   | **Тип данных**    | **Ограничение** |
|---------------------|--------------------------------|-------------------|-----------|
| ```wallet_id```     | Идентификатор кошелька         | ```INTEGER```     | ```PRIMARY KEY``` |
| ```used_id```       | Идентификатор хозяйна кошелька | ```INTEGER```     | ```FOREIGN KEY```    |
| ```name```          | Имя кошелька                   | ```VARCHAR(20)``` | ```NOT NULL``` |
| ```total_balance``` | Суммарный баланс на кошельке   | ```INTEGER```     | ```NOT NULL``` |

```
CREATE TABLE cd.Wallet (
   wallet_id     INTEGER               PRIMARY KEY,
   user_id       INTEGER               NOT NULL REFERENCES users(user_id),
   name          VARCHAR(20)          NOT NULL,
   total_balance INTEGER               NOT NULL
);
```
-------------------

Таблица ```InfoAboutWallet```:

| **Название**    | **Описание**                                               | **Тип данных** | **Ограничение**   |
|-----------------|------------------------------------------------------------|----------------|-------------------|
| ```wallet_id``` | Идентификатор кошелька                                     | ```INTEGER```  | ```PRIMARY KEY``` |
| ```crypto_id``` | Идентификатор криптовалюты на кошельке                     | ```INTEGER```  | ```PRIMARY KEY``` |
| ```amount```    | Количество данной криптовалюты                             | ```INTEGER```  | ```NOT NULL```    |
| ```total_sum``` | Суммарная цена этой криптовалюты(сколько есть на кошельке) | ```INTEGER```  | ```NOT NULL```    |


```
CREATE TABLE InfoAboutWallet (
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
```
-------------
Таблица ```Miner```:

| **Название**     | **Описание**                                     | **Тип данных**    | **Ограничение**   |
|------------------|--------------------------------------------------|-------------------|-------------------|
| ```miner_id```   | Идентификатор майнера                            | ```INTEGER```     | ```PRIMARY KEY``` |
| ```crypto_id```  | Идентификатор криптовалюты, которую она добывает | ```INTEGER```     | ```FOREIGN KEY``` |
| ```name```       | Имя майнера                                      | ```VARCHAR(20)``` | ```NONE```        |
| ```efficienty``` | Эффективность майнера                            | ```INTEGER```     | ```NOT NULL```    |

```
CREATE TABLE Miner (
  miner_id INTEGER PRIMARY KEY,
  crypto_id INTEGER REFERENCES Crypto (crypto_id),
  name VARCHAR(20) DEFAULT NULL,
  efficiency INTEGER NOT NULL
);
```

---------

Таблица ```User```:

| **Название**        | **Описание**               | **Тип данных**    | **Ограничение**   |
|---------------------|----------------------------|-------------------|-------------------|
| ```user_id```       | Идентификатор пользователя | ```INTEGER```     | ```PRIMARY KEY``` |
| ```date_of_birth``` | Дата рождения пользователя | ```TIMESTAMP```   | ```NONE```        |
| ```name```          | Имя пользователя           | ```VARCHAR(20)``` | ```NOT NULL```    |
| ```surname```       | Фамилия пользователя       | ```VARCHAR(20)``` | ```NONE```        |

```
CREATE TABLE User (
    user_id       INTEGER PRIMARY KEY,
    date_of_birth TIMESTAMP,
    name          VARCHAR(20) NOT NULL,
    surname       VARCHAR(20)
);
```

------------

Таблица ```WalletChangeHistory```:

| **Название**         | **Описание**           | **Тип данных**  | **Ограничение**   |
|----------------------|------------------------|-----------------|-------------------|
| ```change_id```      | Идентификатор записи   | ```INTEGER```   | ```PRIMARY KEY``` |
| ```wallet_id```      | Идентификатор кошелька | ```INTEGER```   | ```FOREIGN KEY``` |
| ```balance_before``` | Баланс до изменения    | ```INTEGER```   | ```NOT NULL```    |
| ```valid_to```       | Aктуальна до           | ```TIMESTAMP``` | ```NOT NULL```    |
| ```change_date```| Дата записи            | ```TIMESTAMP```  |  ``` NOT NULL```  |


```
CREATE TABLE WalletChangeHistory (
  change_id INTEGER PRIMARY KEY,
  wallet_id INTEGER NOT NULL REFERENCES Wallet(wallet_id),
  balance_before INTEGER NOT NULL,
  valid_to TIMESTAMP NOT NULL,
  change_date TIMESTAMP NOT NULL
);
```

---------------

Таблица ```Transaction```:

| **Название**         | **Описание**                                                                   | **Тип данных**    | **Ограничение**   |
|----------------------|--------------------------------------------------------------------------------|-------------------|-------------------|
| ```transaction_id``` | Идентификатор транзакции                                                       | ```INTEGER```     | ```PRIMARY KEY``` |
| ```sender_id```      | Идентификатор кошелька отправителя транзакции (ссылка на таблицу Пользователи) | ```INTEGER```     | ```FOREIGN KEY``` |
| ```reciever_id```    | Идентификатор кошелька получателя транзакции (ссылка на таблицу Пользователи)  | ```INTEGER```     | ```FOREIGN KEY``` |
| ```crypto_id```      | Ссылка на криптовалюту, с которой была проведена транзакция                    | ```INTEGER```     | ```FOREIGN KEY``` |
| ```date_time```      | Дата и время проведения транзакции                                             | ```TIMESTAMP```   | ```NONE```        |
| ```price```          | Стоимость транзакции                                                           | ```INTEGER```     | ```NONE```        |
| ```fee```            | Комиссия, взимаемая за проведение транзакции                                   | ```INTEGER```     | ```NONE```        |
|```type```| Тип отправленной транзакции  (покупка/продажа/перевод и т.д.)                  | ```VARCHAR(20)``` | ```NOT NULL```    |

```
CREATE TABLE Transaction (
    transaction_id INTEGER PRIMARY KEY,
    sender_id INTEGER,
    reciever_id INTEGER,
    crypto_id INTEGER,
    date_time TIMESTAMP,
    price INTEGER,
    fee INTEGER,
    type VARCHAR(20) NOT NULL,
    FOREIGN KEY (sender_id) REFERENCES User(user_id),
    FOREIGN KEY (reciever_id) REFERENCES User(user_id),
    FOREIGN KEY (crypto_id) REFERENCES Crypto(crypto_id)
);
```
------------


