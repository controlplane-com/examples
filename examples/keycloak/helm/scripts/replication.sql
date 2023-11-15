CREATE OR REPLACE FUNCTION spock_assign_repset()
RETURNS event_trigger AS $$
DECLARE obj record;
BEGIN
    FOR obj IN SELECT * FROM pg_event_trigger_ddl_commands()
    LOOP
        IF obj.object_type = 'table' THEN
            IF obj.schema_name = 'public' THEN
                PERFORM spock.repset_add_table('cpln_default', obj.objid);
            ELSIF NOT obj.in_extension THEN
                PERFORM spock.repset_add_table('default', obj.objid);
            END IF;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE EVENT TRIGGER spock_assign_repset_trg
    ON ddl_command_end
    WHEN TAG IN ('CREATE TABLE', 'CREATE TABLE AS')
    EXECUTE PROCEDURE spock_assign_repset();

ALTER EVENT TRIGGER spock_assign_repset_trg ENABLE ALWAYS;