public class RCCTV2_ROL_Util 
{
    //[15/01/14 OLE UST-01048 WIT-002037 RCCTv2]
    // W2.0 Util class for RCCT pick list generation 
    // listRCCTRegions()            List regions (first level of RCCT)
    // list RCCTChildren()          List children for one level (in RCCT format i.e. the final Cluster, Country, Territory is removed)
    // enforceNonApplicable()       Check that an RCCT is consistent in terms of N/A value for last non null level and 
    //                              update if needed to keep consitent 
    // dumpRoleHierToCSV()          Extract hierarchy (one line per node) and attach to a doc in my document. 
    //                              This is helper when working on Role hierarchy reorg once or twice a year
    // private getRoleChildren()    private recursive function called by dumpRoleHierToCSV() to traverse hierarchy



    //----------------------------------------------------------
    // listRCCTRegions()
    // Return list of regions defined in custom settings SMB_Setting_Region__c
    // Attribute are id and name of corresponding role node in hierarchy as well as "HasSuffix" to specifiy 
    // if region is complying with the suffix naming convention (' Cluster', 'Country', 'Territory')
    // We need to have this defined in a setting since regions don't all start
    // at same level in the role hierarchy
    // Note: the custom settings must contains all role nodes defined as region and one 'N/A' node.
    public static list<SMB_Setting_Region__c> listRCCTRegions()
    {
        List<SMB_Setting_Region__c> listSMBRegion = SMB_Setting_Region__c.getall().values();
        listSMBRegion.sort();
        return(listSMBRegion);
    }
    
    //----------------------------------------------------------
    // listRCCTChildren (...)
    // Return list of children roles for on role, optionally filtering out roles whose name match an exclusion criteria.
    // Can be used for building a dependent dynamic picklist 
    public static list<UserRole> listRCCTChildren(
         // list<UserRole>  listUserRole 
         string     sParentRoleName
        ,string     sExclude    //comma separated list of strings. role with name containing any of the strings are excluded
    )
    {
        list<UserRole> listParentUserRole = new list<UserRole>([select id, name from UserRole where name = :sParentRoleName]);
        // if parent does not exist no need to look for children, return empty immediately
        if (listParentUserRole.isEmpty()) 
        {            
            return ( null );
        } 
        else 
        {
            //list to store children
            list<UserRole> listChildrenRole = new list<UserRole>();
            //loop on chidren
            for (UserRole  thisUserRole : [select id, name from UserRole where parentRoleId = :listParentUserRole[0].id]) 
            {
                boolean bToDisplay = true;
                //Identify lines to filter out
                if (sExclude != null) 
                {
                    if (sExclude.length () > 0) 
                    {
                        for ( string sToExclude : sExclude.split('\\,',0) ) 
                        {
                            if (thisUserRole.name.contains(sToExclude) )
                            {
                                bToDisplay = false;
                            }
                        }
                    }
                }
                //dump what is not excluded
                if (bToDisplay) 
                {
                    listChildrenRole.add(thisUserRole);
                }
                
            }
            listChildrenRole.sort();
            return (listChildrenRole);
        }
        
    }
    
    //-----------------------------------------------------------------------------
    //enforceNonApplicable(oRCCT) make basic checks on RCCT fields before saving. 
    //----------------------------------------------------------------------------
    //make sure last filled level is N/A, then null below and there is --none-- value left over
    // return '' string if ok, error message else
    //public static string enforceNonApplicable(string region, string cluster, string country, string territory) {
    public static string enforceNonApplicable(RCCTV2_Tuple oRCCT) {
        
        string sReturn = '';
        string region       = oRCCT.region;
        string cluster      = oRCCT.cluster;
        string country      = oRCCT.country;
        string territory    = oRCCT.territory;
        try {
            //this block to ensure consistent entries
            if (region == null)             {region = 'N/A'; cluster = null; country = null;  territory = null;}
            else {
                if (region == '--none--')   {region = 'N/A'; cluster = null;  country = null;  territory = null;}
                if (region == 'N/A')        {                cluster = null;  country = null;   territory = null;}
            }
            
            if (cluster == null)            {                                 country = null;   territory = null;}
            else {
                if (cluster == '--none--')  {                cluster = 'N/A'; country = null;   territory = null;}
                if (cluster == 'N/A')       {                                 country = null;   territory = null;}
            }
            
            if (country == null)            {                                                   territory = null;}
            else {
                if (country == '--none--')  {                                 country = 'N/A';  territory = null;}
                if (country == 'N/A')       {                                                   territory = null;}
            }
            
            if (territory == null)          {                                                   territory = null;}
            else {
                if (territory == '--none--'){                                                   territory = 'N/A';}
                if (country == 'N/A')       {                                                   territory = 'N/A';}
            }

            oRCCT.region    = region;
            oRCCT.cluster   = cluster;
            oRCCT.country   = country;
            oRCCT.territory = territory;
            
        } 
        catch (Exception e) {
            sReturn = 'error 01 in RCCTV2_ROL_Util.enforceNonApplicable(): ' + e;
            return sReturn;
        } 
        return sReturn;
    }

