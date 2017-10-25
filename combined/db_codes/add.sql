#search on max three evidence and combined the result with average score at the end


#search with selected multiple evidences with one drug name as parameters
drop procedure if exists newDrugAddition;
DELIMITER $$
create procedure newDrugAddition(IN drugID VARCHAR(255), IN drugName VARCHAR(255), IN evi1 VARCHAR(255))
begin

    DECLARE cur1 cursor for SELECT t.TABLE_NAME FROM information_schema.columns t
        WHERE t.table_schema='drugdb' and t.TABLE_NAME like 'target%';
    DECLARE cur1_1 cursor for SELECT t.TABLE_NAME FROM information_schema.columns t
        WHERE t.table_schema='drugdb' and t.TABLE_NAME like 'target%' and t.COLUMN_NAME = 'DRUGBANK_ID';
    DECLARE cur1_2 cursor for SELECT t.TABLE_NAME, t.COLUMN_NAME FROM information_schema.columns t
        WHERE t.table_schema='drugdb' and t.TABLE_NAME like 'target%';
    
    DECLARE cur2 cursor for SELECT t.TABLE_NAME FROM information_schema.columns t
        WHERE t.table_schema='drugdb' and t.TABLE_NAME like 'chemical_structure%';
    DECLARE cur2_1 cursor for SELECT t.TABLE_NAME FROM information_schema.columns t
        WHERE t.table_schema='drugdb' and t.TABLE_NAME like 'chemical_structure%' and t.COLUMN_NAME = 'DRUGBANK_ID';
    DECLARE cur2_2 cursor for SELECT t.TABLE_NAME, t.COLUMN_NAME FROM information_schema.columns t
        WHERE t.table_schema='drugdb' and t.TABLE_NAME like 'chemical_structure%';

    DECLARE cur3 cursor for SELECT t.TABLE_NAME FROM information_schema.columns t
        WHERE t.table_schema='drugdb' and t.TABLE_NAME like 'pathway%';
    DECLARE cur3_1 cursor for SELECT t.TABLE_NAME FROM information_schema.columns t
        WHERE t.table_schema='drugdb' and t.TABLE_NAME like 'pathway%' and t.COLUMN_NAME = 'DRUGBANK_ID';
    DECLARE cur3_2 cursor for SELECT t.TABLE_NAME, t.COLUMN_NAME FROM information_schema.columns t
        WHERE t.table_schema='drugdb' and t.TABLE_NAME like 'pathway%';

    if not exists(select ID from info where ID = drugID) THEN 
        set @row = concat('insert into info (ID, `GENERIC NAME`) values ( \'', drugID,  '\', \'', drugName,'\')');
        select @row;
        PREPARE r FROM @row;
        EXECUTE r;
        DEALLOCATE PREPARE r;
    end if;
    #add the new row for all the table drugbank_id
    open cur1_1;
    begin
        DECLARE done int default false;
        DECLARE table_name1_1 CHAR(255);
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
        myloop1: loop
            fetch cur1_1 into table_name1_1; #target0, target1....
            if done then
                leave myloop1;
            end if;
            SET @tempTable = table_name1_1; 

            #INSERT INTO pathway9(DRUGBANK_ID) select 'DB30000' from pathway9 where not exists(select DRUGBANK_ID from pathway9 where DRUGBANK_ID = 'DB30000');
 
            #set @insertFirstID = concat('insert into ', @tempTable, '(DRUGBANK_ID) values (\'', drugID ,'\')');
            set @insertFirstID = concat('insert into ', @tempTable, '(DRUGBANK_ID) SELECT \'',drugID,'\' from ',@tempTable,' where not exists (select DRUGBANK_ID from ', @tempTable,' where DRUGBANK_ID = \'',drugID,'\')');
            #select @insertFirstID;
            PREPARE re FROM @insertFirstID;
            EXECUTE re;
            DEALLOCATE PREPARE re;

        end loop;
    end;
    close cur1_1;

    open cur2_1;
    begin
        DECLARE done int default false;
        DECLARE table_name2_1 CHAR(255);
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
        myloop4: loop
            fetch cur2_1 into table_name2_1; #target0, target1....
            if done then
                leave myloop4;
            end if;
            SET @tempTable = table_name2_1; 
            set @tempTableID = drugID; 
            #if not exists(select DRUGBANK_ID from table_name2_1 where ID = drugID) THEN 
            set @insertFirstID = concat('insert into ', @tempTable, '(DRUGBANK_ID) SELECT \'',drugID,'\' from ',@tempTable,' where not exists (select DRUGBANK_ID from ', @tempTable,' where DRUGBANK_ID = \'',drugID,'\')');
            #select @insertFirstID;
            PREPARE re FROM @insertFirstID;
            EXECUTE re;
            DEALLOCATE PREPARE re;
            #end if;
        end loop;
    end;
    close cur2_1;#
    open cur3_1;
    begin
        DECLARE done int default false;
        DECLARE table_name3_1 CHAR(255);
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
        myloop7: loop
            fetch cur3_1 into table_name3_1;
            if done then
                leave myloop7;
            end if;
            SET @tempTable = table_name3_1; 
            #select @tempTable;
            set @tempTableID = drugID; 
            #if not exists(select DRUGBANK_ID from table_name3_1 where ID = drugID) THEN 
            set @insertFirstID = concat('insert into ', @tempTable, '(DRUGBANK_ID) SELECT \'',drugID,'\' from ',@tempTable,' where not exists (select DRUGBANK_ID from ', @tempTable,' where DRUGBANK_ID = \'',drugID,'\')');
            #select @insertFirstID;
            PREPARE re FROM @insertFirstID;
            EXECUTE re;
            DEALLOCATE PREPARE re;
            #end if;
        end loop;
    end;
    close cur3_1;#

    #new drug input --> drugID as the table name
    if evi1 = 'target' then 
        #add the column to the file
        open cur1;
        begin
            DECLARE done int default false;
            DECLARE table_name1_2 CHAR(255);
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
            myloop2: loop
                fetch cur1 into table_name1_2; #target0, target1....
                if done then
                    leave myloop2;
                end if;
                SET @tempTable1 = table_name1_2;
            end loop;
            #add to the end of the last file of the evidence file
            #select @tempTable1;
            #add the new null column for the new drug with its ID as the column name
            set @tempTableID1 = drugID; #new uplaod file for the new drug
            IF NOT EXISTS( SELECT NULL
                        FROM INFORMATION_SCHEMA.COLUMNS
                       WHERE table_name = @tempTable1
                         AND table_schema = 'drugdb'
                         AND column_name = @tempTableID1)  THEN#
                set @tt = concat('alter table ', @tempTable1, ' add column ', @tempTableID1,' VARCHAR(255)');
                PREPARE res FROM @tt;
                EXECUTE res;
                DEALLOCATE PREPARE res;
            END IF;#
            set @updateTable = concat('update ', @tempTable1, ' f inner join ( select DRUGBANK_ID, ', drugID ,' from ', @tempTableID1, ' )a on f.DRUGBANK_ID = a.DRUGBANK_ID set f.',@tempTableID1,'= a.', drugID);
            PREPARE re FROM @updateTable;
            EXECUTE re;
            DEALLOCATE PREPARE re;
            set @updateToNull = concat('update ', @tempTable1, ' set ',drugID ,' = 0 where ',drugID,' is null');
            PREPARE re FROM @updateToNull;
            EXECUTE re;
            DEALLOCATE PREPARE re;
        end;
        close cur1; 
        #find where the latest column store in
        select @tempTable1;
        #double check the present drugID
        select @tempTableID1;##
        #add all values into the row for every files
        open cur1_2;
        BEGIN
            DECLARE done int default false;
            DECLARE table_name1_3 CHAR(255);
            DECLARE column_name1_3 CHAR(255);
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;#
            myloop3: loop
                fetch cur1_2 into table_name1_3, column_name1_3; #target0, target1....
                if done then
                    leave myloop3;
                end if;
            SET @tempTable2 = table_name1_3;
            set @tempColumn2 = column_name1_3;#
            set @updateTableA = concat('update ', @tempTable2, ' a, (select ',drugID,' from ', @tempTable1,' where DRUGBANK_ID = \'', @tempColumn2,'\') b set a.', @tempColumn2 , ' = coalesce(b.',drugID,',0) where DRUGBANK_ID = \'', drugID, '\'');
            SELECT @updateTableA;
            PREPARE re FROM @updateTableA;
            EXECUTE re;
            DEALLOCATE PREPARE re;
            select @tempTable2;
            select @tempColumn2;
            end loop;
        end;
        close cur1_2;#
        open cur2;
        begin
            DECLARE done int default false;
            DECLARE table_name2_2 CHAR(255);
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
            myloop5: loop
                fetch cur2 into table_name2_2;
                if done then
                    leave myloop5;
                end if;
                SET @tempTable1 = table_name2_2;
            end loop;
            #add to the end of the last file of the evidence file
            #select @tempTable1;
            #add the new null column for the new drug with its ID as the column name
            set @tempTableID1 = drugID; #new uplaod file for the new drug
            IF NOT EXISTS( SELECT NULL
                        FROM INFORMATION_SCHEMA.COLUMNS
                       WHERE table_name = @tempTable1
                         AND table_schema = 'drugdb'
                         AND column_name = @tempTableID1)  THEN#
                set @tt = concat('alter table ', @tempTable1, ' add column ', @tempTableID1,' VARCHAR(255)');
                PREPARE res FROM @tt;
                EXECUTE res;
                DEALLOCATE PREPARE res;
            END IF;            
            set @updateToNull = concat('update ', @tempTable1, ' set ',drugID ,' = 0 where ',drugID,' is null');
            PREPARE re FROM @updateToNull;
            EXECUTE re;
            DEALLOCATE PREPARE re;
        end;
        close cur2; #
        open cur3;
        begin
            DECLARE done int default false;
            DECLARE table_name3_2 CHAR(255);
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
            myloop8: loop
                fetch cur3 into table_name3_2; #target0, target1....
                if done then
                    leave myloop8;
                end if;
                SET @tempTable1 = table_name3_2;
            end loop;
            #add to the end of the last file of the evidence file
            #select @tempTable1;
            set @tempTableID1 = drugID; #new uplaod file for the new drug
            IF NOT EXISTS( SELECT NULL
                        FROM INFORMATION_SCHEMA.COLUMNS
                       WHERE table_name = @tempTable1
                         AND table_schema = 'drugdb'
                         AND column_name = @tempTableID1)  THEN#
                set @tt = concat('alter table ', @tempTable1, ' add column ', @tempTableID1,' VARCHAR(255)');
                PREPARE res FROM @tt;
                EXECUTE res;
                DEALLOCATE PREPARE res;
            END IF;
            set @updateToNull = concat('update ', @tempTable1, ' set ',drugID ,' = 0 where ',drugID,' is null');
            PREPARE re FROM @updateToNull;
            EXECUTE re;
            DEALLOCATE PREPARE re;
        end;
        close cur3; 
    end if;#
    if evi1 = 'chemical_structure' then 
        #add the column to the file
        open cur2;
        begin
            DECLARE done int default false;
            DECLARE table_name2_2 CHAR(255);
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
            myloop5: loop
                fetch cur2 into table_name2_2;
                if done then
                    leave myloop5;
                end if;
                SET @tempTable1 = table_name2_2;
            end loop;
            #add to the end of the last file of the evidence file
            #select @tempTable1;
            #add the new null column for the new drug with its ID as the column name
            set @tempTableID1 = drugID; #new uplaod file for the new drug
            IF NOT EXISTS( SELECT NULL
                        FROM INFORMATION_SCHEMA.COLUMNS
                       WHERE table_name = @tempTable1
                         AND table_schema = 'drugdb'
                         AND column_name = @tempTableID1)  THEN#
                set @tt = concat('alter table ', @tempTable1, ' add column ', @tempTableID1,' VARCHAR(255)');
                PREPARE res FROM @tt;
                EXECUTE res;
                DEALLOCATE PREPARE res;
            END IF;
            set @updateTable = concat('update ', @tempTable1, ' f inner join ( select DRUGBANK_ID, ', drugID ,' from ', @tempTableID1, ' )a on f.DRUGBANK_ID = a.DRUGBANK_ID set f.',@tempTableID1,'= a.', drugID);
            PREPARE re FROM @updateTable;
            EXECUTE re;
            DEALLOCATE PREPARE re;
            set @updateToNull = concat('update ', @tempTable1, ' set ',drugID ,' = 0 where ',drugID,' is null');
            PREPARE re FROM @updateToNull;
            EXECUTE re;
            DEALLOCATE PREPARE re;
        end;
        close cur2; #
        #add all values into the row for every files
        open cur2_2;
        BEGIN
            DECLARE done int default false;
            DECLARE table_name2_3 CHAR(255);
            DECLARE column_name2_3 CHAR(255);
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
            myloop6: loop
                fetch cur2_2 into table_name2_3, column_name2_3; #target0, target1....
                if done then
                    leave myloop6;
                end if;
            SET @tempTable2 = table_name2_3;
            set @tempColumn2 = column_name2_3;
            set @updateTableA = concat('update ', @tempTable2, ' a, (select ',drugID,' from ', @tempTable1,' where DRUGBANK_ID = \'', @tempColumn2,'\') b set a.', @tempColumn2 , ' = coalesce(b.',drugID,',0) where DRUGBANK_ID = \'', drugID, '\'');
            SELECT @updateTableA;
            PREPARE re FROM @updateTableA;
            EXECUTE re;
            DEALLOCATE PREPARE re;
            select @tempTable2;
            select @tempColumn2;
            end loop;
        end;
        close cur2_2;#
        open cur1;
        begin
            DECLARE done int default false;
            DECLARE table_name1_2 CHAR(255);
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
            myloop2: loop
                fetch cur1 into table_name1_2; #target0, target1....
                if done then
                    leave myloop2;
                end if;
                SET @tempTable1 = table_name1_2;
            end loop;
            #add to the end of the last file of the evidence file
            #select @tempTable1;
            #add the new null column for the new drug with its ID as the column name
            set @tempTableID1 = drugID; #new uplaod file for the new drug
            IF NOT EXISTS( SELECT NULL
                        FROM INFORMATION_SCHEMA.COLUMNS
                       WHERE table_name = @tempTable1
                         AND table_schema = 'drugdb'
                         AND column_name = @tempTableID1)  THEN#
                set @tt = concat('alter table ', @tempTable1, ' add column ', @tempTableID1,' VARCHAR(255)');
                PREPARE res FROM @tt;
                EXECUTE res;
                DEALLOCATE PREPARE res;
            END IF;
            
            set @updateToNull = concat('update ', @tempTable1, ' set ',drugID ,' = 0 where ',drugID,' is null');
            PREPARE re FROM @updateToNull;
            EXECUTE re;
            DEALLOCATE PREPARE re;
        end;
        close cur1; #
        open cur3;
        begin
            DECLARE done int default false;
            DECLARE table_name3_2 CHAR(255);
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
            myloop8: loop
                fetch cur3 into table_name3_2; #target0, target1....
                if done then
                    leave myloop8;
                end if;
                SET @tempTable1 = table_name3_2;
            end loop;
            #add to the end of the last file of the evidence file
            #select @tempTable1;
            set @tempTableID1 = drugID; #new uplaod file for the new drug
            IF NOT EXISTS( SELECT NULL
                        FROM INFORMATION_SCHEMA.COLUMNS
                       WHERE table_name = @tempTable1
                         AND table_schema = 'drugdb'
                         AND column_name = @tempTableID1)  THEN#
                set @tt = concat('alter table ', @tempTable1, ' add column ', @tempTableID1,' VARCHAR(255)');
                PREPARE res FROM @tt;
                EXECUTE res;
                DEALLOCATE PREPARE res;
            END IF;
            set @updateToNull = concat('update ', @tempTable1, ' set ',drugID ,' = 0 where ',drugID,' is null');
            PREPARE re FROM @updateToNull;
            EXECUTE re;
            DEALLOCATE PREPARE re;
        end;
        close cur3; 
    end if;#
    if evi1 = 'pathway' then 
        #add the column to the file
        open cur3;
        begin
            DECLARE done int default false;
            DECLARE table_name3_2 CHAR(255);
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
            myloop8: loop
                fetch cur3 into table_name3_2; #target0, target1....
                if done then
                    leave myloop8;
                end if;
                SET @tempTable1 = table_name3_2;
            end loop;
            #add to the end of the last file of the evidence file
            #select @tempTable1;
            set @tempTableID1 = drugID; #new uplaod file for the new drug
            IF NOT EXISTS( SELECT NULL
                        FROM INFORMATION_SCHEMA.COLUMNS
                       WHERE table_name = @tempTable1
                         AND table_schema = 'drugdb'
                         AND column_name = @tempTableID1)  THEN#
                set @tt = concat('alter table ', @tempTable1, ' add column ', @tempTableID1,' VARCHAR(255)');
                PREPARE res FROM @tt;
                EXECUTE res;
                DEALLOCATE PREPARE res;
            END IF;
            set @updateTable = concat('update ', @tempTable1, ' f inner join ( select DRUGBANK_ID, ', drugID ,' from ', @tempTableID1, ' )a on f.DRUGBANK_ID = a.DRUGBANK_ID set f.',@tempTableID1,'= a.', drugID);
            PREPARE re FROM @updateTable;
            EXECUTE re;
            DEALLOCATE PREPARE re;#
            set @updateToNull = concat('update ', @tempTable1, ' set ',drugID ,' = 0 where ',drugID,' is null');
            PREPARE re FROM @updateToNull;
            EXECUTE re;
            DEALLOCATE PREPARE re;
        end;
        close cur3; #

        #add all values into the row for every files
        open cur3_2;
        BEGIN
            DECLARE done int default false;
            DECLARE table_name3_3 CHAR(255);
            DECLARE column_name3_3 CHAR(255);
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;#
            myloop9: loop
                fetch cur3_2 into table_name3_3, column_name3_3; #target0, target1....
                if done then
                    leave myloop9;
                end if;
            SET @tempTable2 = table_name3_3;
            set @tempColumn2 = column_name3_3;#
            set @updateTableA = concat('update ', @tempTable2, ' a, (select ',drugID,' from ', @tempTable1,' where DRUGBANK_ID = \'', @tempColumn2,'\') b set a.', @tempColumn2 , ' = coalesce(b.',drugID,',0) where DRUGBANK_ID = \'', drugID, '\'');
            SELECT @updateTableA;
            PREPARE re FROM @updateTableA;
            EXECUTE re;
            DEALLOCATE PREPARE re;
            select @tempTable2;
            select @tempColumn2;
            end loop;
        end;
        close cur3_2;#
        open cur1;
        begin
            DECLARE done int default false;
            DECLARE table_name1_2 CHAR(255);
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
            myloop2: loop
                fetch cur1 into table_name1_2; #target0, target1....
                if done then
                    leave myloop2;
                end if;
                SET @tempTable1 = table_name1_2;
            end loop;
            #add to the end of the last file of the evidence file
            #select @tempTable1;
            #add the new null column for the new drug with its ID as the column name
            set @tempTableID1 = drugID; #new uplaod file for the new drug
            IF NOT EXISTS( SELECT NULL
                        FROM INFORMATION_SCHEMA.COLUMNS
                       WHERE table_name = @tempTable1
                         AND table_schema = 'drugdb'
                         AND column_name = @tempTableID1)  THEN#
                set @tt = concat('alter table ', @tempTable1, ' add column ', @tempTableID1,' VARCHAR(255)');
                PREPARE res FROM @tt;
                EXECUTE res;
                DEALLOCATE PREPARE res;
            END IF;
            set @updateToNull = concat('update ', @tempTable1, ' set ',drugID ,' = 0 where ',drugID,' is null');
            PREPARE re FROM @updateToNull;
            EXECUTE re;
            DEALLOCATE PREPARE re;
        end;
        close cur1; #
        open cur2;
        begin
            DECLARE done int default false;
            DECLARE table_name2_2 CHAR(255);
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
            myloop5: loop
                fetch cur2 into table_name2_2;
                if done then
                    leave myloop5;
                end if;
                SET @tempTable1 = table_name2_2;
            end loop;
            #add to the end of the last file of the evidence file
            #select @tempTable1;
            #add the new null column for the new drug with its ID as the column name
            set @tempTableID1 = drugID; #new uplaod file for the new drug
            IF NOT EXISTS( SELECT NULL
                        FROM INFORMATION_SCHEMA.COLUMNS
                       WHERE table_name = @tempTable1
                         AND table_schema = 'drugdb'
                         AND column_name = @tempTableID1)  THEN#
                set @tt = concat('alter table ', @tempTable1, ' add column ', @tempTableID1,' VARCHAR(255)');
                PREPARE res FROM @tt;
                EXECUTE res;
                DEALLOCATE PREPARE res;
            END IF;
            set @updateToNull = concat('update ', @tempTable1, ' set ',drugID ,' = 0 where ',drugID,' is null');
            PREPARE re FROM @updateToNull;
            EXECUTE re;
            DEALLOCATE PREPARE re;
        end;
        close cur2; 
    end if;
    #set @dropInputTable = concat('drop table if exists ', drugID);
    #PREPARE re FROM @dropInputTable;
    #EXECUTE re;
    #DEALLOCATE PREPARE re;

end$$ 
DELIMITER ;




#call newDrugAddition('DB30000','ADCCCC','pathway');

