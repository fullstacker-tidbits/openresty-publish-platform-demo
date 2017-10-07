CREATE TABLE IF NOT EXISTS endpoint (
    eid INT AUTO_INCREMENT,
    endpoint VARCHAR(256),
    ip VARCHAR(16),
    hostname VARCHAR(256),
    uri VARCHAR(256),
    PRIMARY KEY (eid)
)
