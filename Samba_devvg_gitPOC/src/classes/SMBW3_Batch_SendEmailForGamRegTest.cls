@isTest
public class SMBW3_Batch_SendEmailForGamRegTest{
    
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
            Database.executebatch(new SMBW3_Batch_SendEmailForGamRegistration
      ('SELECT Id, Name, GAM_type__c, Owner.Name, Account.Name, RecordType.Name, StageName, Amount FROM Opportunity WHERE GAM_type__c = \'Standard GAM\' '+
      'AND CurrentDateTime_OnChange_Of_Registration__c = LAST_N_DAYS:1 AND Standard_GAM_Registered__c=true', 
      System.Label.User_Frequency_1day));
        Test.stopTest();
    }
    
}