    /*------------------------------------------------------------------------------
     dumpRoleHierToCSV(...)
    call example:
    RCCTV2_ROL_Util.dumpRoleHierToCSV(
        new set<string>{'APAC,EMI'}     //setParentname
        , ':'                           // sep
        , false                         // escapeQuoteCSV
        , 'Presale,Support'             // exclude csv list
        ,99                             // maxDepth
            );
    */
    public static void dumpRoleHierToCSV(
         //set<id>      setStartNodeId      //null ==> dump all hierarchy, if not start from StartNode id(s). for example use to dump a Region: 00EE0000000d69p for APAC
         set<string>    setStartNodeName    //null ==> dump all hierarchy, if not start from StartNode name(s). for example use to dump a Region: APAC
        ,string         sSep                //Since some role may contain comma, use an alternative separator character, if null or ''  defaults to ','. Alternatively use bEscapeCSV
        ,boolean        bEscapeCSV          //Enclose all role names with double quote
        ,string         sExclude            //comma separated list of strings. Lines containing any of the strings are excluded from dump.
                                            // e.g.: 'presale,account,support'
        ,integer        iMaxDepth           //Max number of level to explore
    ) 
    {

        integer iDepth = 0; // to measure recursive level reached
        string  sCSVQuote = (bEscapeCSV? '"' : '');

        // instantiate map that will contain hierarchy to build, and initiate with setStartNode nodes if any given as input
        set<id>         setStartNodeId = new set<Id>{null}; 
        string 			sRootName	   = sCSVQuote + 'Root' + sCSVQuote;
        map<id, string> mapHierarchyDump = new map <id, string> {null => sRootName}; //format is lead node id of current line and current path. e.g.: <Z.id, 'X:Y:Z'> 
        
        if (  (setStartNodeName != null))
        {
            if (( setStartNodeName.size() > 0 )) 
            {
                // not starting from root, reset default map and set....
                mapHierarchyDump.clear();
                setStartNodeId.clear();
                
                //... and build from input parameter setStartNodeName
                for ( UserRole UserRoleToExplore: [select id,name from UserRole where name in :setStartNodeName])
                {
                    UserRoleToExplore.name = sCSVQuote + UserRoleToExplore.name + sCSVQuote; //UserRoleToExplore.name.escapeCsv();}
                    mapHierarchyDump.put(UserRoleToExplore.id, UserRoleToExplore.name);
                    setStartNodeId.add(UserRoleToExplore.id);
                }

            }
        }
                    
        // get separator
        if (sSep == null) {sSep = ',';}
        if (sSep ==''   ) {sSep = ',';}
        

        
        // Get all UserRoles (roleid, rolename, parentid) in a set we'll use as a heap to build the hiearchy map
        //system.debug('%%%%%%%%%%%%%%%%%%% DUMP ALL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
        set<UserRole> setUserRoleHeap = new set<userRole>([select id, name, parentRoleId from UserRole LIMIT 99999]);
 
        //system.debug('%%%%%%%%%%%%%%%%%%% DUMP ALL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%>');

        
        // Dump hierarchy into mapHierarchyDump
        iDepth = getRoleChildren (
             0                  // always 0
            ,setStartNodeId     // starting node id (null is root)
            ,setUserRoleHeap    // heap containing all unsorted role id, parent id pairs
            ,mapHierarchyDump   // map where we'll build the hierarchy by going throuhg the heap
            ,sSep
            ,sCSVQuote          // escapeCSV when necessary
            ,iMaxDepth -1       //offset one to remove root level 
        );      

        // copy to list, sort
        list<string> listHierarchyDump = mapHierarchyDump.values();
        listHierarchyDump.sort();
        
        //check if there are any exclusion
        boolean bHasExclusion = false;
        if (sExclude != null) 
        {
            if (sExclude.length () > 0) 
            {
                bHasExclusion = true;
            }
        }

        //prepare csv header line
        string sStringCSV = 'L0'; 
        //for (integer ii=0; ii <= iMaxDepth; ii++ )
        for (integer ii=1; ii <= iDepth; ii++ )
        {
            sStringCSV +=  sSep + sCSVQuote + 'L' + ii + sCSVQuote; 
        }
        sStringCSV +=    '\n';
        //system.debug('<-----> FIRST CSV LINE: ' + sStringCSV);
        
        //loop on each line and if not excluded add line to CSV buffer
        for(string sSortedNodePath : listHierarchyDump) 
        {
            boolean bToDisplay = true;
            //Identify lines to filter out
            if (sExclude != null) 
            {
                if (sExclude.length () > 0) 
                {
                    for ( string sToExclude : sExclude.split('\\,',0) ) 
                    {
                        if (sSortedNodePath.contains(sToExclude) )
                        {
                            bToDisplay = false;
                        }
                    }
                }
            }
            //dump what is not excluded
            if (bToDisplay) 
            {
                sStringCSV +=  sSortedNodePath + '\n';
                //system.debug('====> hasX Current sSortedNodePath: ' + sSortedNodePath);                             
            }
        }    
        
        //system.debug('======> EXTRACT DONE <=====');
        
        //dump CSV buffer to a file somewhere
        string sFileName = 'RoleHier';
        
        if (  (setStartNodeName != null))
        {
            if (( setStartNodeName.size() > 0 )) 
            {
                for (string s : setStartNodeName) 
                {
                    sFileName += '-' + s;
                }
                
            }
        }
        Document d = new Document(); 
        d.Name = sFileName.replace(' ', '-') + '-' + datetime.now().formatGMT('yyyy-MM-dd\'-\'HH:mm'); 
        d.Body = Blob.valueOf(sStringCSV); 
        d.ContentType = 'text/plain';
        d.Type = 'csv';
        d.FolderId = UserInfo.getUserId();
        insert d;
        
        
        //system.debug('======> DOC CREATION DONE <=====');
    } 
    
    
    // ---------------------------------------------------------------------
    //     private static void getRoleChildren (...)
    // ---------------------------------------------------------------------
    // Build recursively hiearchy map of role hierarchy (each entry has current leaf as id and current path as value)
    // For one level use list of level ids in setParentRoleId to retrieve all children, the for each child node
    // find the map entry with child node parentId as key and create a new map entry with child node id as new
    // leaf, i.e.: id = child node id and value = parent map value appended with ':' + new leaf name
    // E.g.:
    //  Root--|--L1-----M1
    //        |--L2--|--M2
    //               |--M3
    // 
    //  setParentRoleId = {L1.id, L2.id}
    //  current map: (rootId, 'rootName')     (i.e.: rootname parent is null and current leaf is )
    //               (L1.id, 'Root:L1')
    //               (L2.id, 'Root:L2')
    // 
    //  children for (L1,L2) will be (M1,M2,M2)
    //  Parent map entry value for M1 will be map.get(M1.ParentId) = map.get(L1.id) = Root:L1
    //  so we create a new map entry with key M1.id and value Root:L1:M1
    //  at end of function call the current map will now be
    //  current map: (rootId, 'rootName')     (i.e.: rootname parent is null and current leaf is )
    //               (L1.id, 'Root:L1')
    //               (L2.id, 'Root:L2')
    //               (M1.id, 'Root:L1:M1')
    //               (M2.id, 'Root:L2:M2')
    //               (M3.id, 'Root:L2:M3')
    //               
    // Then we call function recursively until there is no more children after which we return;
    private static integer getRoleChildren ( 
         integer        iDepth                      //set to 0. Recursive depth call, used by method when callint itself
        ,set<id>        setParentRoleId             //set of role ids for which to seach children. All ids should be at same level in hierarchy
        ,set<UserRole>  setUserRoleHeap             // collection of user roles (id, parent id) used as input. Elements are removed once they are copid to the Hierarchy map 
        ,map<id, string> mapCurrentHierarchyDump    //current hierarchy map. Will be appended with new found nodes. Format for each line 
                                                    // is lead node id of current line and current path. e.g.: <Z.id, 'X:Y:Z'> 
        ,string         sSep
        ,string         sCSVQuote                   // Enclose role name between quote (if a role name contains a comma, newline or double quote)
        ,integer        iMaxDepth
    )
    {        
        set<id> setChildrenRoleId = new set<id>();
        
        //Loop on role heap 

        /************** DO NOT DELETE **************************************
        //Alternative code, bulkified, using map and set instead of one SOQL at each level
        // seems to be a bug with setUserRoleHeap.remove() method so using SOQL alternatice (no impact on perf)
		for ( UserRole oneUserRole : setUserRoleHeap) 
        {
            //check if current role if child of a key of map mapCurrentHierarchyDump (i.e.: a path ending with  this role id) 
            string  currentParentPath = mapCurrentHierarchyDump.get(oneUserRole.ParentRoleId) ;
            if (currentParentPath!= null ) 
            {
                // if role is a child then add it to setChildrenRoleId (which will use as candidate parent set for next level call)
                setChildrenRoleId.add(oneUserRole.id);
                
                // Let's add the role as a new entry in the hierarchy map <id, path-rolename>
                id  newNodeId       = oneUserRole.id;
                oneUserRole.name    = sCSVQuote + oneUserRole.name + sCSVQuote; //oneUserRole.name.escapeCsv();}

                if (currentParentPath == null)
                {
                    currentParentPath = ''; // root node has currentParentPath = '' other nodes have a non null parent path
                }
                string newPathNode = currentParentPath + sSep + oneUserRole.name;
                mapCurrentHierarchyDump.put(newNodeId, newPathNode);
                
                //remove current role from heap
                setUserRoleHeap.remove(oneUserRole);
            }
        }
        ************** DO NOT DELETE ***************************************/
        
        //Alternative code with SOQL rather than bulkified map access (perf is comparable because adding 300 members to set and map is long)
        for (UserRole oneUserRole : [select id,name,parentRoleId from UserRole 
                             where  parentRoleId in :setParentRoleId]) 
        {
            setChildrenRoleId.add(oneUserRole.id);
            id      newNodeId           = oneUserRole.id;
            string  currentParentPath   = '';
            
            if ( mapCurrentHierarchyDump.size() > 0 ) // root node has currentParentPath = '' other nodes have parent path
            {
                currentParentPath = mapCurrentHierarchyDump.get(oneUserRole.parentRoleId);
            }
            
            oneUserRole.name = sCSVQuote + oneUserRole.name + sCSVQuote; //oneUserRole.name.escapeCsv();}
            string newPathNode = currentParentPath + sSep + oneUserRole.name;
            mapCurrentHierarchyDump.put(newNodeId, newPathNode);
        }

        
        //system.debug('----->  getRoleChildren iDepth: ' + iDepth  + ' setChildrenRoleId.size(): ' + setChildrenRoleId.size() + ' setUserRoleHeap.size(): ' + setUserRoleHeap.size());
        if ((setChildrenRoleId.size() > 0) && (iDepth < iMaxDepth))
            {
                iDepth++;
                iDepth = getRoleChildren(iDepth, setChildrenRoleId, setUserRoleHeap, mapCurrentHierarchyDump, sSep, sCSVQuote, iMaxDepth);
            }
        //system.debug('-----> End of getRoleChildren iDepth: ' + iDepth );
        return iDepth;
    } 
}