@isTest(SeeAllData=true)
public class RCCTV2_ROL_LoadFromCSVDoc_Test {

    public class LoadRoleFromCSVTestException extends Exception {}

    public static testMethod void testDoload(){      

            
        //build some dummy CSV string
        string sStringCSV = 'L0,L1,L2,L3\n'	;
        sStringCSV += 'Z-Test-Apex-0-0\n';
        sStringCSV += 'Z-Test-Apex-0-0,1-1\n';
        sStringCSV += 'Z-Test-Apex-0-0,2-1,2-2\n';
        sStringCSV += 'Z-Test-Apex-0-0,"3-1",3-2\n';
        sStringCSV += 'Z-Test-Apex-0-0,4-1\n';
        sStringCSV += 'Z-Test-Apex-0-0,5-1,5-2\n';
        sStringCSV += 'Z-Test-Apex-0-0,5-1\n';
        sStringCSV += 'Z-Test-Apex-0-0\n';

        //create file outside of test so that it is not mixed with the test.start in term of mixed DML etc...
        string sFileName = 'Apex-Deploy-testParseCSV';
        Document d = new Document(); 
        d.Name = sFileName; //.replace(' ', '-') + '-' + datetime.now().formatGMT('yyyy-MM-dd\'-\'HH:mm'); 
        d.Body = Blob.valueOf(sStringCSV); 
        d.ContentType = 'text/plain';
        d.Type = 'csv';
        d.FolderId = UserInfo.getUserId();

        insert d;  

        // test itself
        Test.startTest();
		
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        // This is to prevent MIXED_DML_OPERATION error because we mix regular insert (document) and setup insert (roles)
        // see: https://developer.salesforce.com/forums?id=906F00000008vk3IAA
        System.runAs ( thisUser ) {        
            UserRole oRootRole = new UserRole(name = 'Z-Test-Apex-0-0', developername = 'Z_Test_Apex_0_0');
            insert oRootRole;
            try {
                string sRC = RCCTV2_ROL_LoadFromCSVDoc.doLoad(sFileName, 'Edit', 'Edit', 'Edit'); //should always have this option available, shouldn't we?
                system.assertEquals('OK', sRC, 'Apex test RCCTV2_ROL_LoadFromCSVDoc_Test.TestdoLoad failed with Error 01: RetCode != OK');
                
            } catch (Exception e) {
                throw new LoadRoleFromCSVTestException('Apex test RCCTV2_ROL_LoadFromCSVDoc_Test.TestdoLoad failed with Error 00. Catched error: ' + e);
            }
        }
        test.stopTest();
    }

    
    
}