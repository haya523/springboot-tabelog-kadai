-- =========================================================
-- data.sql（完全版：列名明示 & UPSERT、一行毎にセミコロン）
-- =========================================================

-- 文字コード（必要に応じて）
-- SET NAMES utf8mb4;

-- ============== 初期マスタ ==============
INSERT IGNORE INTO roles (id, name) VALUES (1, 'ROLE_GENERAL');
INSERT IGNORE INTO roles (id, name) VALUES (2, 'ROLE_ADMIN');

INSERT IGNORE INTO users
(id, name, furigana, postal_code, address, phone_number, email, password, role_id, enabled)
VALUES
(1, '侍 太郎', 'サムライ タロウ', '101-0022', '東京都千代田区神田練塀町300番地', '090-1234-5678', 'taro.samurai@example.com',  '$2a$10$2JNjTwZBwo7fprL2X4sv.OEKqxnVtsVQvuXDkI8xVGix.U3W5B7CO', 1, true),
(2, '侍 花子', 'サムライ ハナコ', '101-0022', '東京都千代田区神田練塀町300番地', '090-1234-5678', 'hanako.samurai@example.com', '$2a$10$2JNjTwZBwo7fprL2X4sv.OEKqxnVtsVQvuXDkI8xVGix.U3W5B7CO', 2, true),
(3, '侍 義勝', 'サムライ ヨシカツ', '638-0644', '奈良県五條市西吉野町湯川X-XX-XX', '090-1234-5678', 'yoshikatsu.samurai@example.com', '$2a$10$2JNjTwZBwo7fprL2X4sv.OEKqxnVtsVQvuXDkI8xVGix.U3W5B7CO', 1, true),
(4, '侍 幸美', 'サムライ サチミ', '342-0006', '埼玉県吉川市南広島X-XX-XX', '090-1234-5678', 'sachimi.samurai@example.com',    '$2a$10$2JNjTwZBwo7fprL2X4sv.OEKqxnVtsVQvuXDkI8xVGix.U3W5B7CO', 1, true),
(5, '侍 雅',   'サムライ ミヤビ', '527-0209', '滋賀県東近江市佐目町X-XX-XX',  '090-1234-5678', 'miyabi.samurai@example.com',    '$2a$10$2JNjTwZBwo7fprL2X4sv.OEKqxnVtsVQvuXDkI8xVGix.U3W5B7CO', 1, true);

INSERT IGNORE INTO reservations
(id, house_id, user_id, checkin_date, checkout_date, number_of_people, amount)
VALUES
(1, 1, 1, '2023-04-01', '2023-04-02', 2,  6000),
(2, 2, 1, '2023-04-01', '2023-04-02', 3,  7000),
(3, 3, 1, '2023-04-01', '2023-04-02', 4,  8000),
(4, 4, 1, '2023-04-01', '2023-04-02', 5,  9000),
(5, 5, 1, '2023-04-01', '2023-04-02', 6, 10000),
(6, 6, 1, '2023-04-01', '2023-04-02', 2,  6000),
(7, 7, 1, '2023-04-01', '2023-04-02', 3,  7000),
(8, 8, 1, '2023-04-01', '2023-04-02', 4,  8000),
(9, 9, 1, '2023-04-01', '2023-04-02', 5,  9000),
(10,10,1, '2023-04-01', '2023-04-02', 6, 10000),
(11,11,1, '2023-04-01', '2023-04-02', 2,  6000);

-- ============== レビュー（食べログ風に差し替え） ==============
DELETE FROM reviews;
INSERT INTO reviews (house_id, user_id, rating, comment, created_at)
VALUES
(1, 1, 5, '香ばしい焼き目とタレのキレが最高。締めの出汁で味変も楽しく、再訪確定です。', NOW()),
(1, 2, 4, '店内は清潔感があり居心地◎。香り立つ鰻がご飯に合う。もう一歩ボリュームがあると嬉しい。', NOW()),
(1, 3, 4, '名駅からのアクセス良好で使い勝手抜群。待ち時間も少なく、サクッと美味。', NOW()),
(1, 4, 3, 'タレは好み。やや提供まで時間がかかったが、焼きは上々。', NOW()),
(1, 5, 4, 'スタッフの気配りが行き届いて安心して食事ができた。肝吸いもおすすめ。', NOW());

