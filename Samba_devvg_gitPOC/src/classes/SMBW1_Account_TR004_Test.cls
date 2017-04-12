@isTest(SeeAllData=true)
private class SMBW1_Account_TR004_Test {
    static testMethod void myUnitTest(){
        List<User> listU = [SELECT Id, Name, Email FROM User WHERE isActive = true and Profile.Name = 'System Administrator' limit 1];
        List<RecordType> listRecordtype = [SELECT Id FROM RecordType WHERE SobjectType = 'Account'
        AND IsActive = true order by DeveloperName];
        Account AccTest = new Account(name = 'CocaFranceTest', RCE_ID__c = 'TestRCEId', iSell__OSKeyID__c = 'TestRCEId', recordTypeId = listRecordtype[0].Id, /*Sales_Region__c = 'France', */ OwnerId = listU[0].Id);
        insert AccTest;
        Account AccTest2 = new Account(name = 'CocaInterTest', iSell__OSKeyID__c = 'TestOsKeyId', recordTypeId = listRecordtype[2].Id, /*Sales_Region__c = 'Americas',*/ Ultimate_Parent_Account__c = AccTest.Id);
        
        Test.startTest();
        insert AccTest2;
        AccTest2.Ultimate_Parent_Account__c = null;
        update AccTest2;
        AccTest2.Ultimate_Parent_Account__c = AccTest.Id;
        update AccTest2;
        Test.stopTest();
    }
}