@isTest(SeeAllData=true)
private class SMBW1_Opportunity_TR002_Test {
    static testMethod void myUnitTest(){
        List<User> listU = [SELECT Id, Name, Email FROM User WHERE isActive = true and Profile.Name = 'System Administrator' limit 2];
        List<RecordType> listRecordtype = [SELECT Id FROM RecordType WHERE SobjectType = 'Account'
        AND IsActive = true order by DeveloperName];
        Account AccTest = new Account(name = 'CocaFranceTest', RCE_ID__c = 'TestRCEId', iSell__OSKeyID__c = 'TestRCEId', recordTypeId = listRecordtype[0].Id, /*Sales_Region__c = 'France',*/ OwnerId = listU[0].Id);
        insert AccTest;
        Account AccTest2 = new Account(name = 'CocaInterTest', iSell__OSKeyID__c = 'TestOsKeyId', recordTypeId = listRecordtype[2].Id, /*Sales_Region__c = 'Americas',*/ Ultimate_Parent_Account__c = AccTest.Id, OwnerId = listU[1].Id);
        insert AccTest2;
        Opportunity OppTest= new Opportunity(Name='NameOpportunity', stageName='Pre-qualification',Amount= 23.00 ,CloseDate=Date.Today().addDays(1), AccountId =AccTest2.id );
        
        Test.startTest();
        insert OppTest;
        Test.stopTest();
    }
}