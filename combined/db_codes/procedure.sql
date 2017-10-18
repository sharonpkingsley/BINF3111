DROP PROCEDURE IF EXISTS searchOneEvidence;
DELIMITER $$
CREATE PROCEDURE searchOneEvidence(IN drugName VARCHAR(255),IN evidenceName VARCHAR(255))
BEGIN
  SET @t1 =CONCAT('SELECT `Unnamed: 0`, ',drugName ,' FROM ',evidenceName, ' WHERE `Unnamed: 0` != "',drugName, '"');
  PREPARE result FROM @t1;
  EXECUTE result;
  DEALLOCATE PREPARE result;
END$$
DELIMITER ;

call searchOneEvidence('ANWABDrug','qq')//
call searchAllEvidence('ANWABDrug')//

#search all evidence with one drugName as a parameter
#database name = 'mydrugfinaldatabase'
drop procedure if exists searchAllEvidence;
DELIMITER $$
create procedure searchAllEvidence(IN drugName VARCHAR(255))
begin
    DECLARE done int default false;
    DECLARE table_name CHAR(255);

    DECLARE cur1 cursor for SELECT t.TABLE_NAME FROM information_schema.tables t
    	WHERE t.table_schema='drugdb';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    open cur1;
    myloop: loop
        fetch cur1 into table_name;
        if done then
            leave myloop;
        end if;
        SET @t1 =CONCAT('SELECT `Unnamed: 0`, ',drugName ,' FROM ',TABLE_NAME, ' WHERE `Unnamed: 0` != "',drugName, '"');
		PREPARE result FROM @t1;
		EXECUTE result;
		DEALLOCATE PREPARE result;
    end loop;
    close cur1;
end $$
DELIMITER ;


DROP PROCEDURE IF EXISTS fullNetwork;
DELIMITER $$
CREATE PROCEDURE fullNetwork(IN drugName VARCHAR(255), IN evidenceName VARCHAR(255))
BEGIN
  SET @t1 =CONCAT('SELECT * FROM ',evidenceName);
  PREPARE result FROM @t1;
  EXECUTE result;
  DEALLOCATE PREPARE result;
END$$
DELIMITER ;

