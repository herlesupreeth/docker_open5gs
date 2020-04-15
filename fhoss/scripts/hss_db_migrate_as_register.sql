use hss_db;

-- ----------------------------------------------------------------------------
-- We'll need to use IF to determine whether the database is already upgraded.
-- MySQL only allows us to use IF from within stored procedures, so we'll
-- create a very short-lived stored procedure.  Before we do that, delete any
-- existing procedure.
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS upgrade_hss_database;

-- ----------------------------------------------------------------------------
-- Define the stored procedure.  Before doing this, we must redefine the
-- delimiter so that the end of statements within the body of the stored
-- procedure are not considered to be the end of the stored procedure as a
-- whole.
-- ----------------------------------------------------------------------------
DELIMITER $$
CREATE PROCEDURE upgrade_hss_database()
BEGIN
  -- --------------------------------------------------------------------------
  -- Add IncludeRegisterRequest/Response flags.
  -- --------------------------------------------------------------------------
  IF NOT EXISTS (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='application_server' AND COLUMN_NAME='include_register_response') THEN
    ALTER TABLE application_server ADD COLUMN include_register_response TINYINT NOT NULL DEFAULT 0;
  END IF;

  IF NOT EXISTS (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='application_server' AND COLUMN_NAME='include_register_request') THEN
    ALTER TABLE application_server ADD COLUMN include_register_request TINYINT NOT NULL DEFAULT 0;
  END IF;

END $$
DELIMITER ;

-- ----------------------------------------------------------------------------
-- Call the upgrade procedure and then drop it from the database.
-- ----------------------------------------------------------------------------
CALL upgrade_hss_database();
DROP PROCEDURE upgrade_hss_database;
