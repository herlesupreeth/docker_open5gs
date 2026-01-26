divert(-1)

define(`ACL_ENABLED',`E')
define(`ACL_FORCE_NAT',`N')
define(`ACL_DND',`D')
define(`ACL_ALLOW_PSTN',`P')
define(`ACL_VM_ENABLED',`4')
define(`ACL_VM_ALWAYS',`5')
define(`ACL_VM_NOT_FOUND',`6')
define(`ACL_VM_BUSY',`7')
define(`ACL_VM_NO_ANSWER',`8')

define(`is_acl_set', `($(avp($1){s.index,$2}) != NULL)')

divert
