systemTools.setEnvVariable "ADSK_3DSMAX_CUI_PRE_USER_CONFIG_2026" ("C:\\Users\\" + sysInfo.username + "\\Autodesk\\3ds Max 2026\\User Settings\\MaxStack.mnx")
(maxops.GetICuiMenuMgr()).LoadConfiguration((maxops.GetICuiMenuMgr()).GetCurrentConfiguration())

print "MaxStack menu loaded..."