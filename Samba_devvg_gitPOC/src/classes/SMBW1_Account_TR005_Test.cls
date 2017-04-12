@isTest(SeeAllData=true)
private class SMBW1_Account_TR005_Test {
    static testMethod void myUnitTest(){
        /*List<User> listU = [SELECT Id, Name, Email, SMB_Sales_Cluster__c, SMB_Sales_Country__c,
        SMB_Sales_Region__c, SMB_Sales_Territory__c FROM User WHERE isActive = true AND SMB_Sales_Region__c !=: 'France'
        AND Profile.Name = 'System Administrator' limit 2];
        List<RecordType> listRecordtype = [SELECT Id FROM RecordType WHERE SobjectType = 'Account'
        AND IsActive = true order by DeveloperName];
        Account AccTest = new Account(name = 'CocaFranceTest', iSell__OSKeyID__c = 'TestRCEId', recordTypeId = listRecordtype[0].Id, OwnerId = listU[0].Id);
        
        Test.startTest();
        insert AccTest;*/
        /*System.assertEquals(AccTest.Sales_Region__c, listU[0].SMB_Sales_Region__c);
        System.assertEquals(AccTest.Sales_Cluster__c, listU[0].SMB_Sales_Cluster__c);
        System.assertEquals(AccTest.Sales_Country__c, listU[0].SMB_Sales_Country__c);
        System.assertEquals(AccTest.Sales_Territory__c, listU[0].SMB_Sales_Territory__c);*/
        /*AccTest.OwnerId = listU[1].Id;
        update AccTest;*/
        /*System.assertEquals(AccTest.Sales_Region__c, listU[1].SMB_Sales_Region__c);
        System.assertEquals(AccTest.Sales_Cluster__c, listU[1].SMB_Sales_Cluster__c);
        System.assertEquals(AccTest.Sales_Country__c, listU[1].SMB_Sales_Country__c);
        System.assertEquals(AccTest.Sales_Territory__c, listU[1].SMB_Sales_Territory__c);*/
        /*Test.stopTest();*/
    }

}