-- ============== お気に入り（サンプル） ==============
INSERT IGNORE INTO favorites (id, user_id, house_id, created_at) VALUES
(1, 1, 1, NOW()),
(2, 1, 2, NOW()),
(3, 1, 3, NOW()),
(4, 1, 4, NOW()),
(5, 1, 5, NOW()),
(6, 1, 6, NOW()),
(7, 1, 7, NOW()),
(8, 1, 8, NOW()),
(9, 1, 9, NOW()),
(10,1,10, NOW()),
(11,1,11, NOW());


-- ===== seed roles (idempotent) =====
INSERT INTO roles (name)
SELECT 'ROLE_GENERAL'
WHERE NOT EXISTS (SELECT 1 FROM roles WHERE name = 'ROLE_GENERAL');

INSERT INTO roles (name)
SELECT 'ROLE_PREMIUM'
WHERE NOT EXISTS (SELECT 1 FROM roles WHERE name = 'ROLE_PREMIUM');
-- ===== end =====


-- ================== houses を UPSERT ==================
-- タイムスタンプは統一。42 は欠番のまま。
SET @CREATED := '2025-07-16 07:54:57';
SET @UPDATED := '2025-09-18 11:51:16';

-- 1〜12（ひつまぶし）
INSERT INTO houses
(id, name, image_name, description, price, capacity, postal_code, address, phone_number, created_at, updated_at)
VALUES
(1,  '名代 ひつまぶし 鰻匠 本店', 'yakiniku02.jpg', '香ばしく焼いた鰻をタレと出汁で三度愉しむ名古屋名物ひつまぶし。', 6000, 2, '073-0145', '北海道砂川市西五条南X-XX-XX', '012-345-678', @CREATED, @UPDATED)
ON DUPLICATE KEY UPDATE
 name=VALUES(name), image_name=VALUES(image_name), description=VALUES(description),
 price=VALUES(price), capacity=VALUES(capacity),
 postal_code=VALUES(postal_code), address=VALUES(address), phone_number=VALUES(phone_number),
 created_at=VALUES(created_at), updated_at=VALUES(updated_at);

