-- create tables/indexes

DROP INDEX IF EXISTS idx_thlefwno_id;
DROP TABLE IF EXISTS axiologiseis;
DROP TABLE IF EXISTS ergazetai_se_ergo;
DROP TABLE IF EXISTS thlefwno;
DROP TABLE IF EXISTS paradoteo;
DROP TABLE IF EXISTS axiologisi;
DROP TABLE IF EXISTS epist_pedio_ergou;
DROP TABLE IF EXISTS ergo;
DROP TABLE IF EXISTS erevnitis;
DROP TABLE IF EXISTS organismos;
DROP TABLE IF EXISTS epist_pedio;
DROP TABLE IF EXISTS programma;
DROP TABLE IF EXISTS org_etairia;
DROP TABLE IF EXISTS org_erevnitiko_kentro;
DROP TABLE IF EXISTS org_panepistimio;
DROP TABLE IF EXISTS stelexos;


CREATE TABLE stelexos(
   id CHAR(11) PRIMARY KEY     NOT NULL,           -- AMKA
   eponimo        VARCHAR(100) NOT NULL,
   onoma          VARCHAR(100) NOT NULL,
   CONSTRAINT unq UNIQUE (id, onoma)
);


CREATE TABLE org_panepistimio(
   id CHAR(9) PRIMARY KEY NOT NULL,    -- ΑΦΜ
   proyp_yp_paideias REAL NOT NULL
);

CREATE TABLE org_erevnitiko_kentro(
   id CHAR(9) PRIMARY KEY NOT NULL,    -- ΑΦΜ
   proyp_yp_paideias REAL NOT NULL,
   proyp_idiotikes_draseis REAL NOT NULL
);

CREATE TABLE org_etairia(
   id CHAR(9) PRIMARY KEY NOT NULL,    -- ΑΦΜ
   proyp_idia_kefalaia REAL NOT NULL
);

CREATE TABLE programma(
   onoma          VARCHAR(500)  PRIMARY KEY     NOT NULL,
   diefthinsi     VARCHAR(50) NOT NULL,
   -- κάθε πρόγραμμα ανήκει σε μία διεύθυνση
   CONSTRAINT unq_diefthinsi UNIQUE (onoma, diefthinsi)
);



CREATE TABLE epist_pedio(
   onoma VARCHAR(100) PRIMARY KEY     NOT NULL
);


CREATE TABLE organismos(
   id CHAR(11) PRIMARY KEY    NOT NULL,   -- ΑΦΜ
   sintomografia VARCHAR(20) NOT NULL,
   onoma         VARCHAR(100) NOT NULL,
   odos          VARCHAR(100) NOT NULL,
   poli          VARCHAR(50) NOT NULL,
   tk            CHAR(5) NOT NULL
);



CREATE TABLE ergo(
   id  INT PRIMARY KEY    NOT NULL,
   poso           REAL    NOT NULL,
   titlos        VARCHAR(600) NOT NULL,
   perilipsi     VARCHAR(1000) NOT NULL,
   enarxi         DATE    NOT NULL,
   lixi           DATE    NOT NULL,
   stelexosid     CHAR(11) NOT NULL,
   programmaonoma VARCHAR(500) NOT NULL,
   epist_ypeyth_ergou CHAR(11) NOT NULL,
   orgid          CHAR(9) NOT NULL,
   -- κάθε έργο έχει έναν και μόνο οργανισμό που το διαχειρίζεται
   CONSTRAINT unq_orgid UNIQUE (id, orgid),
   -- κάθε έργο χρηματοδείται από ακριβώς ένα πρόγραμμα
   CONSTRAINT unq_programmaonoma UNIQUE (id, programmaonoma),
   CONSTRAINT fk_org FOREIGN KEY(orgid) REFERENCES organismos(id),
   CONSTRAINT fk_stelexosid FOREIGN KEY(stelexosid) REFERENCES stelexos(id),
   CONSTRAINT fk_programmaonoma FOREIGN KEY(programmaonoma) REFERENCES programma(onoma),
-- επειδή η σχέση 'erevnitis' δεν έχει δημιουργηθεί ακόμα δεν μπορεί να γραφεί εδώ το παρακάτω:
-- CONSTRAINT fk_epist_ypeyth_ergou  FOREIGN KEY(epist_ypeyth_ergou) REFERENCES erevnitis(id),
-- αλλά θα πρέπει το ξένο κλειδί να προστεθεί στην σχέση χειρωνακτικώς παρακάτω
   -- η διάρκεια του έργου είναι από 1 έως 4 έτη (και η λήξη πρέπει να έπεται της έναρξης)
   CONSTRAINT ck_dates1 CHECK(lixi >= enarxi),
   CONSTRAINT ck_dates2 CHECK(
    (EXTRACT(year FROM lixi) - EXTRACT(year FROM enarxi) >= 1)
     AND
    (EXTRACT(year FROM lixi) - EXTRACT(year FROM enarxi) <= 4)
   )
);

