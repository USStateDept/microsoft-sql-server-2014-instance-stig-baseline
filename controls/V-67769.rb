SERVER_INSTANCE= attribute(
  'server_instance',
  description: 'SQL server instance we are connecting to',
  default: "WIN-FC4ANINFUFP"
)

control "V-67769" do
  title "Where SQL Server Audit is in use, SQL Server must generate audit
  records when privileges/permissions are retrieved."
  desc  "The system must monitor who/what is reading privilege/permission/role
  information.

    This requirement addresses explicit requests for privilege/permission/role
  membership information. It does not refer to the implicit retrieval of
  privileges/permissions/role memberships that SQL Server continually performs to
  determine if any and every action on the database is permitted.

    Use of SQL Server Audit is recommended.  All features of SQL Server Audit
  are available in the Enterprise and Developer editions of SQL Server 2014.  It
  is not available at the database level in other editions.  For this or legacy
  reasons, the instance may be using SQL Server Trace for auditing, which remains
  an acceptable solution for the time being.  Note, however, that Microsoft
  intends to remove most aspects of Trace at some point after SQL Server 2016.

    This requirement applies to SQL Server Audit-based audit trails; Trace does
  not have this capability.
  "
  impact 0.7
  tag "gtitle": "SRG-APP-000091-DB-000066"
  tag "gid": "V-67769"
  tag "rid": "SV-82259r2_rule"
  tag "stig_id": "SQL4-00-011410"
  tag "fix_id": "F-73883r1_fix"
  tag "cci": ["CCI-000172"]
  tag "nist": ["AU-12 c", "Rev_4"]
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
  tag "check": "If SQL Server Trace is in use for audit purposes, and SQL
  Server Audit is not in use, this is not a finding.

  The basic SQL Server Audit configuration provided in the supplemental file
  Audit.sql uses the broad, server-level audit action group
  SCHEMA_OBJECT_ACCESS_GROUP for this purpose.  SQL Server Audit's flexibility
  makes other techniques possible.  If an alternative technique is in use and
  demonstrated effective, this is not a finding.

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

  Run the following to verify that all SELECT actions on the permissions-related
  system views, and any locally-defined permissions tables, are being audited:

  USE [master];
  GO
  SELECT * FROM sys.server_audit_specification_details WHERE
  server_specification_id =
  (SELECT server_specification_id FROM sys.server_audit_specifications WHERE
  [name] = '<server_audit_specification_name>')
  AND audit_action_name = 'SCHEMA_OBJECT_ACCESS_GROUP';

  If no row is returned, this is a finding.

  If the audited_result column is not \"SUCCESS\" or \"SUCCESS AND FAILURE\",
  this is a finding."
  tag "fix": "Design and deploy a SQL Server Audit that captures all auditable
  events.  The script provided in the supplemental file Audit.sql can be used for
  this.

  Alternatively, to add the necessary data capture to an existing server audit
  specification, run the script:
  USE [master];
  GO
  ALTER SERVER AUDIT SPECIFICATION <server_audit_specification_name> WITH (STATE
  = OFF);
  GO
  ALTER SERVER AUDIT SPECIFICATION <server_audit_specification_name> ADD
  (SCHEMA_OBJECT_ACCESS_GROUP);
  GO
  ALTER SERVER AUDIT SPECIFICATION <server_audit_specification_name> WITH (STATE
  = ON);
  GO"
  describe command("Invoke-Sqlcmd -Query \"SELECT * FROM sys.server_audit_specification_details WHERE server_specification_id = (SELECT server_specification_id FROM sys.server_audit_specifications WHERE [name] = 'spec1') AND audit_action_name = 'SCHEMA_OBJECT_ACCESS_GROUP';\" -ServerInstance '#{SERVER_INSTANCE}'") do
   its('stdout') { should_not eq '' }
  end
  describe command("Invoke-Sqlcmd -Query \"SELECT * FROM sys.server_audit_specification_details WHERE server_specification_id = (SELECT server_specification_id FROM sys.server_audit_specifications WHERE [name] = 'spec1') AND audit_action_name = 'SCHEMA_OBJECT_ACCESS_GROUP' AND audited_result != 'SUCCESS' AND audited_result != 'SUCCESS AND FAILURE';\" -ServerInstance '#{SERVER_INSTANCE}'") do
   its('stdout') { should eq '' }
  end
  
end

