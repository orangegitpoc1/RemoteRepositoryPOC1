@isTest(SeeAllData=true)
//[15/01/14 OLE UST-01048 WIT-002037 RCCTv2]

public class RCCTV2_ROL_Util_Test {

    //pull root role for testing
    //note: we are not creating data, only reading role hieararchy
    private static UserRole oUserRole = [SELECT id, Name FROM UserRole where ParentRoleId ='' LIMIT 1];

    //--------------------- Test 1 -----------------------------------------------------
    public static testMethod void listRCCTRegions(){      

        
        Test.startTest();
    
        list<SMB_Setting_Region__c> listSettingRegion = RCCTV2_ROL_Util.listRCCTRegions();
        
        system.assert((listSettingRegion != null));
        if (listSettingRegion != null) 
        {
            system.assert(listSettingRegion.size() > 0, 'No entries in custom setting SMB Setting Region. Regions msut be declared before using RCCT');
        }

        Test.stopTest();
    }        

    //--------------------- Test 2 -----------------------------------------------------
    public static testMethod void listRCCTChildren(){      


        Test.startTest();
        //find children from top role. We except children (otherwise RCCT and Role hiearachy aer pointless)
        list<UserRole> listUserRole = RCCTV2_ROL_Util.listRCCTChildren(oUserRole.name, 'dummy exclusion string');
        system.assert((listUserRole != null)); //not normal to return an empty list

        listUserRole = RCCTV2_ROL_Util.listRCCTChildren('Role name unlikely to exist azd988hazdoijzf7a', 'G');
        system.assert((listUserRole == null));  // expect no list returned

        listUserRole = RCCTV2_ROL_Util.listRCCTChildren(null, 'GOIJdazoduhazdhuoixiaoidj');
        system.assert((listUserRole == null));  //expect nothing returned

        Test.stopTest();
    }        

    public class RCCTV2_ROL_Util_TestException extends Exception {}

    //--------------------- Test 3 -----------------------------------------------------
    public static testMethod void dumpRoleHierToCSV(){      

        Test.startTest();       
        try {
            
            RCCTV2_ROL_Util.dumpRoleHierToCSV(
              new set<String>{oUserRole.name} //setParentname  set<string> or null to start from root node
            , ':'           // sep
            , true          // escapeQuoteCSV
            , 'Presale'         // exclude csv list
            ,2              // maxDepth
            );
        } catch (Exception e) {
            
            system.assert(false, 'RCCTV2_ROL_Util_Test.dumpRoleHierToCSV() fails with exception:' + e);            
        }
    
        Test.stopTest();
    }    

    //--------------------- Test 4 -----------------------------------------------------
    public static testMethod void enforceNonApplicable(){      
        
        string sReturn;
        RCCTV2_Tuple oRCCT = new RCCTV2_Tuple();
        Test.startTest();
        
        oRCCT.region = null; oRCCT.cluster = null; oRCCT.country = null; oRCCT.territory = null;
        sReturn = RCCTV2_ROL_Util.enforceNonApplicable(oRCCT);
        system.assertEquals('', sReturn, 'RCCTV2_ROL_Util_Test.enforceNonApplicable error 1: ' + sReturn);

        oRCCT.region = '--none--'; oRCCT.cluster = null; oRCCT.country = null; oRCCT.territory = null;
        sReturn = RCCTV2_ROL_Util.enforceNonApplicable(oRCCT);
        system.assertEquals('', sReturn, 'RCCTV2_ROL_Util_Test.enforceNonApplicable error 2: ' + sReturn);
        
        oRCCT.region = '--dummy--'; oRCCT.cluster = '--none--'; oRCCT.country = null; oRCCT.territory = null;
        sReturn = RCCTV2_ROL_Util.enforceNonApplicable(oRCCT);
        system.assertEquals('', sReturn, 'RCCTV2_ROL_Util_Test.enforceNonApplicable error 3: ' + sReturn);
        
        oRCCT.region = '--dummy--'; oRCCT.cluster = 'N/A'; oRCCT.country = null; oRCCT.territory = null;
        sReturn = RCCTV2_ROL_Util.enforceNonApplicable(oRCCT);
        system.assertEquals('', sReturn, 'RCCTV2_ROL_Util_Test.enforceNonApplicable error 4: ' + sReturn);

        oRCCT.region = '--dummy--'; oRCCT.cluster = '--dummy--'; oRCCT.country = '--none--'; oRCCT.territory = null;
        sReturn = RCCTV2_ROL_Util.enforceNonApplicable(oRCCT);
        system.assertEquals('', sReturn, 'RCCTV2_ROL_Util_Test.enforceNonApplicable error 5: ' + sReturn);
        
        oRCCT.region = '--dummy--'; oRCCT.cluster = '--dummy--'; oRCCT.country = 'N/A'; oRCCT.territory = null;
        sReturn = RCCTV2_ROL_Util.enforceNonApplicable(oRCCT);
        system.assertEquals('', sReturn, 'RCCTV2_ROL_Util_Test.enforceNonApplicable error 6: ' + sReturn);
        
        oRCCT.region = '--dummy--'; oRCCT.cluster = '--dummy--'; oRCCT.country = '--dummy--'; oRCCT.territory = '--none--';
        sReturn = RCCTV2_ROL_Util.enforceNonApplicable(oRCCT);
        system.assertEquals('', sReturn, 'RCCTV2_ROL_Util_Test.enforceNonApplicable error 7: ' + sReturn);
        
        oRCCT.region = '--dummy--'; oRCCT.cluster = '--dummy--'; oRCCT.country = '--dummy--'; oRCCT.territory = 'N/A';
        sReturn = RCCTV2_ROL_Util.enforceNonApplicable(oRCCT);
        system.assertEquals('', sReturn, 'RCCTV2_ROL_Util_Test.enforceNonApplicable error 8: ' + sReturn);
        
        
        Test.stopTest();
    }


}