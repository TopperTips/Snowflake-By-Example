

VPC - Virtual Private Cloud (Virtual Private Snowflake VPS)

Physical Security
	24hr arm guards in data center
	video survilience data center
	no access to any unauthorized personality to data center
	not Snoflake personal nor Snowflake customer have access to these data centers

Data Redundancy
	Provided by cloud provider

Network Access 
	Network Policy helps to control the SF access
	IP Whitelisting - policy can be created to allow or disallow IPs
	private link - private tunnel between customer and cloud provider (ESD or VPS customer)

Account Access & Authentication
	MFA - Multi Factor Authentication can be implemented to increase Security
	MFA is provided by duo Security sevices
	Once MFA is installed, Duo app to be installed by user
	Each user must enable MFA by themself. 
	All user with account admin role should have MFA enabled.
	SSO (SAML 2.0) allows user to access via federated services (IDP Identity provider)
	As long as IPD session is active, they can access SF
	SSO/IDP is available enterprise edition & +

Object Security
	All the objects (warehouse/db/schema/table etc) can be controlled by DAC/RBAC
	DAC- Discretionary Access control
	RBAC - Role Based Access control
	SF implements hybrid model of DAC & RBAC
	DAC handle the ownership, each object has an owner and owner has full access to the object.
	RBAC - Handle all other access except ownership like object priviledge and role access
	Object priviledge assign to role which are intern assign to users.

Data Security
	All data is encrypted uses AES-256 strong Encryption
	All files stored in stage area is automatically Encryption using AES-128 or AES-256 
	Special edition of SF allows periodic re-key and customer manage encryption.
	Hi

Connectivty Security
	All communication over internet is via HTTPS.
	All communication is secure and encrypted via TLS 1.2 or higher

Compliance Security
	Third Party 
	HIPPA
	PCI (Payment Card for Industry for data security)
	NIST 800-53
	SOC
	SOC-2 type II 
	SIG Lite (SIG Assessment) (Standardized Information Gathering - SIG Questionnaire Tools allow organizations to build, customize, analyze and store vendor questionnaires)

Application Activity Log 
	History tab provide all historical commands
	All details including session id etc can be viewed.
	Each query has query id which helps for trouble shooting (no access to data to even SF users)

User Access Audit Log
	Login_History family of table function can be use to query login attempts

Query History
	Query History is available for 7 days, it can be stored in SF table or external system.



Infrastructure Monitoring
	SF users Threat Stack & Sumo Logic to monitor production Infrastructure
	Lacework for behavioural Monitoring (use activity/network traffic/binaries)
	All alerts are viewed by SF security team.

Penetration Testing
	SF performs 7-10 penetration testing per year
	Application Penetration Test
	Network Penetration Test
	Funtional Penetration Test
	All logs and findings are tracked to closure
	Test results are available with customer under NDA



