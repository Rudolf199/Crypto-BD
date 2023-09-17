


--- Функция, возвращает топ 5 самых прибыльных криптовалют за день, на основе имеющихся данных
CREATE or replace FUNCTION find_most_profitable_cryptocurrency() RETURNS TABLE (id NUMERIC, name VARCHAR(20), profitability NUMERIC)
AS $$
BEGIN
  RETURN QUERY
  SELECT c.id, c.name, ROUND(((((c.price * m.efficiency) + (c.volume_24h / c.change_24h)) * m.efficiency))  / c.market_cap, 3)::numeric AS profitability
  FROM schema.cryptocurrencies AS c
  JOIN Miner AS m ON c.id = m.crypto_id
  ORDER BY profitability DESC
  LIMIT 5;
END;
$$ LANGUAGE plpgsql;




SELECT * FROM find_most_profitable_cryptocurrency();