INSERT INTO houses
(id, name, image_name, description, price, capacity, postal_code, address, phone_number, created_at, updated_at)
VALUES
(2,  'ひつまぶし うな香 栄店','yakiniku03.jpg','香ばしく焼いた鰻をタレと出汁で三度愉しむ名古屋名物ひつまぶし。',7000,3,'030-0945','青森県青森市桜川X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses
(id, name, image_name, description, price, capacity, postal_code, address, phone_number, created_at, updated_at)
VALUES
(3,'うなぎ茶屋 ひつまぶし 名駅','yakitori01.jpg','香ばしく焼いた鰻をタレと出汁で三度愉しむ名古屋名物ひつまぶし。',8000,4,'029-5618','岩手県和賀郡西和賀町沢内両沢X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses
(id, name, image_name, description, price, capacity, postal_code, address, phone_number, created_at, updated_at)
VALUES
(4,'炭焼き鰻 ひつまぶし さくら','nagoyaburger.jpg','香ばしく焼いた鰻をタレと出汁で三度愉しむ名古屋名物ひつまぶし。',9000,5,'989-0555','宮城県刈田郡七ヶ宿町滝ノ上X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses
(id, name, image_name, description, price, capacity, postal_code, address, phone_number, created_at, updated_at)
VALUES
(5,'鰻とだし茶の店 ひつまぶし庵','ramen.jpg','香ばしく焼いた鰻をタレと出汁で三度愉しむ名古屋名物ひつまぶし。',10000,6,'018-2661','秋田県山本郡八峰町八森浜田X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses
(id, name, image_name, description, price, capacity, postal_code, address, phone_number, created_at, updated_at)
VALUES
(6,'熟成うなぎ ひつまぶし 風雅','ramen02.jpg','香ばしく焼いた鰻をタレと出汁で三度愉しむ名古屋名物ひつまぶし。',6000,2,'999-6708','山形県酒田市泉興野X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses
(id, name, image_name, description, price, capacity, postal_code, address, phone_number, created_at, updated_at)
VALUES
(7,'名駅 ひつまぶし 参道','udon.jpg','香ばしく焼いた鰻をタレと出汁で三度愉しむ名古屋名物ひつまぶし。',7000,3,'969-5147','福島県会津若松市大戸町芦牧X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses
(id, name, image_name, description, price, capacity, postal_code, address, phone_number, created_at, updated_at)
VALUES
(8,'金鯱 ひつまぶし 鰻の刻','sakana.jpg','香ばしく焼いた鰻をタレと出汁で三度愉しむ名古屋名物ひつまぶし。',8000,4,'310-0021','茨城県水戸市南町X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses
(id, name, image_name, description, price, capacity, postal_code, address, phone_number, created_at, updated_at)
VALUES
(9,'川魚料理 ひつまぶし 花筏','washoku.jpg','香ばしく焼いた鰻をタレと出汁で三度愉しむ名古屋名物ひつまぶし。',9000,5,'323-1101','栃木県下都賀郡藤岡町大前X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses
(id, name, image_name, description, price, capacity, postal_code, address, phone_number, created_at, updated_at)
VALUES
(10,'名古屋 ひつまぶし 鰻の善','fried.jpg','香ばしく焼いた鰻をタレと出汁で三度愉しむ名古屋名物ひつまぶし。',10000,6,'370-0806','群馬県高崎市上和田町X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses
(id, name, image_name, description, price, capacity, postal_code, address, phone_number, created_at, updated_at)
VALUES
(11,'伏見 ひつまぶし うな蓮','don.jpg','香ばしく焼いた鰻をタレと出汁で三度愉しむ名古屋名物ひつまぶし。',6000,2,'344-0125','埼玉県春日部市飯沼X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses
(id, name, image_name, description, price, capacity, postal_code, address, phone_number, created_at, updated_at)
VALUES
(12,'栄 ひつまぶし しら河庵','yakiniku.jpg','香ばしく焼いた鰻をタレと出汁で三度愉しむ名古屋名物ひつまぶし。',7000,3,'272-0011','千葉県市川市高谷新町X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

-- 13〜24（味噌カツ）
INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(13,'味噌カツ かつ真 栄本店','yakiniku02.jpg','八丁味噌だれが決め手。サクッと揚げたロースとヒレの味噌カツ。',8000,4,'130-0023','東京都墨田区立川X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(14,'味噌カツ工房 とん晴 名駅西','yakiniku03.jpg','八丁味噌だれが決め手。サクッと揚げたロースとヒレの味噌カツ。',9000,5,'240-0006','神奈川県横浜市保土ヶ谷区星川X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(15,'揚げたて味噌かつ こいし','yakitori01.jpg','八丁味噌だれが決め手。サクッと揚げたロースとヒレの味噌カツ。',10000,6,'950-0201','新潟県新潟市駒込X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(16,'味噌とんかつ 玄 八事店','nagoyaburger.jpg','八丁味噌だれが決め手。サクッと揚げたロースとヒレの味噌カツ。',6000,2,'939-8155','富山県富山市江本X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(17,'みそかつ亭 かつ郎 金山','ramen.jpg','八丁味噌だれが決め手。サクッと揚げたロースとヒレの味噌カツ。',7000,3,'929-0111','石川県能美市吉原町X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(18,'熟成かつ 味噌ダレ専門 こがね','ramen02.jpg','八丁味噌だれが決め手。サクッと揚げたロースとヒレの味噌カツ。',8000,4,'910-2354','福井県福井市東天田町X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(19,'矢場味噌かつ きわみ 伏見','udon.jpg','八丁味噌だれが決め手。サクッと揚げたロースとヒレの味噌カツ。',9000,5,'403-0003','山梨県富士吉田市大明見X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(20,'味噌カツ かつ政 大須本通','sakana.jpg','八丁味噌だれが決め手。サクッと揚げたロースとヒレの味噌カツ。',10000,6,'395-0017','長野県飯田市東新町X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(21,'味噌かつ膳 まるや 本山','washoku.jpg','八丁味噌だれが決め手。サクッと揚げたロースとヒレの味噌カツ。',6000,2,'509-5147','岐阜県土岐市泉郷町X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(22,'黒豚味噌カツ 錦 角屋','fried.jpg','八丁味噌だれが決め手。サクッと揚げたロースとヒレの味噌カツ。',7000,3,'434-0002','静岡県浜松市尾野X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(23,'名駅 味噌かつ厨房 きさらぎ','don.jpg','八丁味噌だれが決め手。サクッと揚げたロースとヒレの味噌カツ。',8000,4,'444-3261','愛知県豊田市東大林町X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(24,'鉄鍋みそかつ とん秀 栄南','yakiniku.jpg','八丁味噌だれが決め手。サクッと揚げたロースとヒレの味噌カツ。',9000,5,'510-0201','三重県鈴鹿市稲生町X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

-- 25〜36（味噌煮込みうどん）
INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(25,'味噌煮込み きし蔵 本店','yakiniku02.jpg','コシのある麺と湯気立つ味噌出汁。土鍋で熱々の味噌煮込みうどん。',10000,6,'520-2353','滋賀県野洲市久野部X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(26,'老舗 味噌煮込み かじ川','yakiniku03.jpg','コシのある麺と湯気立つ味噌出汁。土鍋で熱々の味噌煮込みうどん。',6000,2,'612-8369','京都府京都市伏見区村上町X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(27,'煮込うどん処 味噌の助','yakitori01.jpg','コシのある麺と湯気立つ味噌出汁。土鍋で熱々の味噌煮込みうどん。',7000,3,'578-0915','大阪府東大阪市古箕輪X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(28,'自家製麺 味噌煮込み つる庵','nagoyaburger.jpg','コシのある麺と湯気立つ味噌出汁。土鍋で熱々の味噌煮込みうどん。',8000,4,'655-0891','兵庫県神戸市垂水区山手X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(29,'名古屋味噌煮込み 空','ramen.jpg','コシのある麺と湯気立つ味噌出汁。土鍋で熱々の味噌煮込みうどん。',9000,5,'630-1126','奈良県奈良市法用町X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(30,'味噌煮込み 饂飩 えびす','ramen02.jpg','コシのある麺と湯気立つ味噌出汁。土鍋で熱々の味噌煮込みうどん。',10000,6,'640-8319','和歌山県和歌山市手平X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(31,'土鍋味噌煮込み 花ごよみ','udon.jpg','コシのある麺と湯気立つ味噌出汁。土鍋で熱々の味噌煮込みうどん。',6000,2,'689-2203','鳥取県東伯郡北栄町原X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(32,'味噌煮込み庵 いな穂','sakana.jpg','コシのある麺と湯気立つ味噌出汁。土鍋で熱々の味噌煮込みうどん。',7000,3,'694-0035','島根県大田市五十猛町X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(33,'味噌煮込み かね甚','washoku.jpg','コシのある麺と湯気立つ味噌出汁。土鍋で熱々の味噌煮込みうどん。',8000,4,'712-8036','岡山県倉敷市水島西弥生町X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(34,'釜揚げ味噌煮込み たまき','fried.jpg','コシのある麺と湯気立つ味噌出汁。土鍋で熱々の味噌煮込みうどん。',9000,5,'726-0011','広島県府中市広谷町X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(35,'味噌煮込み 麺房 こく豊','don.jpg','コシのある麺と湯気立つ味噌出汁。土鍋で熱々の味噌煮込みうどん。',10000,6,'750-0451','山口県下関市豊田町阿座上X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(36,'名駅 味噌煮込み こはる','yakiniku.jpg','コシのある麺と湯気立つ味噌出汁。土鍋で熱々の味噌煮込みうどん。',6000,2,'778-0004','徳島県三好市池田町X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

-- 37〜41, 43〜48（手羽先） ※42は欠番
INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(37,'手羽先 唐揚げ 金の羽 栄本店','yakiniku02.jpg','カリッと揚げた手羽先に甘辛だれと胡椒。ビールが進む名古屋の定番。',7000,3,'762-0067','香川県坂出市瀬居町X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(38,'元祖 手羽先 のぼりや 名駅西','yakiniku03.jpg','カリッと揚げた手羽先に甘辛だれと胡椒。ビールが進む名古屋の定番。',8000,4,'792-0828','愛媛県新居浜市松原町X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(39,'備長炭 手羽先 はね吉 大須','yakitori01.jpg','カリッと揚げた手羽先に甘辛だれと胡椒。ビールが進む名古屋の定番。',9000,5,'787-1323','高知県四万十市西土佐中半X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(40,'旨辛 手羽先 赤から屋 伏見','nagoyaburger.jpg','カリッと揚げた手羽先に甘辛だれと胡椒。ビールが進む名古屋の定番。',10000,6,'835-0018','福岡県みやま市瀬高町高柳X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(41,'秘伝だれ 手羽先 鶏八','ramen.jpg','カリッと揚げた手羽先に甘辛だれと胡椒。ビールが進む名古屋の定番。',6000,2,'840-0213','佐賀県佐賀市大和町久留間X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

-- 42 欠番

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(43,'揚げたて 手羽先 せんば','udon.jpg','カリッと揚げた手羽先に甘辛だれと胡椒。ビールが進む名古屋の定番。',8000,4,'863-0021','熊本県天草市港町X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(44,'焼き手羽先 炭と肴 たつみ','sakana.jpg','カリッと揚げた手羽先に甘辛だれと胡椒。ビールが進む名古屋の定番。',9000,5,'872-0014','大分県宇佐市南鶴田新田X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(45,'手羽先横丁 かえで','washoku.jpg','カリッと揚げた手羽先に甘辛だれと胡椒。ビールが進む名古屋の定番。',10000,6,'880-0947','宮崎県宮崎市薫る坂X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(46,'カリ旨 手羽先 こがし屋','fried.jpg','カリッと揚げた手羽先に甘辛だれと胡椒。ビールが進む名古屋の定番。',6000,2,'895-2103','鹿児島県薩摩郡さつま町紫尾X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(47,'めしと手羽先 ひので','don.jpg','カリッと揚げた手羽先に甘辛だれと胡椒。ビールが進む名古屋の定番。',7000,3,'904-2165','沖縄県沖縄市宮里X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(48,'酒場 手羽先 風来横丁','yakiniku.jpg','カリッと揚げた手羽先に甘辛だれと胡椒。ビールが進む名古屋の定番。',8000,4,'041-1121','北海道亀田郡七飯町大中山X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

-- 49〜57（きしめん）
INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(49,'きしめん処 名駅 きぬ乃','yakiniku02.jpg','鰹と昆布の香り立つ出汁でいただく、つるもち食感のきしめん。',9000,5,'095-0019','北海道士別市大通東X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(50,'老舗 きしめん つばき','yakiniku03.jpg','鰹と昆布の香り立つ出汁でいただく、つるもち食感のきしめん。',10000,6,'099-0423','北海道紋別郡遠軽町若松X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(51,'出汁香る きしめん こまち','yakitori01.jpg','鰹と昆布の香り立つ出汁でいただく、つるもち食感のきしめん。',6000,2,'089-0533','北海道中川郡幕別町札内新北町X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(52,'釜玉きしめん こがね屋','nagoyaburger.jpg','鰹と昆布の香り立つ出汁でいただく、つるもち食感のきしめん。',7000,3,'049-3514','北海道山越郡長万部町富野X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(53,'天ぷら きしめん かしわ屋','ramen.jpg','鰹と昆布の香り立つ出汁でいただく、つるもち食感のきしめん。',8000,4,'066-0018','北海道千歳市旭ヶ丘X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(54,'冷やしきしめん 清流','ramen02.jpg','のど越し爽やか。出汁の旨みをキリッと感じる一杯。',6000,2,'957-0053','新潟県新発田市中央町X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(55,'香味きしめん 三蔵','udon.jpg','香味油が食欲をそそるコク深いきしめん。',7000,3,'500-8833','岐阜県岐阜市神田町X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(56,'釜あげ きしめん まつ乃','sakana.jpg','もちもち食感と出汁の香りが調和する王道きしめん。',8000,4,'444-2134','愛知県岡崎市大樹寺X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);

INSERT INTO houses (id,name,image_name,description,price,capacity,postal_code,address,phone_number,created_at,updated_at) VALUES
(57,'名古屋 きしめん 翔','washoku.jpg','つるりとした麺線が美しい、出汁香る一杯。',9000,5,'460-0008','愛知県名古屋市中区栄X-XX-XX','012-345-678',@CREATED,@UPDATED)
ON DUPLICATE KEY UPDATE name=VALUES(name),image_name=VALUES(image_name),description=VALUES(description),price=VALUES(price),capacity=VALUES(capacity),postal_code=VALUES(postal_code),address=VALUES(address),phone_number=VALUES(phone_number),created_at=VALUES(created_at),updated_at=VALUES(updated_at);
