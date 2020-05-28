{{- define "reva.http.middlewares.cors" }}
  [http.middlewares.cors]
  allow_credentials = true
{{- end }}

{{- define "reva.http.services.ocdav" }}
  [http.services.ocdav]
  prefix = ""
  chunk_folder = "/var/tmp/reva/chunks"
  files_namespace = "/home"
  webdav_namespace = "/home"
{{- end }}

{{- define "reva.http.services.ocs" }}
  [http.services.ocs.capabilities.capabilities.files_sharing]
  api_enabled = true
  resharing = true
  group_sharing = true
  auto_accept_share = true
  share_with_group_members_only = true
  share_with_membership_groups_only = true
  default_permissions = 22
  search_min_length = 3
  
  [http.services.ocs.capabilities.capabilities.files_sharing.public]
  enabled = true
  send_mail = true
  social_share = true
  upload = true
  multiple = true
  supports_upload_only = true
  
  [http.services.ocs.capabilities.capabilities.files_sharing.public.password]
  enforced = true
  
  [http.services.ocs.capabilities.capabilities.files_sharing.public.password.enforced_for]
  read_only = true
  read_write = true
  upload_only = true
  
  [http.services.ocs.capabilities.capabilities.files_sharing.public.expire_date]
  enabled = true
  
  [http.services.ocs.capabilities.capabilities.files_sharing.user]
  send_mail = true
  
  [http.services.ocs.capabilities.capabilities.files_sharing.user_enumeration]
  enabled = true
  group_members_only = true
  
  [http.services.ocs.capabilities.capabilities.files_sharing.federation]
  outgoing = true
  incoming = true
{{- end }}

{{- define "reva.grpc.services.gateway" }}
  [grpc.services.gateway]
  authregistrysvc         = "reva-gateway:{{ .Values.components.gateway.ports.grpc }}"
  storageregistrysvc      = "reva-gateway:{{ .Values.components.gateway.ports.grpc }}"
  preferencessvc          = "reva-users:{{ .Values.components.users.ports.grpc }}"
  userprovidersvc         = "reva-users:{{ .Values.components.users.ports.grpc }}"
  usershareprovidersvc    = "reva-shares:{{ .Values.components.shares.ports.grpc }}"
  publicshareprovidersvc  = "reva-shares:{{ .Values.components.shares.ports.grpc }}"
  ocmshareprovidersvc     = "reva-shares:{{ .Values.components.shares.ports.grpc }}"
  commit_share_to_storage_grant = true
  commit_share_to_storage_ref = true
  share_folder = "Shared"
  datagateway = "http://reva-gateway:{{ .Values.components.gateway.ports.http }}/data"
  transfer_shared_secret = "{{ .Values.config.transferSecret }}" # for direct uploads
  transfer_expires = 6 # give it a moment
  #disable_home_creation_on_login = true
{{- end }}

{{- define "reva.grpc.services.authregistry" }}
  [grpc.services.authregistry]
  driver = "static"
  
  [grpc.services.authregistry.drivers.static.rules]
  basic = "reva-users:{{ .Values.components.users.ports.grpc }}"
  bearer = "reva-frontend:{{ .Values.components.frontend.ports.grpc }}"
{{- end }}

{{- define "reva.grpc.services.storageregistry" }}
  [grpc.services.storageregistry]
  driver = "static"
  
  [grpc.services.storageregistry.drivers.static]
  home_provider = "/home"
  
  [grpc.services.storageregistry.drivers.static.rules]
  "/home" = "reva-storagehome:{{ .Values.components.storageHome.ports.grpc }}"
  "/global" = "reva-storageglobal:{{ .Values.components.storageGlobal.ports.grpc }}"
{{- end }}

{{- define "reva.http.services.datagateway" }}
  [http.services.datagateway]
  transfer_shared_secret = "{{ .Values.config.transferSecret }}" # for direct uploads
{{- end }}

{{- define "reva.grpc.shareproviders" }}
  [grpc.services.usershareprovider]
  driver = "memory"
  
  #[grpc.services.usershareprovider.drivers.json]
  #file = "/json-db/reva-shares.json"
  
  [grpc.services.publicshareprovider]
  driver = "memory"
{{- end }}

