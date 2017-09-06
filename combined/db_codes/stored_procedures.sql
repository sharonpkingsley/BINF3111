DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_findAllEvidence`(
IN p_drugname VARCHAR(20)
)
BEGIN
	DECLARE tb VARCHAR(100);
	DECLARE cur1 CURSOR FOR SELECT DISTINCT table_name FROM information_schema.tables where table_schema='drugdb';
	
	OPEN cur1;

	read_loop: LOOP
		FETCH cur1 INTO tb;
		SET @query = 'SELECT DrugNames, p_drugname FROM ' + tb +' where DrugNames!=p_drugname';
		EXEC(@query);
	END LOOP;

	CLOSE cur1;
END$$
DELIMITER ;