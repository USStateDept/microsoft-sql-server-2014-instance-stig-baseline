SERVER_INSTANCE= attribute(
  'server_instance',
  description: 'SQL server instance we are connecting to',
  default: "WIN-FC4ANINFUFP"
)
control "V-67903" do
  title "SQL Server must produce Trace or Audit records of its enforcement of
  access restrictions associated with changes to the configuration of the DBMS or
  database(s)."
  desc  "Without auditing the enforcement of access restrictions against
  changes to configuration, it would be difficult to identify attempted attacks
  and an audit trail would not be available for forensic investigation for
  after-the-fact actions.

      Enforcement actions are the methods or mechanisms used to prevent
  unauthorized changes to configuration settings. Enforcement action methods may
  be as simple as denying access to a file based on the application of file
  permissions (access restriction). Audit items may consist of lists of actions
  blocked by access restrictions or changes identified after the fact.

      Use of SQL Server Audit is recommended.  All features of SQL Server Audit
  are available in the Enterprise and Developer editions of SQL Server 2014.  It
  is not available at the database level in other editions.  For this or legacy
  reasons, the instance may be using SQL Server Trace for auditing, which remains
  an acceptable solution for the time being.  Note, however, that Microsoft
  intends to remove most aspects of Trace at some point after SQL Server 2016.
  "
  impact 0.7
  tag "gtitle": "SRG-APP-000381-DB-000361"
  tag "gid": "V-67903"
  tag "rid": "SV-82393r3_rule"
  tag "stig_id": "SQL4-00-034000"
  tag "fix_id": "F-74019r2_fix"
  tag "cci": ["CCI-001814"]
  tag "nist": ["CM-5 (1)", "Rev_4"]
  tag "false_negatives": nil
  tag "false_positives": nil
  tag "documentable": false
  tag "mitigations": nil
  tag "severity_override_guidance": false
  tag "potential_impacts": nil
  tag "third_party_tools": nil
  tag "mitigation_controls": nil
  tag "responsibility": nil
  tag "ia_controls": nil
  tag "check": "If neither SQL Server Audit nor SQL Server Trace is in use for
  audit purposes, this is a finding.

  If SQL Server Trace is in use for audit purposes, verify that all required
  events are being audited.  From the query prompt:
  SELECT * FROM sys.traces;
  All currently defined traces for the SQL server instance will be listed.

  If no traces are returned, this is a finding.

  Determine the trace(s) being used for the auditing requirement.
  In the following, replace # with a trace ID being used for the auditing
  requirements.
  From the query prompt:
  SELECT DISTINCT(eventid) FROM sys.fn_trace_geteventinfo(#);

  The following required event IDs should be among those listed; if not, this is
  a finding:

  102 -- Audit Statement GDR Event
  103 -- Audit Object GDR Event
  104 -- Audit AddLogin Event
  105 -- Audit Login GDR Event
  106 -- Audit Login Change Property Event
  107 -- Audit Login Change Password Event
  108 -- Audit Add Login to Server Role Event
  109 -- Audit Add DB User Event
  110 -- Audit Add Member to DB Role Event
  111 -- Audit Add Role Event
  112 -- Audit App Role Change Password Event
  113 -- Audit Statement Permission Event
  115 -- Audit Backup/Restore Event
  116 -- Audit DBCC Event
  117 -- Audit Change Audit Event
  118 -- Audit Object Derived Permission Event
  128 -- Audit Database Management Event
  129 -- Audit Database Object Management Event
  130 -- Audit Database Principal Management Event
  131 -- Audit Schema Object Management Event
  132 -- Audit Server Principal Impersonation Event
  133 -- Audit Database Principal Impersonation Event
  134 -- Audit Server Object Take Ownership Event
  135 -- Audit Database Object Take Ownership Event
  152 -- Audit Change Database Owner
  153 -- Audit Schema Object Take Ownership Event
  162 -- User error message
  170 -- Audit Server Scope GDR Event
  171 -- Audit Server Object GDR Event
  172 -- Audit Database Object GDR Event
  173 -- Audit Server Operation Event
  175 -- Audit Server Alter Trace Event
  176 -- Audit Server Object Management Event
  177 -- Audit Server Principal Management Event


  If SQL Server Audit is in use, proceed as follows.

  The basic SQL Server Audit configuration provided in the supplemental file
  Audit.sql uses broad, server-level audit action groups for this purpose.  SQL
  Server Audit's flexibility makes other techniques possible.  If an alternative
  technique is in use and demonstrated effective, this is not a finding.

  Determine the name(s) of the server audit specification(s) in use.

  To look at audits and audit specifications, in Management Studio's object
  explorer, expand
  <server name> >> Security >> Audits
  and
  <server name> >> Security >> Server Audit Specifications.
  Also,
  <server name> >> Databases >> <database name> >> Security >> Database Audit
  Specifications.

  Alternatively, review the contents of the system views with \"audit\" in their
  names.

  Run the following code to verify that all configuration-related actions are
  being audited:
  USE [master];
  GO
  SELECT * FROM sys.server_audit_specification_details WHERE
  server_specification_id =
  (SELECT server_specification_id FROM sys.server_audit_specifications WHERE
  [name] = '<server_audit_specification_name>')
  AND audit_action_name IN
  (
  'APPLICATION_ROLE_CHANGE_PASSWORD_GROUP',
  'AUDIT_CHANGE_GROUP',
  'BACKUP_RESTORE_GROUP',
  'DATABASE_CHANGE_GROUP',
  'DATABASE_OBJECT_ACCESS_GROUP',
  'DATABASE_OBJECT_CHANGE_GROUP',
  'DATABASE_OBJECT_OWNERSHIP_CHANGE_GROUP',
  'DATABASE_OBJECT_PERMISSION_CHANGE_GROUP',
  'DATABASE_OPERATION_GROUP',
  'DATABASE_OWNERSHIP_CHANGE_GROUP',
  'DATABASE_PERMISSION_CHANGE_GROUP',
  'DATABASE_PRINCIPAL_CHANGE_GROUP',
  'DATABASE_PRINCIPAL_IMPERSONATION_GROUP',
  'DATABASE_ROLE_MEMBER_CHANGE_GROUP',
  'DBCC_GROUP',
  'LOGIN_CHANGE_PASSWORD_GROUP',
  'SCHEMA_OBJECT_CHANGE_GROUP',
  'SCHEMA_OBJECT_OWNERSHIP_CHANGE_GROUP',
  'SCHEMA_OBJECT_PERMISSION_CHANGE_GROUP',
  'SERVER_OBJECT_CHANGE_GROUP',
  'SERVER_OBJECT_OWNERSHIP_CHANGE_GROUP',
  'SERVER_OBJECT_PERMISSION_CHANGE_GROUP',
  'SERVER_OPERATION_GROUP',
  'SERVER_PERMISSION_CHANGE_GROUP',
  'SERVER_PRINCIPAL_IMPERSONATION_GROUP',
  'SERVER_ROLE_MEMBER_CHANGE_GROUP',
  'SERVER_STATE_CHANGE_GROUP',
  'TRACE_CHANGE_GROUP'
  );
  GO

  Examine the list produced by the query.

  If any of the audit action groups specified in the WHERE clause are not
  included in the list, this is a finding.

  If the audited_result column is not  \"SUCCESS AND FAILURE\" on every row, this
  is a finding."
  tag "fix": "Design and deploy a SQL Server Audit or Trace that captures all
  auditable events.  The script provided in the supplemental file Trace.sql can
  be used to create a trace.

  Where SQL Server Audit is in use, design and deploy a SQL Server Audit that
  captures all auditable events.  The script provided in the supplemental file
  Audit.sql can be used for this.

  Alternatively, to add the necessary data capture to an existing server audit
  specification, run the script:
  USE [master];
  GO
  ALTER SERVER AUDIT SPECIFICATION <server_audit_specification_name> WITH (STATE
  = OFF);
  GO
  ALTER SERVER AUDIT SPECIFICATION <server_audit_specification_name>
   ADD (APPLICATION_ROLE_CHANGE_PASSWORD_GROUP),
   ADD (AUDIT_CHANGE_GROUP),
   ADD (BACKUP_RESTORE_GROUP),
   ADD (DATABASE_CHANGE_GROUP),
   ADD (DATABASE_OBJECT_ACCESS_GROUP),
   ADD (DATABASE_OBJECT_CHANGE_GROUP),
   ADD (DATABASE_OBJECT_OWNERSHIP_CHANGE_GROUP),
   ADD (DATABASE_OBJECT_PERMISSION_CHANGE_GROUP),
   ADD (DATABASE_OPERATION_GROUP),
   ADD (DATABASE_OWNERSHIP_CHANGE_GROUP),
   ADD (DATABASE_PERMISSION_CHANGE_GROUP),
   ADD (DATABASE_PRINCIPAL_CHANGE_GROUP),
   ADD (DATABASE_PRINCIPAL_IMPERSONATION_GROUP),
   ADD (DATABASE_ROLE_MEMBER_CHANGE_GROUP),
   ADD (DBCC_GROUP),
   ADD (LOGIN_CHANGE_PASSWORD_GROUP),
   ADD (SCHEMA_OBJECT_CHANGE_GROUP),
   ADD (SCHEMA_OBJECT_OWNERSHIP_CHANGE_GROUP),
   ADD (SCHEMA_OBJECT_PERMISSION_CHANGE_GROUP),
   ADD (SERVER_OBJECT_CHANGE_GROUP),
   ADD (SERVER_OBJECT_OWNERSHIP_CHANGE_GROUP),
   ADD (SERVER_OBJECT_PERMISSION_CHANGE_GROUP),
   ADD (SERVER_OPERATION_GROUP),
   ADD (SERVER_PERMISSION_CHANGE_GROUP),
   ADD (SERVER_PRINCIPAL_IMPERSONATION_GROUP),
   ADD (SERVER_STATE_CHANGE_GROUP),
   ADD (SERVER_ROLE_MEMBER_CHANGE_GROUP),
   ADD (TRACE_CHANGE_GROUP)
  ;
  GO
  ALTER SERVER AUDIT SPECIFICATION <server_audit_specification_name> WITH (STATE
  = ON);
  GO"
  describe command("Invoke-Sqlcmd -Query \"SELECT * FROM sys.traces;\" -ServerInstance 'WIN-FC4ANINFUFP'") do
   its('stdout') { should_not eq '' }
  end
  get_columnid = command("Invoke-Sqlcmd -Query \"SELECT id FROM sys.traces;\" -ServerInstance 'WIN-FC4ANINFUFP' | Findstr /v 'id --'").stdout.strip.split("\n")
  
  get_columnid.each do | perms|  
    a = perms.strip
    describe command("Invoke-Sqlcmd -Query \"SELECT DISTINCT(eventid) FROM sys.fn_trace_geteventinfo(#{a}) WHERE eventid = 102;\" -ServerInstance '#{SERVER_INSTANCE}'") do
      its('stdout') { should_not eq '' }
    end
    describe command("Invoke-Sqlcmd -Query \"SELECT DISTINCT(eventid) FROM sys.fn_trace_geteventinfo(#{a}) WHERE eventid = 103;\" -ServerInstance '#{SERVER_INSTANCE}'") do
      its('stdout') { should_not eq '' }
    end
    describe command("Invoke-Sqlcmd -Query \"SELECT DISTINCT(eventid) FROM sys.fn_trace_geteventinfo(#{a}) WHERE eventid = 104;\" -ServerInstance '#{SERVER_INSTANCE}'") do
      its('stdout') { should_not eq '' }
    end
    describe command("Invoke-Sqlcmd -Query \"SELECT DISTINCT(eventid) FROM sys.fn_trace_geteventinfo(#{a}) WHERE eventid = 105;\" -ServerInstance '#{SERVER_INSTANCE}'") do
      its('stdout') { should_not eq '' }
    end
    describe command("Invoke-Sqlcmd -Query \"SELECT DISTINCT(eventid) FROM sys.fn_trace_geteventinfo(#{a}) WHERE eventid = 106;\" -ServerInstance '#{SERVER_INSTANCE}'") do
      its('stdout') { should_not eq '' }
    end
    describe command("Invoke-Sqlcmd -Query \"SELECT DISTINCT(eventid) FROM sys.fn_trace_geteventinfo(#{a}) WHERE eventid = 107;\" -ServerInstance '#{SERVER_INSTANCE}'") do
      its('stdout') { should_not eq '' }
    end
    describe command("Invoke-Sqlcmd -Query \"SELECT DISTINCT(eventid) FROM sys.fn_trace_geteventinfo(#{a}) WHERE eventid = 108;\" -ServerInstance '#{SERVER_INSTANCE}'") do
      its('stdout') { should_not eq '' }
    end
    describe command("Invoke-Sqlcmd -Query \"SELECT DISTINCT(eventid) FROM sys.fn_trace_geteventinfo(#{a}) WHERE eventid = 109;\" -ServerInstance '#{SERVER_INSTANCE}'") do
      its('stdout') { should_not eq '' }
    end
    describe command("Invoke-Sqlcmd -Query \"SELECT DISTINCT(eventid) FROM sys.fn_trace_geteventinfo(#{a}) WHERE eventid = 110;\" -ServerInstance '#{SERVER_INSTANCE}'") do
      its('stdout') { should_not eq '' }
    end
    describe command("Invoke-Sqlcmd -Query \"SELECT DISTINCT(eventid) FROM sys.fn_trace_geteventinfo(#{a}) WHERE eventid = 111;\" -ServerInstance '#{SERVER_INSTANCE}'") do
      its('stdout') { should_not eq '' }
    end
    describe command("Invoke-Sqlcmd -Query \"SELECT DISTINCT(eventid) FROM sys.fn_trace_geteventinfo(#{a}) WHERE eventid = 112;\" -ServerInstance '#{SERVER_INSTANCE}'") do
      its('stdout') { should_not eq '' }
    end
    describe command("Invoke-Sqlcmd -Query \"SELECT DISTINCT(eventid) FROM sys.fn_trace_geteventinfo(#{a}) WHERE eventid = 113;\" -ServerInstance '#{SERVER_INSTANCE}'") do
      its('stdout') { should_not eq '' }
    end
    describe command("Invoke-Sqlcmd -Query \"SELECT DISTINCT(eventid) FROM sys.fn_trace_geteventinfo(#{a}) WHERE eventid = 115;\" -ServerInstance '#{SERVER_INSTANCE}'") do
      its('stdout') { should_not eq '' }
    end
    describe command("Invoke-Sqlcmd -Query \"SELECT DISTINCT(eventid) FROM sys.fn_trace_geteventinfo(#{a}) WHERE eventid = 116;\" -ServerInstance '#{SERVER_INSTANCE}'") do
      its('stdout') { should_not eq '' }
    end
    describe command("Invoke-Sqlcmd -Query \"SELECT DISTINCT(eventid) FROM sys.fn_trace_geteventinfo(#{a}) WHERE eventid = 117;\" -ServerInstance '#{SERVER_INSTANCE}'") do
      its('stdout') { should_not eq '' }
    end
    describe command("Invoke-Sqlcmd -Query \"SELECT DISTINCT(eventid) FROM sys.fn_trace_geteventinfo(#{a}) WHERE eventid = 118;\" -ServerInstance '#{SERVER_INSTANCE}'") do
      its('stdout') { should_not eq '' }
    end
    describe command("Invoke-Sqlcmd -Query \"SELECT DISTINCT(eventid) FROM sys.fn_trace_geteventinfo(#{a}) WHERE eventid = 128;\" -ServerInstance '#{SERVER_INSTANCE}'") do
      its('stdout') { should_not eq '' }
    end
    describe command("Invoke-Sqlcmd -Query \"SELECT DISTINCT(eventid) FROM sys.fn_trace_geteventinfo(#{a}) WHERE eventid = 129;\" -ServerInstance '#{SERVER_INSTANCE}'") do
      its('stdout') { should_not eq '' }
    end
    describe command("Invoke-Sqlcmd -Query \"SELECT DISTINCT(eventid) FROM sys.fn_trace_geteventinfo(#{a}) WHERE eventid = 130;\" -ServerInstance '#{SERVER_INSTANCE}'") do
      its('stdout') { should_not eq '' }
    end
    describe command("Invoke-Sqlcmd -Query \"SELECT DISTINCT(eventid) FROM sys.fn_trace_geteventinfo(#{a}) WHERE eventid = 131;\" -ServerInstance '#{SERVER_INSTANCE}'") do
      its('stdout') { should_not eq '' }
    end
    describe command("Invoke-Sqlcmd -Query \"SELECT DISTINCT(eventid) FROM sys.fn_trace_geteventinfo(#{a}) WHERE eventid = 132;\" -ServerInstance '#{SERVER_INSTANCE}'") do
      its('stdout') { should_not eq '' }
    end
    describe command("Invoke-Sqlcmd -Query \"SELECT DISTINCT(eventid) FROM sys.fn_trace_geteventinfo(#{a}) WHERE eventid = 133;\" -ServerInstance '#{SERVER_INSTANCE}'") do
      its('stdout') { should_not eq '' }
    end
    describe command("Invoke-Sqlcmd -Query \"SELECT DISTINCT(eventid) FROM sys.fn_trace_geteventinfo(#{a}) WHERE eventid = 134;\" -ServerInstance '#{SERVER_INSTANCE}'") do
      its('stdout') { should_not eq '' }
    end
    describe command("Invoke-Sqlcmd -Query \"SELECT DISTINCT(eventid) FROM sys.fn_trace_geteventinfo(#{a}) WHERE eventid = 135;\" -ServerInstance '#{SERVER_INSTANCE}'") do
      its('stdout') { should_not eq '' }
    end
    describe command("Invoke-Sqlcmd -Query \"SELECT DISTINCT(eventid) FROM sys.fn_trace_geteventinfo(#{a}) WHERE eventid = 152;\" -ServerInstance '#{SERVER_INSTANCE}'") do
      its('stdout') { should_not eq '' }
    end
    describe command("Invoke-Sqlcmd -Query \"SELECT DISTINCT(eventid) FROM sys.fn_trace_geteventinfo(#{a}) WHERE eventid = 153;\" -ServerInstance '#{SERVER_INSTANCE}'") do
      its('stdout') { should_not eq '' }
    end
    describe command("Invoke-Sqlcmd -Query \"SELECT DISTINCT(eventid) FROM sys.fn_trace_geteventinfo(#{a}) WHERE eventid = 162;\" -ServerInstance '#{SERVER_INSTANCE}'") do
      its('stdout') { should_not eq '' }
    end
    describe command("Invoke-Sqlcmd -Query \"SELECT DISTINCT(eventid) FROM sys.fn_trace_geteventinfo(#{a}) WHERE eventid = 170;\" -ServerInstance '#{SERVER_INSTANCE}'") do
      its('stdout') { should_not eq '' }
    end
    describe command("Invoke-Sqlcmd -Query \"SELECT DISTINCT(eventid) FROM sys.fn_trace_geteventinfo(#{a}) WHERE eventid = 171;\" -ServerInstance '#{SERVER_INSTANCE}'") do
      its('stdout') { should_not eq '' }
    end
    describe command("Invoke-Sqlcmd -Query \"SELECT DISTINCT(eventid) FROM sys.fn_trace_geteventinfo(#{a}) WHERE eventid = 172;\" -ServerInstance '#{SERVER_INSTANCE}'") do
      its('stdout') { should_not eq '' }
    end
    describe command("Invoke-Sqlcmd -Query \"SELECT DISTINCT(eventid) FROM sys.fn_trace_geteventinfo(#{a}) WHERE eventid = 173;\" -ServerInstance '#{SERVER_INSTANCE}'") do
      its('stdout') { should_not eq '' }
    end
    describe command("Invoke-Sqlcmd -Query \"SELECT DISTINCT(eventid) FROM sys.fn_trace_geteventinfo(#{a}) WHERE eventid = 175;\" -ServerInstance '#{SERVER_INSTANCE}'") do
      its('stdout') { should_not eq '' }
    end
    describe command("Invoke-Sqlcmd -Query \"SELECT DISTINCT(eventid) FROM sys.fn_trace_geteventinfo(#{a}) WHERE eventid = 176;\" -ServerInstance '#{SERVER_INSTANCE}'") do
      its('stdout') { should_not eq '' }
    end
    describe command("Invoke-Sqlcmd -Query \"SELECT DISTINCT(eventid) FROM sys.fn_trace_geteventinfo(#{a}) WHERE eventid = 177;\" -ServerInstance '#{SERVER_INSTANCE}'") do
      its('stdout') { should_not eq '' }
    end
  end
  describe command("Invoke-Sqlcmd -Query \"SELECT * FROM sys.server_audit_specification_details WHERE server_specification_id = (SELECT server_specification_id FROM sys.server_audit_specifications WHERE [name] = 'spec1' AND audit_action_name NOT IN ('APPLICATION_ROLE_CHANGE_PASSWORD_GROUP', 'AUDIT_CHANGE_GROUP', 'BACKUP_RESTORE_GROUP', 'DATABASE_CHANGE_GROUP', 'DATABASE_OBJECT_ACCESS_GROUP',  ' DATABASE_OBJECT_CHANGE_GROUP','DATABASE_OBJECT_OWNERSHIP_CHANGE_GROUP', 'DATABASE_OBJECT_PERMISSION_CHANGE_GROUP', 'DATABASE_OPERATION_GROUP','DATABASE_OWNERSHIP_CHANGE_GROUP','DATABASE_PERMISSION_CHANGE_GROUP', 'DATABASE_PRINCIPAL_CHANGE_GROUP', 'DATABASE_PRINCIPAL_IMPERSONATION_GROUP', 'DATABASE_ROLE_MEMBER_CHANGE_GROUP', 'DBCC_GROUP', 'LOGIN_CHANGE_PASSWORD_GROUP', 'SCHEMA_OBJECT_CHANGE_GROUP', 'SCHEMA_OBJECT_OWNERSHIP_CHANGE_GROUP', 'SCHEMA_OBJECT_PERMISSION_CHANGE_GROUP', 'SERVER_OBJECT_CHANGE_GROUP', 'SERVER_OBJECT_OWNERSHIP_CHANGE_GROUP', 'SERVER_OBJECT_PERMISSION_CHANGE_GROUP', 'SERVER_OPERATION_GROUP', 'SERVER_PERMISSION_CHANGE_GROUP', 'SERVER_PRINCIPAL_IMPERSONATION_GROUP', 'SERVER_ROLE_MEMBER_CHANGE_GROUP', 'SERVER_STATE_CHANGE_GROUP', 'TRACE_CHANGE_GROUP') AND audited_result != 'SUCCESS AND FAILURE');\" -ServerInstance '#{SERVER_INSTANCE}'") do
   its('stdout') { should eq '' }
  end
end

