CREATE TABLE JobsData (
    keyword VARCHAR(255),
    LinkedIn INT,
    Indeed INT,
    SimplyHire INT,
    Monster INT,
    `LinkedIn %` DECIMAL(5, 2),
    `Indeed %` DECIMAL(5, 2),
    `SimplyHire %` DECIMAL(5, 2),
    `Monster %` DECIMAL(5, 2),
    `Avg %` DECIMAL(5, 2),
    GlassDoor DECIMAL(5, 2),
    Difference DECIMAL(5, 2)
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\ds_job_listing_software.csv'
INTO TABLE JobsData
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(keyword, @LinkedIn, @Indeed, @SimplyHire, @Monster, @LinkedInPct, @IndeedPct, @SimplyHirePct, @MonsterPct, @AvgPct, @GlassDoor, @Difference)
SET
    LinkedIn = NULLIF(@LinkedIn, -1),
    Indeed = NULLIF(@Indeed, -1),
    SimplyHire = NULLIF(@SimplyHire, -1),
    Monster = NULLIF(@Monster, -1),
    `LinkedIn %` = NULLIF(@LinkedInPct, -1),
    `Indeed %` = NULLIF(@IndeedPct, -1),
    `SimplyHire %` = NULLIF(@SimplyHirePct, -1),
    `Monster %` = NULLIF(@MonsterPct, -1),
    `Avg %` = NULLIF(@AvgPct, -1),
    GlassDoor = NULLIF(@GlassDoor, -1),
    Difference = NULLIF(@Difference, -1);
    
CREATE TABLE Keyword (
    keyword_id INT PRIMARY KEY AUTO_INCREMENT,
    keyword_name VARCHAR(255) UNIQUE NOT NULL,
    aveg_percentage DECIMAL(5, 2),
    Glassdoor_percentage DECIMAL(5, 2),
    percentage_dif DECIMAL(5, 2)
);

INSERT INTO Keyword (keyword_name, aveg_percentage, Glassdoor_percentage, percentage_dif)
SELECT keyword, `Avg %`, GlassDoor, Difference
FROM JobsData;

INSERT INTO Keyword (aveg_percentage, Glassdoor_percentage, percentage_dif)
SELECT `Avg %`, GlassDoor, Difference
FROM JobsData;

CREATE TABLE JobSource (
    source_id INT PRIMARY KEY AUTO_INCREMENT,
    source_name VARCHAR(255) UNIQUE NOT NULL
);

INSERT INTO JobSource (source_name)
VALUES ('LinkedIn'), ('Indeed'), ('SimplyHire'), ('Monster');

CREATE TABLE Metrics (
    metric_id INT PRIMARY KEY AUTO_INCREMENT,
    keyword_id INT,
    source_id INT,
    count INT,
    percentage DECIMAL(5, 2),
    FOREIGN KEY (keyword_id) REFERENCES Keyword(keyword_id),
    FOREIGN KEY (source_id) REFERENCES JobSource(source_id)
);

INSERT INTO Metrics (keyword_id, source_id, count, percentage)
SELECT k.keyword_id, s.source_id, j.LinkedIn, j.`LinkedIn %`
FROM JobsData j
JOIN Keyword k ON j.keyword = k.keyword_name
JOIN JobSource s ON s.source_name = 'LinkedIn'
UNION ALL
SELECT k.keyword_id, s.source_id, j.Indeed, j.`Indeed %`
FROM JobsData j
JOIN Keyword k ON j.keyword = k.keyword_name
JOIN JobSource s ON s.source_name = 'Indeed'
UNION ALL
SELECT k.keyword_id, s.source_id, j.SimplyHire, j.`SimplyHire %`
FROM JobsData j
JOIN Keyword k ON j.keyword = k.keyword_name
JOIN JobSource s ON s.source_name = 'SimplyHire'
UNION ALL
SELECT k.keyword_id, s.source_id, j.Monster, j.`Monster %`
FROM JobsData j
JOIN Keyword k ON j.keyword = k.keyword_name
JOIN JobSource s ON s.source_name = 'Monster';

