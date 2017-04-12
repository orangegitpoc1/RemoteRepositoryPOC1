public class RCCTV2_ROL_LoadFromCSVDoc {

    public class RCCTV2RoleLoadException extends Exception {}
    
    
    //----------------------------------- doLoad() --------------------------------------
    //Input is a CSV file with each column representing a level of a role hierarchy branch
    // The header line MUST contain one cell by level (contains typically L0, L1, L2, L3, ....)
    // The first level (first Column) MUST correspond to an existing User Role under which the
    // branch will be loaded. The example below assumes that 'TopRole' exists and X1, X2 and X3
    // will be created under TopRole. TopRole can be anywhere in the existing role hierarchy
    // if TopRole is not found nothing is loaded
    //  L0      L1      L2      L3      L4
    //  TopRole X1      
    //  TopRole X1      X1Y1
    //  TopRole X1      X1Y1    X1Y1Z1
    //  TopRole X2      X2Y1    X2Y1Z1
    //  TopRole X3 etc.....
    //  
    //  AccessForAccountOwner define the role level defautl permission on accounts owner by
    //  a role member
    public static string doLoad(
   		 string sDocName
        ,string sContactAccessForAccountOwner		//null, read or edit (careful though, possible values depend on OWD)
		,string sOpportunityAccessForAccountOwner	//null, read or edit
		,string sCaseAccessForAccountOwner			//null, read or edit
   ) 
     {
        
        string sRetCode = 'DidNothing';
        Savepoint sp = Database.setSavepoint(); //All or nothing, rollback on exception
        try {
            
            //Retrieve doc containing the hierarchy to load
            list<Document> listDoc = [select id, body from Document where name = :sDocName limit 2];
            //some sanity checks on returned doc
            if ( listDoc == null)     throw new RCCTV2RoleLoadException ( 'RCCTV2_ROL_LoadFromCSVDoc.doLoad(): doc ' + sDocName + ' not found, null list');
            if ( listDoc.size() == 0) throw new RCCTV2RoleLoadException ( 'RCCTV2_ROL_LoadFromCSVDoc.doLoad(): doc ' + sDocName + ' not found, empty list');
            if ( listDoc.size() > 1)  throw new RCCTV2RoleLoadException ( 'RCCTV2_ROL_LoadFromCSVDoc.doLoad(): found 2 docs matching name ' + sDocName);

            //Let's load content into a string and parse it into a table of cell
            list<list<string>> listListCSV = TEK_UTL_CSV.parseCSV(listDoc[0].body.toString(), false); //true ==> Skip header
            integer iNbRow = listListCSV.size();
            integer iNbCol	= listListCSV[0].size();
			system.debug('=============> Load Role From CSV iNbRow  iNbCol ' + iNbRow + ' ' + iNbCol);

            //The role found in cell (row 1,col 0) must correspond to an existing role under which (row 1 to skip header)
            // the branch will be loaded
            list<UserRole> listRootUserRole = new list<UserRole>();
            string sRootRoleName = listListCSV[1][0];
            system.debug('=============> Load Role From CSV starting from  sRootRoleName (0,0): ' +  sRootRoleName);
            
            listRootUserRole = [select id, name, parentRoleId, DeveloperName, RollupDescription 
                            from userRole
                            where name = :sRootRoleName
                            LIMIT 2
                           ];
            
            //some sanity checks on returned op user role (exist and is found only once)
            if ( listRootUserRole == null)     throw new RCCTV2RoleLoadException ( 'RCCTV2_ROL_LoadFromCSVDoc.doLoad(): cannot find an existing role corresponding to role in first column: ' + sRootRoleName + ' (null list)');
            if ( listRootUserRole.size() == 0) throw new RCCTV2RoleLoadException ( 'RCCTV2_ROL_LoadFromCSVDoc.doLoad(): cannot find an existing role corresponding to role in first column: ' + sRootRoleName + ' (empty list)');
            if ( listRootUserRole.size() > 1)  throw new RCCTV2RoleLoadException ( 'RCCTV2_ROL_LoadFromCSVDoc.doLoad(): found more than one role corresponding to role in first column: ' + sRootRoleName + '. User a role which has a unique name');

            UserRole oRootRole = listRootUserRole.get(0); //role underwhich we will load our hierarchy

            //We need to store roles as they are loaded. We use a map of map. 1st key is column. For each 
            // column we store a map of <RoleName, UserRole>. This way we can find a ParentRoleId from
            // its name in the map of the previous column:
            // 		<Col1, <rolename1, role1><rolename2, role2><..., ...>>
            // 		<Col2, <rolenameX, roleX><rolenameY, roleY><..., ...>>
            map<integer,map<string,UserRole>> mapMapLoadedRoles = new map<integer,map<string,UserRole>> ();

            //Let's initiate mapLoadedRoles for Col0 with the existing Role (our Root Role)
            map<string, UserRole> mapCol0LoadedRole = new map<string, UserRole> ();
            mapCol0LoadedRole.put(sRootRoleName,oRootRole);
            mapMapLoadedRoles.put(0, mapCol0LoadedRole);

			//poka Collect a map of existing roles to manage upserts. We'll match by name, parentRoleId
			map<UserRole,Id> mapExistingUserRole = new map<UserRole,Id>();
			list<UserRole> listExistingUserRole = new list<UserRole>([select name, parentRoleId
                                                      from userRole
                                                      LIMIT 9999]);
            for (UserRole oUserRole : [select name, parentRoleId
                                                      from userRole
                                                      LIMIT 9999]) // not transferring list directly otherwise Id is initialized somehow
            {
                mapExistingUserRole.put(new UserRole( Name = oUserRole.name, ParentRoleId = oUserRole.parentRoleId)
                                        ,oUserRole.id);
            }


            //Let's start working! We traverse column by column
            //	In each column we'll find rolenames, and for each rolename we'll look for the
            //	parent role in the adjacent cell of previous column. For example in the hierarchy 
            //	below parent of APAC Region is International
            //		Global	International		
            //		Global	International	APAC Region	
            //		Global	International	APAC Region	ASEAN Cluster            
            // 
            // Then we'll look for Parent role id in the map of <name, UserRole> for previous 
            // column which we will find in our mapMapLoadedRoles of <column, map of parent roles>
            integer iRow;
            integer iCol;
            integer iPrevCol; //is iCol - 1, but makes the code easier to read for me
            string	sCurrentCell = '';
            string 	sPreviousCell = '';
            integer iNbInserts = 0;
            integer iNbUpdates = 0;
     
            for (iCol = 1; iCol < iNbCol; iCol++)
            {
                iPrevCol = iCol -1; //yes I know, but I find it easier to read
                set<UserRole> setCurrentColRoles = new set<UserRole>(); //use a set to deduplicate

                // Start at row 1 to skip header
                for (iRow = 1; iRow < iNbRow; iRow++)
                {
                    sCurrentCell = '';
                    sPreviousCell = '';
                    //skip emtpy cells (ok, not elegant I should rather check size of current listListCSV row)
	                // but.... good enough. It depends on how the csv is loaded by the CSV parser and
	                // whether it removes trailing empty cells or not. 
                    try {
                        sCurrentCell = listListCSV[iRow][iCol];
                        if ( (sCurrentCell == '') || (sCurrentCell == '\r') || (sCurrentCell == '\n')  ) 
                        {
                            continue;
                        }
                    } catch (Exception e) {
                            system.debug('NULL Cell on listListCSV[' + iRow +']['+iCol +'] ');
                            continue;
                    }
                    sCurrentCell = sCurrentCell.remove('\n'); //remove last training crlf
                    sCurrentCell = sCurrentCell.remove('\r'); //remove last training crlf

                    sPreviousCell = listListCSV[iRow][iCol-1];
	                //system.debug('=============> Load Role From CSV current  listListCSV[' + iRow +']['+iCol     +'] ' + listListCSV[iRow][iCol]);
	                //system.debug('=============> Load Role From CSV previous listListCSV[' + iRow +']['+iPrevCol +'] ' + listListCSV[iRow][iPrevCol]);

                    string sRoleName	   = sCurrentCell;
                    string sParentRoleName = sPreviousCell; 	//parent is in previous column, same row
                    //system.debug('=========> Load Roles from CSV. iPrevCol: ' + iPrevCol 
                    //             + ' sParentRoleName: ' + sParentRoleName
                    //             + ' sRoleName: ' + sRoleName);
                    //system.debug('=========> mapMapLoadedRoles: ' + mapMapLoadedRoles);

                    
                    //                         Map of <string<UserRole> 
                    //                             for current column
                    //                                    |            Get role by its
                    //                                    |            string Name
                    //                                    |                |          Id of parent UserRole
                    //                                    |                |                |
                    id sParentRoleId = mapMapLoadedRoles.get(iPrevCol).get(sParentRoleName).id; 

					//pokb Upsert management. If role found in existing map, set get the id to do an upsert
					// N.B.: we only check on name, parentRoleId which is arguable, mightbe improved?
					UserRole oUserRoleToUpsert = new UserRole( Name = sRoleName, ParentRoleId = sParentRoleId);
                    if (mapExistingUserRole.containsKey(oUserRoleToUpsert)) //will be an update
                    {
	                    oUserRoleToUpsert.id = mapExistingUserRole.get(oUserRoleToUpsert);
                        iNbUpdates++;
                    } // else id is null, will be an insert
					else
                    {
                        //system.debug('==========> INSERT!!!!!!: ' + oUserRoleToUpsert);
                        iNbInserts++;
                    }
                    oUserRoleToUpsert.ContactAccessForAccountOwner 		= sContactAccessForAccountOwner;
                    oUserRoleToUpsert.OpportunityAccessForAccountOwner 	= sOpportunityAccessForAccountOwner;
                    oUserRoleToUpsert.CaseAccessForAccountOwner 		= sCaseAccessForAccountOwner;
                    setCurrentColRoles.add(oUserRoleToUpsert);

                } //end of loop on rows (rows of current col)

                //Convert our set of column roles into a list
                list<UserRole> listCurrentColRoles = new list<UserRole>(setCurrentColRoles); 

                // upsert colum to database
                upsert listCurrentColRoles;
                
                //let's store in a map the current column roles
                map<string, UserRole> mapCurrentColLoadedRoles = new map<string, UserRole> ();
                for (UserRole oUserRole : listCurrentColRoles)
                {
					mapCurrentColLoadedRoles.put(oUserRole.name, oUserRole);                 
                }

                //finally let's add the column roles to our map of map so that we have it for nex column
                mapMapLoadedRoles.put(iCol,mapCurrentColLoadedRoles);
            } //end of loop on Col
            system.debug('=============> Load Role from CSV after main loop, updates: ' + iNbUpdates + ' inserts: ' + iNbInserts);

            sRetCode = 'OK';  
        } catch (Exception e){
                Database.rollback(sp);
                throw new RCCTV2RoleLoadException ( 'RCCTV2_ROL_LoadFromCSVDoc.doLoad() other exception pouet: ' + sRetCode );
        }
        return sRetCode;     //end of logic, auto commit;
    } //end of doLoad()
}