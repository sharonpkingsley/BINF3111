drop procedure if exists deleteTables;
DELIMITER $$
create procedure deleteTables(IN evi1 VARCHAR(255))
begin

    DECLARE cur1_1 cursor for SELECT t.TABLE_NAME FROM information_schema.columns t
        WHERE t.table_schema='drugdb' and t.TABLE_NAME like 'target%';
   
    DECLARE cur2_1 cursor for SELECT t.TABLE_NAME FROM information_schema.columns t
        WHERE t.table_schema='drugdb' and t.TABLE_NAME like 'chemical_structure%';
    
    DECLARE cur3_1 cursor for SELECT t.TABLE_NAME FROM information_schema.columns t
        WHERE t.table_schema='drugdb' and t.TABLE_NAME like 'pathway%';
    
    #new drug input --> drugID as the table name
    if evi1 = 'target' then 
        #change for first drug column
        open cur1_1;
        begin
            DECLARE done int default false;
            DECLARE table_name1_A CHAR(255);
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
            myloop: loop
                fetch cur1_1 into table_name1_A; 
                if done then
                    leave myloop;
                end if;
                SET @tempTableA = table_name1_A; 
                set @dropTableA = concat('drop table if exists ', @tempTableA);
                PREPARE re FROM @dropTableA;
                EXECUTE re;
                DEALLOCATE PREPARE re;
            end loop;
        end;
        close cur1_1; 

       
    end if;


    if evi1 = 'chemical_structure' then 
        #change for first drug column
        open cur2_1;
        begin
            DECLARE done int default false;
            DECLARE table_name2_A CHAR(255);
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
            myloop: loop
                fetch cur2_1 into table_name2_A; #target0, target1....
                if done then
                    leave myloop;
                end if;
                SET @tempTableA = table_name2_A; 
                set @dropTableA = concat('drop table if exists ', @tempTableA);
                PREPARE re FROM @dropTableA;
                EXECUTE re;
                DEALLOCATE PREPARE re;
            end loop;
            
        end;
        close cur2_1; 
       
        
    end if;

    if evi1 = 'pathway' then 
        #change for first drug column
        open cur3_1;
        begin
            DECLARE done int default false;
            DECLARE table_name3_A CHAR(255);
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
            myloop: loop
                fetch cur3_1 into table_name3_A; #target0, target1....
                if done then
                    leave myloop;
                end if;
                SET @tempTableA = table_name3_A; 
                set @dropTableA = concat('drop table if exists ', @tempTableA);
                PREPARE re FROM @dropTableA;
                EXECUTE re;
                DEALLOCATE PREPARE re;
            end loop;
        end;
        close cur3_1; 
    end if;

end$$ 
DELIMITER ;
