APPROVED_USERS_SQL_AUDITS = attribute('approved_users_sql_audits')

control 'V-67797' do
  title "SQL Server Profiler must be protected  from unauthorized access,
  modification, or removal."
  desc  "Protecting audit data also includes identifying and protecting the
  tools used to view and manipulate log data.  SQL Server Profiler is one such
  tool.

    If an attacker were to gain access to audit tools, he could analyze audit
  logs for system weaknesses or weaknesses in the auditing itself. An attacker
  could also manipulate logs to hide evidence of malicious activity.
  "
  impact 0.7
  tag "gtitle": 'SRG-APP-000121-DB-000202'
  tag "gid": 'V-67797'
  tag "rid": 'SV-82287r2_rule'
  tag "stig_id": 'SQL4-00-013910'
  tag "fix_id": 'F-73913r2_fix'
  tag "cci": ['CCI-001493']
  tag "nist": ['AU-9', 'Rev_4']
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
  tag "check": "Check the server documentation for a list of approved users
  with access to SQL Server Audits.

  To create, alter, or drop a server audit, principals require the ALTER ANY
  SERVER AUDIT or the CONTROL SERVER permission.  To view an Audit log requires
  the CONTROL SERVER permission.  To use Profiler, ALTER TRACE is required.

  Review the SQL Server permissions granted to principals. Look for permissions
  ALTER ANY SERVER AUDIT, ALTER ANY DATABASE AUDIT, CONTROL SERVER, ALTER TRACE:

  SELECT login.name, perm.permission_name, perm.state_desc
  FROM sys.server_permissions perm
  JOIN sys.server_principals login
  ON perm.grantee_principal_id = login.principal_id
  WHERE permission_name in ('CONTROL SERVER', 'ALTER ANY DATABASE AUDIT', 'ALTER
  ANY SERVER AUDIT','ALTER TRACE')
  and login.name not like '##MS_%';

  If unauthorized accounts have these privileges, this is a finding. "
  tag "fix": "Remove audit-related permissions from individuals and roles not
  authorized to have them.

  USE master;
  DENY [ALTER ANY SERVER AUDIT] TO [User];
  GO"

  sql = mssql_session(user: attribute('user'),
                      password: attribute('password'),
                      host: attribute('host'),
                      instance: attribute('instance'),
                      port: attribute('port'))
  permissions = sql.query("SELECT login.name as 'result' FROM sys.server_permissions perm JOIN sys.server_principals login ON perm.grantee_principal_id = login.principal_id WHERE permission_name in ('CONTROL SERVER', 'ALTER ANY DATABASE AUDIT', 'ALTER ANY SERVER AUDIT','ALTER TRACE') and login.name not like '##MS_%';").column('result')

  if  permissions.empty?
    impact 0.0
    desc 'There are no sql audit permissions alter any server audit granted control not applicable'

    describe 'There are no sql audit permissions alter any server audit granted, control not applicable' do
      skip 'There are no sql audit permissions  alter any server audit granted, control not applicable'
    end
  else
    permissions.each do |grantee|
      a = grantee.strip
      describe "sql audit permissions alter any server audit: #{a}" do
        subject { a }
        it { should be_in APPROVED_USERS_SQL_AUDITS }
      end
    end
  end
end
