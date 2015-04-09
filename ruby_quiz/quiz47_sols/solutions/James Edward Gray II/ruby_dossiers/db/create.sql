DROP TABLE IF EXISTS people;
CREATE TABLE people (
	id           INT          NOT NULL auto_increment,
	full_name    VARCHAR(100) NOT NULL,
	email        VARCHAR(100) NOT NULL,
	password     CHAR(40)     NOT NULL,
	confirmation CHAR(6)      DEFAULT NULL,
	created_on   DATE         NOT NULL,
	updated_on   DATE         NOT NULL,
	PRIMARY KEY(id)
);

DROP TABLE IF EXISTS jobs;
CREATE TABLE jobs (
	id              INT                NOT NULL auto_increment,
	person_id       INT                NOT NULL,
	company         VARCHAR(100)       NOT NULL,
	country         VARCHAR(100)       NOT NULL,
	state           VARCHAR(100)       NOT NULL,
	city            VARCHAR(100)       NOT NULL,
	pay             VARCHAR(50)        NOT NULL,
	terms           ENUM( 'contract',
	                      'hourly',
	                      'salaried' ) NOT NULL,
	on_site         ENUM( 'none',
	                      'some',
	                      'all' )      NOT NULL,
	hours           VARCHAR(50)        NOT NULL,
	travel          VARCHAR(50)        NOT NULL,
	description     TEXT               NOT NULL,
	required_skills TEXT               NOT NULL,
	desired_skills  TEXT,
	how_to_apply    TEXT               NOT NULL,
	created_on      DATE               NOT NULL,
	updated_on      DATE               NOT NULL,
	PRIMARY KEY(id)
);