-- συνάρτηση για τον υπολογισμό της διάρκειας του έργου
CREATE OR REPLACE FUNCTION ergo_diarkia(ergo_id INT)
   RETURNS INT
   LANGUAGE PLPGSQL
  AS
$$
DECLARE 
  d INT;
BEGIN
  SELECT 
    (EXTRACT (YEAR FROM ergo.lixi()) - EXTRACT (YEAR FROM ergo.enarxi)) INTO d
   FROM ergo WHERE (ergo.id = ergo_id);
  RETURN d; 
END;
$$
;

CREATE TABLE epist_pedio_ergou(
   ergoid INT NOT NULL,
   epist_pedio_onoma VARCHAR(100) NOT NULL,
   CONSTRAINT unq_epist_pedio_ergou_ergoid_epist_pedio_onoma UNIQUE (ergoid, epist_pedio_onoma),
   CONSTRAINT fk_ergo FOREIGN KEY(ergoid) REFERENCES ergo(id),
   CONSTRAINT fk_epist_pedio FOREIGN KEY(epist_pedio_onoma) REFERENCES epist_pedio(onoma)
);



CREATE TABLE axiologisi(
   id INT PRIMARY KEY     NOT NULL,
   imerominia     DATE    NOT NULL,
   vathmos        REAL    NOT NULL
);


CREATE TABLE paradoteo(
   titlos         VARCHAR(100) PRIMARY KEY NOT NULL,
   perilipsi      VARCHAR(1000) NOT NULL,
   ergoid INT,
   imerominia    DATE NOT NULL,
   CONSTRAINT unq_paradoteo UNIQUE (titlos,ergoid),
   CONSTRAINT fk_ergo FOREIGN KEY(ergoid) REFERENCES ergo(id)
);



CREATE TABLE erevnitis(
   id CHAR(11) PRIMARY KEY     NOT NULL,	-- AMKA
   eponimo       VARCHAR(100) NOT NULL,
   onoma          VARCHAR(100) NOT NULL,
   gennisi        DATE    NOT NULL,
   fylo           CHAR(1) NOT NULL,
   orgid          CHAR(9) NOT NULL,
   imerominia_org DATE     NOT NULL,
   CONSTRAINT fk_org FOREIGN KEY(orgid) REFERENCES organismos(id),
   CONSTRAINT ck_fylo CHECK(fylo = 'M' or fylo = 'F')
);

-- συνάρτηση για τον υπολογισμό της ηλικίας του ερευνητή
CREATE OR REPLACE FUNCTION erevnitis_hlikia(erevnitis_id CHAR(11))
   RETURNS INT
   LANGUAGE PLPGSQL
  AS
$$
DECLARE 
  h INT;
BEGIN
  SELECT 
    (EXTRACT (YEAR FROM NOW()) - EXTRACT (YEAR FROM erevnitis.gennisi)) INTO h
   FROM erevnitis WHERE (erevnitis.id = erevnitis_id);
  RETURN h; 
