@isTest(SeeAllData=true)
private class SMBW1_ActionPlan_CloneTask_Test {
    static testMethod void myUnitTest(){
        List<RecordType> listRecordtype = [SELECT Id FROM RecordType WHERE SobjectType = 'Account'
        AND IsActive = true order by DeveloperName];
        Account AccTest = new Account(name = 'CocaFranceTest', RCE_ID__c = 'TestRCEId', iSell__OSKeyID__c = 'TestRCEId', recordTypeId = listRecordtype[0].Id); //, Sales_Region__c = 'France');
        insert AccTest;
        Contact contTest = new Contact(AccountId = AccTest.Id, Salutation = 'Mr', FirstName = 'testFirst',
        LastNAme = 'testLast');
        insert contTest;
        Action_Plan__c ap1 = new Action_Plan__c(SMB_AP_Account__c = AccTest.Id);
        insert ap1;
        Task t1 = new Task(Subject = 'Test subject', ActivityDate = Date.today(), Description = 'test comment',
        WhoId = contTest.Id, WhatId = ap1.Id, Status = 'Not Started', Category__c = 'Meeting');
        insert t1;
        Task t2 = new Task(Subject = 'Test subject2', ActivityDate = Date.today(), Description = 'test comment',
        WhoId = contTest.Id, WhatId = ap1.Id, Status = 'Not Started', Category__c = 'Meeting');
        insert t2;
        Action_Plan__c ap2 = new Action_Plan__c(SMB_AP_Account__c = AccTest.Id);
        insert ap2;
        
        Test.startTest();
        ApexPages.StandardController scTest = new ApexPages.standardController(ap2);
        SMBW1_ActionPlan_CloneTask_VFC testCloneTask = new SMBW1_ActionPlan_CloneTask_VFC(scTest);
        testCloneTask.cancel();
        testCloneTask.ac.SMB_AP_TECH_Lookup_Id__c = ap1.Id;
        testCloneTask.retrieveTasks();
        System.assertEquals(testCloneTask.listTaskWrapper.size(), 2);
        testCloneTask.listTaskWrapper[0].bool = true;
        testCloneTask.cloneTask();
        Test.stopTest();
    }
}