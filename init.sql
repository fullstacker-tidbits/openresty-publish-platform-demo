CREATE TABLE IF NOT EXISTS endpoint (
    eid INT AUTO_INCREMENT,
    endpoint VARCHAR(256),
    ip VARCHAR(16),
    hostname VARCHAR(256),
    resource VARCHAR(256),
    PRIMARY KEY (eid)
)
