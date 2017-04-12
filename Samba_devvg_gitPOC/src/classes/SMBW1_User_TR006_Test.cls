@isTest(SeeAllData=true)
private class SMBW1_User_TR006_Test {
    static testMethod void myUnitTest(){
        //OLE: 2014-05-25 set explicity SMB_Sales_Region__c rather than query (for test when deploying since no user deployed yet with this attribute filled)
        /*
        List<User> listU = [SELECT Id, Name, Email, SMB_Sales_Cluster__c, SMB_Sales_Country__c,
        SMB_Sales_Region__c, SMB_Sales_Territory__c FROM User WHERE isActive = true AND SMB_Sales_Region__c =: 'Europe'
        AND Profile.Name = 'System Administrator' limit 1];
        */
        /*List<User> listU = [SELECT Id, Name, Email, SMB_Sales_Cluster__c, SMB_Sales_Country__c,
        SMB_Sales_Region__c, SMB_Sales_Territory__c FROM User WHERE isActive = true // AND SMB_Sales_Region__c =: 'Europe'
        AND Profile.Name = 'System Administrator' limit 1];
        ListU[0].SMB_Sales_Region__c = 'Europe';
        
        List<RecordType> listRecordtype = [SELECT Id FROM RecordType WHERE SobjectType = 'Account'
        AND IsActive = true order by DeveloperName];
        Account AccTest = new Account(Sales_Territory__c = 'Vietnam', name = 'CocaFranceTest', iSell__OSKeyID__c = 'TestRCEId', recordTypeId = listRecordtype[0].Id, OwnerId = listU[0].Id);
        insert AccTest;
        
        Test.startTest();
        listU[0].SMB_Sales_Territory__c = 'China';
        update listU;
        Account AccTestFinal = [SELECT Id, Sales_Territory__c FROM Account WHERE Id =: AccTest.Id limit 1];
        System.assertEquals(AccTestFinal.Sales_Territory__c, listU[0].SMB_Sales_Territory__c);
        Test.stopTest();*/
    }

}