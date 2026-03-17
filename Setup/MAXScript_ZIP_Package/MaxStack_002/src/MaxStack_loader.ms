systemTools.setEnvVariable "ADSK_3DSMAX_CUI_PRE_USER_CONFIG_2026" @"C:\Users\Antoine Allaz\Autodesk\3ds Max 2026\User Settings\MaxStack.mnx"
(maxops.GetICuiMenuMgr()).LoadConfiguration((maxops.GetICuiMenuMgr()).GetCurrentConfiguration())
	
-- maxMenuMgr = maxops.GetICuiMenuMgr()
-- curConfig = maxMenuMgr.GetCurrentConfiguration() -- renvoie le path de la config active
-- 	maxMenuMgr.LoadConfiguration (maxMenuMgr.GetCurrentConfiguration())