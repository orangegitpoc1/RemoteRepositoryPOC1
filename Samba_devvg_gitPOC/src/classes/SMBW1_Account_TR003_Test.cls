@isTest(SeeAllData=true)
private class SMBW1_Account_TR003_Test {
    static testMethod void myUnitTest(){
        
        List<RecordType> listRecordtype = [SELECT Id FROM RecordType WHERE SobjectType = 'Account'
        AND IsActive = true order by DeveloperName];
        Account AccTest = new Account(name = 'CocaFranceTest', RCE_ID__c = 'TestRCEId', iSell__OSKeyID__c = 'TestRCEId', recordTypeId = listRecordtype[0].Id); //, Sales_Region__c = 'France');
        insert AccTest;
        Account AccTest2 = new Account(name = 'CocaInterTest', iSell__OSKeyID__c = 'TestOsKeyId', recordTypeId = listRecordtype[2].Id); //, Sales_Region__c = 'Americas');
        insert AccTest2;
        
        Test.startTest();
        Account AccTestDupli = new Account(name = 'ColaFranceTest', RCE_ID__c = 'TestRCEId', recordTypeId = listRecordtype[0].Id); //, Sales_Region__c = 'France');
        System.assertEquals(AccTestDupli.RCE_ID__c, AccTest.RCE_ID__c);
        Test.stopTest();
    }
}