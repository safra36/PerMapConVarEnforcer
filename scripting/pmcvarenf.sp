

#include <cvarenf>
#include <sourcemod>

public Plugin:myinfo = 
{
	name        = "Per Map ConVar Enforcer",
	author      = "noBrain",
	description = "This plugin will enforce convars based on map",
	version     = "0.0.0"
};



ArrayList g_aMapConVarsList;
char g_szConfigPathDir[PLATFORM_MAX_PATH];



public void OnPluginStart()
{
    g_aMapConVarsList = new ArrayList(128);

    BuildPath(Path_SM, g_szConfigPathDir, sizeof(g_szConfigPathDir), "configs/mapcvarenf");
}




public void OnMapStart()
{
    char g_szMapName[64];
    GetCurrentMap(g_szMapName, sizeof(g_szMapName));

    if(ReadMapConfigFile(g_szMapName))
    {
        PrintToServer("Config File Has Been Read, Adding Commands To Enforcer ...");
        if(GetArraySize(g_aMapConVarsList) > 0)
        {
            for(int i=0;i<GetArraySize(g_aMapConVarsList);i++)
            {
                char g_szFullArrayString[2][64], g_szItemArray[128];
                GetArrayString(g_aMapConVarsList, i, g_szItemArray, sizeof(g_szItemArray));
                ExplodeString(g_szItemArray, " ", g_szFullArrayString, sizeof(g_szFullArrayString), sizeof(g_szFullArrayString[]));
                Cvar_Enforce(g_szFullArrayString[0], g_szFullArrayString[1]);
                PrintToServer("[SM] ConVar %s was enforced for value of %s", g_szFullArrayString[0], g_szFullArrayString[1])
            }
        }
    }
    else
    {
        PrintToServer("Map Config was not found");
    }
}


public void OnMapEnd()
{
    if(GetArraySize(g_aMapConVarsList) > 0)
    {
        for(int i=0;i<GetArraySize(g_aMapConVarsList);i++)
        {
            char g_szFullArrayString[2][64], g_szItemArray[128];
            GetArrayString(g_aMapConVarsList, i, g_szItemArray, sizeof(g_szItemArray));
            ExplodeString(g_szItemArray, " ", g_szFullArrayString, sizeof(g_szFullArrayString), sizeof(g_szFullArrayString[]));

            if(Cvar_IsEnforced(g_szFullArrayString[0]))
            {
                if(Cvar_Unenforce(g_szFullArrayString[0]))
                {
                    PrintToServer("[SM] ConVar %s was unenforced!", g_szFullArrayString[0])
                }
                else
                {
                    PrintToServer("[SM] Could not unenforce command %s !", g_szFullArrayString[0])
                }
            }
            else
            {
                PrintToServer("[SM] ConVar %s was not enforced to unenforce!", g_szFullArrayString[0])
            }

        }
    }
    
}




stock bool ReadMapConfigFile(char[] mapName)
{
    g_aMapConVarsList.Clear();

    char g_szMapConfigFile[PLATFORM_MAX_PATH], g_szFileLine[256];
    Format(g_szMapConfigFile, sizeof(g_szMapConfigFile), "%s/%s.cfg", g_szConfigPathDir, mapName);

    Handle g_hFileReader = OpenFile(g_szMapConfigFile, "r");

    if(g_hFileReader != null)
    {
        while(!IsEndOfFile(g_hFileReader) && ReadFileLine(g_hFileReader, g_szFileLine, sizeof(g_szFileLine)))
        {
            PushArrayString(g_aMapConVarsList, g_szFileLine);
        }

        CloseHandle(g_hFileReader);
        return true;
    }
    else
    {
        CloseHandle(g_hFileReader);
        return false;
    }

}