END;
$$
;

-- τώρα που η σχέση 'erevnitis' δημιουργήθηκε, ας προστεθεί το κλειδί της ως ξένο κλειδί στην σχέση ergo
ALTER TABLE ergo add FOREIGN KEY(epist_ypeyth_ergou) REFERENCES erevnitis(id);


CREATE TABLE thlefwno(
   orgid         CHAR(11)    NOT NULL,
   number        VARCHAR(20) NOT NULL,
   PRIMARY KEY(orgid, number),
   CONSTRAINT fk_org FOREIGN KEY(orgid) REFERENCES organismos(id)
);
-- για την γρήγορη εύρεση των τηλεφώνων ενός οργανισμού
CREATE INDEX idx_thlefwno_id ON thlefwno(orgid);




CREATE TABLE ergazetai_se_ergo(
   ergoid INT  NOT NULL,
   erevnitisid CHAR(11)  NOT NULL,
   UNIQUE (ergoid, erevnitisid),
   CONSTRAINT fk_ergo FOREIGN KEY(ergoid) REFERENCES ergo(id),
   CONSTRAINT fk_erevnitis FOREIGN KEY(erevnitisid) REFERENCES erevnitis(id)
);
CREATE INDEX idx_ergazetai_se_ergo_ergoid ON ergazetai_se_ergo(ergoid);
CREATE INDEX idx_ergazetai_se_ergo_erevnitisid ON ergazetai_se_ergo(erevnitisid);




CREATE TABLE axiologiseis(
   axiologisiid  INT  NOT NULL,
   erevnitisid   CHAR(11) NOT NULL,
   ergoid        INT  NOT NULL,
   axiologitisorgid CHAR(9)  NOT NULL,
   ergoorgid     CHAR(9)  NOT NULL,
   -- το έργο αξιολογείται από έναν έναν ερευνητή
   CONSTRAINT unq_erevnitisid UNIQUE (ergoid, erevnitisid),
   -- ο αξιολογητής ενός έργου δεν μπορεί να ανήκει στον οργανισμό που συμμετέχει στην πρόταση του έργου
   CONSTRAINT ck_axiologitis_ergo CHECK(axiologitisorgid != ergoorgid),
   CONSTRAINT fk_axiologisi FOREIGN KEY(axiologisiid) REFERENCES axiologisi(id),
   CONSTRAINT fk_erevnitis FOREIGN KEY(erevnitisid) REFERENCES erevnitis(id),
   CONSTRAINT fk_ergo FOREIGN KEY(ergoid) REFERENCES ergo(id),
   CONSTRAINT fk_ergoorg FOREIGN KEY(ergoorgid) REFERENCES organismos(id),
   CONSTRAINT fk_axiologitisorg FOREIGN KEY(axiologitisorgid) REFERENCES organismos(id)
);




-- Δημιουργία όψεων

-- έργα ανά ερευνητή
DROP VIEW IF EXISTS erga_ana_erevniti;
-- ονοματεπώνυμο ερευνητών και έργα στα οποία εργάζονται
CREATE VIEW erga_ana_erevniti(ergoid, erevnitisid, onomateponimo) AS
SELECT ergazetai_se_ergo.ergoid, ergazetai_se_ergo.erevnitisid,
       CONCAT(erevnitis.eponimo, ' ',  erevnitis.onoma)
FROM ergazetai_se_ergo INNER JOIN erevnitis
ON (ergazetai_se_ergo.erevnitisid = erevnitis.id)
ORDER BY (erevnitis.eponimo, erevnitis.onoma);


-- ηλικιακή κατανομή ερευνητών (χωρίς προσωπικά στοιχεία)
DROP VIEW IF EXISTS hlikia_erevnitwn;
CREATE VIEW hlikia_erevnitwn (age) AS
SELECT erevnitis_hlikia(id)
FROM erevnitis;


