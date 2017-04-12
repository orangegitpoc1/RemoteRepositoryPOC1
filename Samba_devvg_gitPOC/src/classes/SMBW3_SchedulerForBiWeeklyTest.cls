@isTest
public class SMBW3_SchedulerForBiWeeklyTest{

    static testMethod void testCondition1(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User
        (Alias = 'standt', Email='standarduser@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeg@testorg.com', SMB_Bypass_VR__c=true);
        System.runAs(u){
            TestDataCreation.createSplitcommission(1, 'Commission');
           account acc=TestDataCreation.createAccounts(1)[0];
           System.assertEquals(acc.name,'Test0');
           account accul=TestDataCreation.createultimateAccounts(1,acc.id)[0];
           opportunity opp=TestDataCreation.createOpportunitiesWithAccount(1,acc.id)[0];
        }
    
        Test.startTest();
            String jobId = System.schedule('testSMBW3_SchedulerForBiWeekly', 
                            '0 0 12 1/2 * ?', new SMBW3_SchedulerForBiWeekly());
        Test.stopTest();
    }
    
}