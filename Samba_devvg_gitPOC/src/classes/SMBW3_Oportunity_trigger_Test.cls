@isTest 
public class SMBW3_Oportunity_trigger_Test{

    static testMethod void afterinsert()
    {
        Id parentRoleId = TestDataCreation.createUserRoles(1, null)[0].Id;
        user us=TestDataCreation.createUsers(1, System.Label.Sales_Operation_SAMBA, System.Label.User_Frequency_1day, parentRoleId)[0];
        
        Id roleId = TestDataCreation.createUserRoles(1, parentRoleId)[0].Id;
        Id userId = TestDataCreation.createUsers(1, System.Label.Sales_User_SAMBA, System.Label.User_Frequency_1day, roleId)[0].Id;
        //Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales User SAMBA'];
        
        User u = new User
        (Alias = 'standt', Email='standarduser1@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing1', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeg@testorg.com', SMB_Bypass_VR__c=true,PAD_BypassTrigger__c='');
        
       System.runAs(us){
       Test.startTest();
       
           TestDataCreation.createSplitcommission(1, 'Commission');
           TestDataCreation.createSplitsales(1, 'Sales User SAMBA');
           TestDataCreation.createSplitfinance(1, 'Finance');
           account acc=TestDataCreation.createAccounts(1)[0];
           System.assertEquals(acc.name,'Test0');
           account accul=TestDataCreation.createultimateAccounts(1,acc.id)[0];
           opportunity opp=TestDataCreation.createOpportunitiesWithAccount(1,acc.id)[0];
           system.assertEquals(opp.name,'Test0');
           TestDataCreation.createOppSplitcommission(2,opp.id);
           TestDataCreation.createOppSplitfinance(1,opp.id);
           list<contact> con=TestDataCreation.createContactsWithAccount(1,acc.id,'testingOme');
           OpportunityContactRole ocr1 = new OpportunityContactRole(opportunityid=opp.id,contactid=con[0].id);
           insert ocr1;
           opportunity oppupdate=new opportunity(id=opp.id,Amount=12345.00);
           update oppupdate;
       }
    }
    static testMethod void OME(){
        UserRole UR=new UserRole(Name='OME', ParentRoleId=null);
        insert UR;
        user us=TestDataCreation.createUsers(1, System.Label.Sales_Operation_SAMBA, System.Label.User_Frequency_1day, UR.id)[0];
        
      //  Id roleId = TestDataCreation.createUserRoles(1, parentRoleId)[0].Id;
        Id userId = TestDataCreation.createUsers(1, System.Label.Sales_User_SAMBA, System.Label.User_Frequency_1day, UR.id)[0].Id;
        //Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales User SAMBA'];
        
        User u = new User
        (Alias = 'standt', Email='standarduser1@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing1', 
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', 
        UserName='abcdeg@testorg.com', SMB_Bypass_VR__c=true,PAD_BypassTrigger__c='',UserRoleid=UR.id);
        
       System.runAs(us){
       Test.startTest();
           TestDataCreation.createSplitcommission(1, 'Commission');
           TestDataCreation.createSplitsales(1, 'Sales User SAMBA');
           TestDataCreation.createSplitfinance(1, 'Finance');
           account acc=TestDataCreation.createAccounts(1)[0];
           opportunity opp=TestDataCreation.createOpportunitiesWithAccount(1,acc.id)[0];
           TestDataCreation.createOppSplitcommission(2,opp.id);
           TestDataCreation.createOppSplitfinance(1,opp.id);
           list<contact> con=TestDataCreation.createContactsWithAccount(1,acc.id,'testingOme');
           OpportunityContactRole ocr1 = new OpportunityContactRole(opportunityid=opp.id,contactid=con[0].id);
           insert ocr1;
       Test.stopTest();    
            
    
       }
    }   
    

}