{{- define "reva.storage.global.grpc.services.storageprovider" }}
  [grpc.services.storageprovider]
  driver = "eos"
  mount_path = "/global"
  mount_id = "123e4567-e89b-12d3-a456-426655440000"
  expose_data_server = true
  data_server_url = "http://reva-storageglobal:11001/data"
  
  [grpc.services.storageprovider.drivers.eos]
  eos_binary = "/bin/eos"
  xrdcopy_binary = "/bin/xrdcopy"
  namespace = "/eos/{{ .Release.Name }}"
  master_url = "root://{{ .Release.Name }}-mgm"
  enable_logging = true
  use_keytab = true
  keytab = "/etc/eos.keytab"
  sec_protocol = "sss,unix"
  share_folder = "Shared"
{{- end }}

{{- define "reva.storage.global.http.services.dataprovider" }}
  [http.services.dataprovider]
  driver = "eos"
  temp_folder = "/var/tmp/reva/tmp"
  
  [http.services.dataprovider.drivers.eos]
  eos_binary = "/bin/eos"
  xrdcopy_binary = "/bin/xrdcopy"
  namespace = "/eos/{{ .Release.Name }}"
  master_url = "root://{{ .Release.Name }}-mgm"
  enable_logging = true
  use_keytab = true
  keytab = "/etc/eos.keytab"
  sec_protocol = "sss,unix"
  share_folder = "Shared"
{{- end }}

{{- define "reva.storage.home.grpc.services.storageprovider" }}
  [grpc.services.storageprovider]
  driver = "eos"
  mount_path = "/home"
  mount_id = "123e4567-e89b-12d3-a456-426655440000"
  expose_data_server = true
  data_server_url = "http://reva-storagehome:{{ .Values.components.storageHome.ports.http }}/data"
  enable_home_creation = true
  
  [grpc.services.storageprovider.drivers.eos]
  eos_binary = "/bin/eos"
  xrdcopy_binary = "/bin/xrdcopy"
  namespace = "/eos/{{ .Release.Name }}"
  master_url = "root://{{ .Release.Name }}-mgm"
  enable_logging = true
  use_keytab = true
  keytab = "/etc/eos.keytab"
  sec_protocol = "sss,unix"
  enable_home = true
  user_layout = {{ "{{ .Email.Domain }}/{{ substr 0 1 .Username | lower }}/{{ .Username | lower }}" | quote }}
  share_folder = "Shared"
{{- end }}

{{- define "reva.storage.home.http.services.dataprovider" }}
  [http.services.dataprovider]
  driver = "eos"
  temp_folder = "/var/tmp/reva/tmp"
  
  [http.services.dataprovider.drivers.eos]
  eos_binary = "/bin/eos"
  xrdcopy_binary = "/bin/xrdcopy"
  namespace = "/eos/{{ .Release.Name }}"
  master_url = "root://{{ .Release.Name }}-mgm"
  enable_logging = true
  use_keytab = true
  keytab = "/etc/eos.keytab"
  sec_protocol = "sss,unix"
  enable_home = true
  user_layout = {{ "{{ .Email.Domain }}/{{ substr 0 1 .Username | lower }}/{{ .Username | lower }}" | quote }}
  share_folder = "Shared"
{{- end }}

{{- define "reva.grpc.services.authprovider.oidc" }}
  [grpc.services.authprovider]
  auth_manager = "oidc"

  [grpc.services.authprovider.auth_managers.oidc]
  issuer = "{{ .Values.global.oidc.authority }}"
  insecure = true
  skipcheck = true
{{- end }}

{{- define "reva.grpc.services.authprovider.ldap" }}
  [grpc.services.authprovider]
  auth_manager = "ldap"
  
  [grpc.services.authprovider.auth_managers.ldap]
  hostname = "reva-ldap"
  port = 636
  base_dn = "dc=cloudstor,dc=aarnet,dc=edu,dc=au"
  bind_username = "cn=admin,dc=cloudstor,dc=aarnet,dc=edu,dc=au"
  bind_password = "admin"
  idp = "https://cloudstor-uat.aarnet.edu.au"
  
  [grpc.services.authprovider.auth_managers.ldap.schema]
  uid = "uid"
{{- end }}

{{- define "reva.grpc.services.userprovider" }}
  [grpc.services.userprovider]
  driver = "ldap"
  
  [grpc.services.userprovider.drivers.ldap]
  hostname = "reva-ldap"
  port = 636
  base_dn = "dc=cloudstor,dc=aarnet,dc=edu,dc=au"
  bind_username = "cn=admin,dc=cloudstor,dc=aarnet,dc=edu,dc=au"
  bind_password = "admin"
  idp = "https://cloudstor-uat.aarnet.edu.au"
  
  [grpc.services.userprovider.drivers.ldap.schema]
  uid = "uid"
{{- end }}
